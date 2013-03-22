% script for feature detection
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
% choose strongest corners
sigma = 0.5;
radius = 5;
num = 1000;
[im1dx, im1dy] = im_gradient(im1gray);
[im2dx, im2dy] = im_gradient(im2gray);
[~, row1, col1] = detect_corner_naive(im1dx, im1dy, sigma, num, radius);
[~, row2, col2] = detect_corner_naive(im2dx, im2dy, sigma, num, radius);

% plot detected corner on original images
h1 = figure;
imshow(im1); hold on;
plot(col1, row1, 'y+');
h2 = figure;
imshow(im2); hold on;
plot(col2, row2, 'y+');

% choose by non-maxima suppression
sigma = 0.8;
radius = 5;
num = 1000;
[im1dx, im1dy] = im_gradient(im1gray);
[im2dx, im2dy] = im_gradient(im2gray);
[~, row1, col1] = detect_corner(im1dx, im1dy, sigma, num, radius);
[~, row2, col2] = detect_corner(im2dx, im2dy, sigma, num, radius);

% plot detected corner on original images
h1 = figure;
imshow(im1); hold on;
plot(col1, row1, 'y+');
h2 = figure;
imshow(im2); hold on;
plot(col2, row2, 'y+');

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
% Compute feature matches
NCC = ncc2(im1features, im2features);
SSD = ssd2(im1features, im2features);

%  select top matches
numMatches = 20;
[~,ncc_idx] = sort(NCC(:), 'descend');
[~,ssd_idx] = sort(SSD(:), 'ascend');
[im1feature_ncc_idx, im2feature_ncc_idx] = ind2sub(size(NCC), ncc_idx(1:numMatches));
[im1feature_ssd_idx, im2feature_ssd_idx] = ind2sub(size(SSD), ssd_idx(1:numMatches));

%% Show matches
im = cat(2, im1, im2);
figure; imshow(im); hold on; %title('Matches detected by NCC');
cmaps = hsv(numMatches);
for i = 1 : numMatches
    lr = row1(im1feature_ncc_idx(i));
    lc = col1(im1feature_ncc_idx(i));

    rr = row2(im2feature_ncc_idx(i));
    rc = col2(im2feature_ncc_idx(i));

    r = [lr - radius rr - radius];
    c = [lc - radius rc - radius + width1];
    plot(c, r, 'Color', cmaps(i,:));
end

figure; imshow(im); hold on; %title('Matches detected by SSD');
cmaps = hsv(numMatches);
for i = 1 : numMatches
    lr = row1(im1feature_ssd_idx(i));
    lc = col1(im1feature_ssd_idx(i));

    rr = row2(im2feature_ssd_idx(i));
    rc = col2(im2feature_ssd_idx(i));

    r = [lr - radius rr - radius];
    c = [lc - radius rc - radius + width1];
    plot(c, r, 'Color', cmaps(i,:));
end