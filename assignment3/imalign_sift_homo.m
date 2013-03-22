function mosaic = imalign_sift_homo(im1, im2)
im1 = im2single(im1);
im2 = im2single(im2);

if size(im1, 3) > 1, im1gray = rgb2gray(im1); else im1gray = im1; end
if size(im2, 3) > 1, im2gray = rgb2gray(im2); else im2gray = im2; end

%% SIFT matches
[f1, d1] = vl_sift(im1gray);
[f2, d2] = vl_sift(im2gray);

[matches, ~] = vl_ubcmatch(d1, d2);

x1 = f1(1:2, matches(1,:)); x1(3,:) = 1;
x2 = f2(1:2, matches(2,:)); x2(3,:) = 1;
x1 = x1';
x2 = x2';

%% Estimate transformation
[H, ~, ~] = computeH(x1, x2);

%% Composite images
mosaic = image_composite(im1, im2, H);
end