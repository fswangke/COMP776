% non-incremental way of stitching
close all
clear all
clc
%% Translation Set
datapath = '../../data/AlignmentTranslationSet';
imfiles = dir(fullfile(datapath, '*.bmp'));
imnums = length(imfiles);
images = cell(imnums,1);
for i = 1 : imnums
    images{i} = imread(fullfile(datapath, imfiles(i).name));
end

affine_trans = imalign_sequence(images, 'affine');figure,imshow(affine_trans);title('affine translation');
homo_trans = imalign_sequence(images, 'homography');figure,imshow(homo_trans);title('homo translation');
sift_trans = imalign_sequence(images, 'sift');figure,imshow(sift_trans);title('sift translation');

%% Rotation Set
datapath = '../../data/AlignmentRotationSet';
imfiles = dir(fullfile(datapath, '*.bmp'));
imnums = length(imfiles);
images = cell(imnums,1);
for i = 1 : imnums
    images{i} = imread(fullfile(datapath, imfiles(i).name));
end

affine_rotation = imalign_sequence(images, 'affine');figure,imshow(affine_rotation);title('affine rotation');
homo_rotation = imalign_sequence(images, 'homography');figure,imshow(homo_rotation);title('homo rotation');
sift_rotation = imalign_sequence(images, 'sift');figure,imshow(sift_rotation);title('sift rotation');

%% Loop set
datapath = '../../data/AlignmentLoop';
imfiles = dir(fullfile(datapath, '*.bmp'));
imnums = length(imfiles);
images = cell(imnums,1);
for i = 1 : imnums
    images{i} = imread(fullfile(datapath, imfiles(i).name));
end

affine_loop = imalign_sequence(images, 'affine');figure,imshow(affine_loop);title('affine rotation');
homo_loop = imalign_sequence(images, 'homography');figure,imshow(homo_loop);title('homo rotation');
sift_loop = imalign_sequence(images, 'sift');figure,imshow(sift_loop);title('sift rotation');
