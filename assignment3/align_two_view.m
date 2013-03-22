% Align two images by affine transformation and homography
%% Load images
clear all;
close all;
clc;

datapath = '../../data/AlignmentTwoViews';
imname1 = fullfile(datapath, 'uttower_left.jpg');
imname2 = fullfile(datapath, 'uttower_right.jpg');

im1 = imread(imname1);
im2 = imread(imname2);
im1 = im2double(im1);
im2 = im2double(im2);
[height1, width1, ~] = size(im1);
[height2, width2, ~] = size(im2);

im1gray = rgb2gray(im1);
im2gray = rgb2gray(im2);

%% Detect corners
sigma = 0.8;
radius = 5;
num = 1000;
[im1dx, im1dy] = im_gradient(im1gray);
[im2dx, im2dy] = im_gradient(im2gray);
[~, row1, col1] = detect_corner(im1dx, im1dy, sigma, num, radius);
[~, row2, col2] = detect_corner(im2dx, im2dy, sigma, num, radius);

%% Extract features
radius = 20;
im1features = zeros(length(row1), (2 * radius + 1).^2);
im2features = zeros(length(row2), (2 * radius + 1).^2);

h = zeros(2 * radius + 1); h(radius+1, radius+1) = 1;
pad_im1 = imfilter(im1gray, h, 'replicate', 'full');
pad_im2 = imfilter(im2gray, h','replicate', 'full');

for i = 1 : length(row1)
    patch = pad_im1(row1(i) : row1(i) + 2 * radius, col1(i) : col1(i) + 2 * radius);
    im1features(i,:) = patch(:);
end

for i = 1 : length(row2)
    patch = pad_im2(row2(i) : row2(i) + 2 * radius, col2(i) : col2(i) + 2 * radius);
    im2features(i,:) = patch(:);
end

%% Match features
NCC = ncc2(im1features, im2features);

numMatches = 100;
[~,ncc_idx] = sort(NCC(:), 'descend');
[im1feature_idx, im2feature_idx] = ind2sub(size(NCC), ncc_idx(1:numMatches));

%% Show matches
im = cat(2, im1, im2);
figure; imshow(im); hold on; title('Matches detected by NCC');
cmaps = hsv(numMatches);
for i = 1 : numMatches
    lr = row1(im1feature_idx(i));
    lc = col1(im1feature_idx(i));

    rr = row2(im2feature_idx(i));
    rc = col2(im2feature_idx(i));

    r = [lr - radius rr - radius];
    c = [lc - radius rc - radius + width1];
    plot(c, r, 'Color', cmaps(i,:));
end

%% Estimate transformation
x1 = [col1(im1feature_idx) row1(im1feature_idx) ones(numMatches,1)];
x2 = [col2(im2feature_idx) row2(im2feature_idx) ones(numMatches,1)];

%A = computeA(x1, x2);
[H, homography_inlier_num, homography_inlier_idx] = computeH(x1, x2);
[A, affine_inlier_num, affine_inlier_idx] = computeA(x1, x2);
x2_a = x1(affine_inlier_idx,:) * A;
x2_h = x1(homography_inlier_idx,:) * H;
adu = x2_a(:,1) ./ x2_a(:,3) - x2(affine_inlier_idx,1) ./ x2(affine_inlier_idx,3);
adv = x2_a(:,2) ./ x2_a(:,3) - x2(affine_inlier_idx,2) ./ x2(affine_inlier_idx,3);
affine_error = sum(adu .* adu + adv .* adv) ./ affine_inlier_num;
hdu = x2_h(:,1) ./ x2_h(:,3) - x2(homography_inlier_idx,1) ./ x2(homography_inlier_idx,3);
hdv = x2_h(:,2) ./ x2_h(:,3) - x2(homography_inlier_idx,2) ./ x2(homography_inlier_idx,3);
homo_error = sum(hdu .* hdu + hdv .* hdv) ./ homography_inlier_num;

%% Show inlier matches
im = cat(2, im1, im2);
figure; imshow(im); hold on; title('Inlier matches by homography');
cmaps = hsv(homography_inlier_num);
for i = 1 : homography_inlier_num
    lr = row1(im1feature_idx(homography_inlier_idx(i)));
    lc = col1(im1feature_idx(homography_inlier_idx(i)));

    rr = row2(im2feature_idx(homography_inlier_idx(i)));
    rc = col2(im2feature_idx(homography_inlier_idx(i)));

    r = [lr - radius rr - radius];
    c = [lc - radius rc - radius + width1];
    plot(c, r, 'Color', cmaps(i,:));
end
figure; imshow(im); hold on; title('Inlier matches by affine transformation');
cmaps = hsv(affine_inlier_num);
for i = 1 : affine_inlier_num
    lr = row1(im1feature_idx(affine_inlier_idx(i)));
    lc = col1(im1feature_idx(affine_inlier_idx(i)));

    rr = row2(im2feature_idx(affine_inlier_idx(i)));
    rc = col2(im2feature_idx(affine_inlier_idx(i)));

    r = [lr - radius rr - radius];
    c = [lc - radius rc - radius + width1];
    plot(c, r, 'Color', cmaps(i,:));
end

%% Warp images
hform = maketform('projective', H);
im1h = imtransform(im1, hform);
figure, imshow(im1h);title('Warp by homography');

aform = maketform('affine', A);
im1a = imtransform(im1, aform);
figure, imshow(im1a);title('Warp by affine transformation');
%% Composite images
imout_h = image_composite(im1, im2, H);
figure, imshow(imout_h);title('Alignment by homography');

imout_a = image_composite(im1, im2, A);
figure, imshow(imout_a);title('Alignment by affine transformation');