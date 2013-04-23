function depth = sweep(datapath, n_disparity, ref_cam_id, n_nearby_cam, DOWNSAMPLE, PLOT_CAMERA, PLOT_DEPTH)
%% Read in data
%PLOT_CAMERA = 1;
%DOWNSAMPLE = 1;

%datapath = '../../data/fountain_dense';
%datapath = '../../data/herzjesu_dense';
%datapath = '../../data/castle_entry_dense';

image_names = dir(fullfile(datapath, '*.png'));
camera_names = dir(fullfile(datapath, '*.camera'));
bbox_names = dir(fullfile(datapath, '*.bounding'));

n_camera = numel(image_names);

images = cell(n_camera, 1);
cameras = cell(n_camera, 1);
bbox = cell(n_camera, 1);

K = zeros(3);
R = zeros(3);
C = zeros(3,1);

for i = 1 : n_camera
    fprintf('Loading %d/%d image.\n', i, n_camera);
    f_camera = fopen(fullfile(datapath, camera_names(i).name));
    f_bbox = fopen(fullfile(datapath, bbox_names(i).name));
    images{i} = im2double(imread(fullfile(datapath, image_names(i).name)));
    
    K(1,:) = fscanf(f_camera, '%f %f %f', 3);
    K(2,:) = fscanf(f_camera, '%f %f %f', 3);
    K(3,:) = fscanf(f_camera, '%f %f %f', 3);
    fscanf(f_camera, '%f %f %f', 3);
    
    R(1,:) = fscanf(f_camera, '%f %f %f', 3);
    R(2,:) = fscanf(f_camera, '%f %f %f', 3);
    R(3,:) = fscanf(f_camera, '%f %f %f', 3);
    R = R';
    
    C = fscanf(f_camera, '%f %f %f', 3);
    [img_size, ~] = fscanf(f_camera, '%f %f', 2);
    
    if DOWNSAMPLE == 1
        K = K ./ 5;
        K(3,3) = 1;
        images{i} = imresize(images{i}, 0.2);
        [img_size(2), img_size(1), ~] = size(images{i});
    end
    
    cameras{i}.R = R;
    cameras{i}.K = K;
    cameras{i}.C = C;
    cameras{i}.T = - R * C;
    
    bbox{i}.max = fscanf(f_bbox, '%f %f %f', 3);
    bbox{i}.min = fscanf(f_bbox, '%f %f %f', 3);
    
    fclose(f_camera);
    fclose(f_bbox);
end

%% Plot camera positions and orientations
if PLOT_CAMERA == 1
    x = [0 0 0 0; 3 3 -3 3; 3 -3 -3 -3] .* 0.1;
    y = [0 0 0 0; 2 2 -2 -2; -2 2 2 -2] .* 0.1;
    z = [0 0 0 0; 1 1 1 1; 1 1 1 1] .* 0.5;
    
    figure, hold on;
    for i = 1 : n_camera
        Pts = [cameras{i}.R', cameras{i}.C] * [x(:)'; y(:)'; z(:)'; ones(1,12)];
        fill3(reshape(Pts(1,:), 3, 4), reshape(Pts(2,:), 3, 4), reshape(Pts(3,:), 3, 4), 'b');
        xlabel('X');ylabel('Y');zlabel('Z');
        axis equal;
    end
end

%% Camera transformations

%ref_cam_id = round(median(1:n_camera));
ref_cam = cameras{ref_cam_id};
ref_img = images{ref_cam_id};

% n_nearby_cam = 4;
nearby_cam_id = ref_cam_id - n_nearby_cam / 2 : ref_cam_id + n_nearby_cam / 2;
nearby_cam_id(nearby_cam_id == ref_cam_id) = [];
src_cams = cameras(nearby_cam_id);
src_bbox = bbox(nearby_cam_id);
src_imgs = images(nearby_cam_id);

for c_idx = 1 : n_nearby_cam
    src_cams{c_idx}.T = ref_cam.T - ref_cam.R * src_cams{c_idx}.R' * src_cams{c_idx}.T;
    src_cams{c_idx}.R = ref_cam.R * src_cams{c_idx}.R';
end

%% Depth range computations
depth_range = zeros(n_nearby_cam, 2);
for c_idx = 1 : n_nearby_cam
    p1 = src_bbox{c_idx}.min;
    p2 = src_bbox{c_idx}.max;
    Pts = [p1(1), p1(1), p1(1), p1(1), p2(1), p2(1), p2(1), p2(1);%x
        p1(2), p1(2), p2(2), p2(2), p1(2), p1(2), p2(2), p2(2);%y
        p1(3), p2(3), p1(3), p2(3), p1(3), p2(3), p1(3), p2(3);%z
        ones(1, 8)];
    Pts2 = [ref_cam.R ref_cam.T] * Pts;
    depth_range(c_idx, 1) = min(Pts2(3,:));
    depth_range(c_idx, 2) = max(Pts2(3,:));
end
d_near = min(depth_range(:,1));% - 0.8;
d_far = min(depth_range(:,2));% + 0.8;

%% Plane sweep
n = [ 0 0 -1];
% n_disparity = 250;
disparity = linspace(d_near, d_far, n_disparity);

best_costs = zeros(img_size(2), img_size(1)) + realmax;
depth = zeros(img_size(2), img_size(1));

for d_idx = 1 : n_disparity
    fprintf('Sweep %f%% at depth %f\n', d_idx * 100 / n_disparity, disparity(d_idx));
    cur_cost = zeros(img_size(2), img_size(1)) + realmax;
    %compute cost for each source camera
    for c_idx = 1 : n_nearby_cam
        H = ref_cam.K * (src_cams{c_idx}.R - src_cams{c_idx}.T * n ./ disparity(d_idx)) * inv(src_cams{c_idx}.K);
        tform = maketform('projective', H');
        timg = imtransform(src_imgs{c_idx}, tform, 'XData', [1, img_size(1)], 'YData', [1, img_size(2)]);
        %aggregate matching cost
        cur_cost = min(cur_cost, img_ssd(timg, ref_img));
    end
    
    updated_idx = best_costs > cur_cost;
    depth(updated_idx) = disparity(d_idx);
    best_costs(updated_idx) = cur_cost(updated_idx);
    
    if PLOT_DEPTH == 1
        figure(32768);
        subplot(1,2,1);
        imshow(ref_img);
        
        subplot(1,2,2);
        imagesc(depth);axis image;colorbar;drawnow;
    end
end
end