% Example script for running image demosaic
%
% Ke Wang (kewang@cs.unc.edu)

%% Clean workspace
close all
clear all

%% Read in images
datapath = '../';
imname = 'crayons_mosaic.bmp';
imfile = imread(fullfile(datapath, imname));
imfile = im2double(imfile);
colorname = 'crayons.jpg';
colorim = imread(fullfile(datapath, colorname));
colorim = im2double(colorim);

%% Demosaic
color = demosaicing(imfile);
color2 = demosaicing_freeman(imfile);
figure,imshow(color),title('Linear interpolation');
figure,imshow(color2),title('Freeman method');

%% Compare results
err = 0;
err2 = 0;
for i = 1 : 3
    err = err + (colorim(:,:,i) - color(:,:,i)) .^ 2;
    err2 = err2 + (colorim(:,:,i) - color2(:,:,i)) .^ 2;
end

figure,imagesc(err);
title('Squared difference between original image and linear interpolation');
colorbar;axis equal;
figure,imagesc(err2);
title('Squared difference between original image and Freeman method');
colorbar;axis equal;

%% Compute per-pixel error
[max_err, max_err_ind] = max(err(:));
[max_err_row, max_err_col] = ind2sub(size(err), max_err_ind);

[max_err2, max_err_ind2] = max(err2(:));
[max_err_row2, max_err_col2] = ind2sub(size(err2), max_err_ind2);

mean_err = mean(err(:));
mean_err2 = mean(err2(:));

fprintf('Maximum per-pixel error for linear interpolation is %f at pixel (%d, %d).\n',...
    max_err, max_err_row, max_err_col);
fprintf('Average per-pixel error for linear interpolation is %f.\n', mean_err);
fprintf('Maximum per-pixel error for Freeman method is %f at pixel (%d, %d).\n',...
    max_err2, max_err_row2, max_err_col2);
fprintf('Average per-pixel error for Freeman method is %f.\n', mean_err2);

%% Show close-up 
radius = 20;
close_up = colorim(max_err_row - radius : max_err_row + radius, ...
    max_err_col - radius : max_err_col + radius, :);
close_up_linear = color(max_err_row - radius : max_err_row + radius, ...
    max_err_col - radius : max_err_col + radius, :);
close_up_freeman = color2(max_err_row - radius : max_err_row + radius, ...
    max_err_col - radius : max_err_col + radius, :);

figure;
subplot(1, 2, 1);
imshow(close_up);
title('Close-up of original color image');
subplot(1, 2, 2);
imshow(close_up_linear);
title('Close-up of linear intepolation');

figure;
subplot(1, 2, 1);
imshow(close_up);
title('Close-up of original color image');
subplot(1, 2, 2);
imshow(close_up_freeman);
title('Close-up of freeman method');