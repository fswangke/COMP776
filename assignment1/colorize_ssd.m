%COLORIZE_SSD Colorize Sergei Mikhailovich Prokudin-Gorskii pictures.
%   [colorim, offsetR, offsetB] = colorize_ssd(imname) takes accepts 
%   negative plate file name and returns aligned color images files. Alignment 
%   is done with SSD distance metric.
%
%   Ke Wang (kewang@cs.unc.edu)
function [colorim, offsetR, offsetB] = colorize_ssd(imname)
    %% Read in image and seperate into three channels
    % read in the image
    fullim = imread(imname);
    fullim = im2double(fullim);

    % compute the height of each part (just 1/3 of total)
    height = floor(size(fullim,1)/3);
    width = size(fullim, 2);
    % separate color channels
    B = fullim(1:height,:);
    G = fullim(height+1:height*2,:);
    R = fullim(height*2+1:height*3,:);

    %% Use sub images for alignment
    cut_ratio = 0.1;
    cut_height = floor(cut_ratio * height);
    cut_width = floor(cut_ratio * width);
    subR = R(1 + cut_height : height - cut_height, 1 + cut_width : width - cut_width);
    subG = G(1 + cut_height : height - cut_height, 1 + cut_width : width - cut_width);
    subB = B(1 + cut_height : height - cut_height, 1 + cut_width : width - cut_width);

    %% Align images
    offsetR = align_ssd(subR, subG);
    offsetB = align_ssd(subB, subG);
    aR = circshift(R, offsetR);
    aB = circshift(B, offsetB);

    %% Output
    colorim = cat(3, aR, G, aB);
end