%% clear workspace
clc
clear all
close all

% load variables: BackgroundPointCloudRGB,ForegroundPointCloudRGB,K,crop_region,filter_size)
load ../data/data.mat

data3DC = {BackgroundPointCloudRGB,ForegroundPointCloudRGB};
R       = eye(3);

%% Estimate initial camera position
imgW1 = 400;
imgH1 = 640;
objW = range(ForegroundPointCloudRGB(1,:));
objH = range(ForegroundPointCloudRGB(2,:));
objD0 = mean(ForegroundPointCloudRGB(3,:));

M0 = K*[R zeros(3,1)];
foregroundObj = [ForegroundPointCloudRGB(1,:);...
    ForegroundPointCloudRGB(2,:);...
    ForegroundPointCloudRGB(3,:);...
    ones(1,size(ForegroundPointCloudRGB(1,:),2))];
foregroundImage = M0 * foregroundObj;

imgW0 = range(foregroundImage(1,:) ./ foregroundImage(3,:));
imgH0 = range(foregroundImage(2,:) ./ foregroundImage(3,:));

objD1 = objD0 * imgW0 / imgW1;
t_start = [0; 0; objD1 - objD0];
t_end = [0; 0; -3.8];
move = linspace(0, t_end(3)-t_start(3), 75);
K1 = linspace(-1, 1, 75);
move = [zeros(2, 75);move];

%% Generate image sequence and video
% create video with image sequences
outputVideo = VideoWriter('dollyzoom.avi');
outputVideo2 = VideoWriter('dollyzoom_d.avi');
outputVideo.FrameRate = 15;
outputVideo2.FrameRate = 15;
open(outputVideo);
open(outputVideo2);
fseq = fopen('cameras.txt', 'w');

% create an image sequence
for step = 1 : 75
    tic;
    fname = sprintf('output%03d.png', step);
    fprintf('\nGenerating %s', fname);
    K(1,1) = imgW1 / objW * (objD1 + move(3, step));
    K(2,2) = imgH1 / objH * (objD1 + move(3, step));
    M = K*[R t_start + move(:, step)];
    foregroundImage = M * foregroundObj;
    imgHnew = range(foregroundImage(1,:) ./ foregroundImage(3,:));
    imgWnew = range(foregroundImage(2,:) ./ foregroundImage(3,:));
    depth = t_start + move(:,step);
    fprintf(fseq, 'Depth %f, obj size: %f * %f, focal length %f, %f, K1 %f\n', depth(3), imgHnew, imgWnew, K(1,1), K(2,2), K1(step));
    im = PointCloud2Image(M, data3DC, crop_region, filter_size);
    imwrite(im, fname);
    writeVideo(outputVideo, im);
    im2 = distort(im, K1(step));
    fname2 = sprintf('distorted%03d.png', step);
    imwrite(im2, fname2);
    writeVideo(outputVideo2,im2);
    toc;
end

close(outputVideo);
close(outputVideo2);
fclose(fseq);