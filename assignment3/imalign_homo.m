function mosaic = imalign_homo(im1, im2)
im1 = im2double(im1);
im2 = im2double(im2);

im1gray = rgb2gray(im1);
im2gray = rgb2gray(im2);

%% Detect corners
sigma = 0.5;
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

%% Estimate transformation
x1 = [col1(im1feature_idx) row1(im1feature_idx) ones(numMatches,1)];
x2 = [col2(im2feature_idx) row2(im2feature_idx) ones(numMatches,1)];

[H, ~, ~] = computeH(x1, x2);

%% Composite images
mosaic = image_composite(im1, im2, H);
end