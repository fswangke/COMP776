% Sample use of PointCloud2Image(...)
% 
% The following variables are contained in the provided data file:
%       BackgroundPointCloudRGB,ForegroundPointCloudRGB,K,crop_region,filter_size
% None of these variables needs to be modified


clc
clear all
% load variables: BackgroundPointCloudRGB,ForegroundPointCloudRGB,K,crop_region,filter_size)
load data.mat

data3DC = {BackgroundPointCloudRGB,ForegroundPointCloudRGB};
R       = eye(3);
move    = [0 0 -0.25]';



for step=0:8
    tic
    fname       = sprintf('SampleOutput%03d.jpg',step);
    display(sprintf('\nGenerating %s',fname));
    t           = step * move;
    M           = K*[R t];
    im          = PointCloud2Image(M,data3DC,crop_region,filter_size);
    imwrite(im,fname);
    toc    
end
