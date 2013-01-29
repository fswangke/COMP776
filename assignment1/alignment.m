% Example script for running image alignment
%
% Ke Wang (kewang@cs.unc.edu)

%% Clean workspace
close all
clear all

%% Set variables
datapath = '../data';
outputpath = '../output';

%% Align images by NCC
imfiles = dir(fullfile(datapath, '*.jpg'));
offsetfile = fullfile(outputpath, 'ncc.txt');
f_outputlog = fopen(offsetfile,'w');
for i = 1 : length(imfiles)
    fprintf('Processing image %s\n', imfiles(i).name);
    tstart = tic;
    [colorim, offsetR, offsetB] = colorize_ncc(fullfile(datapath, imfiles(i).name));
    telapsed = toc(tstart);
    [l, r, t, b] = crop(colorim);
    enhancedim = cat(3, imadjust(colorim(t:b, l:r, 1)), ...
        imadjust(colorim(t:b, l:r, 2)), ...
        imadjust(colorim(t:b, l:r, 3)));
    fprintf(f_outputlog, 'File: %s Red offset (%2d, %2d) Green offset (%2d, %2d) ', imfiles(i).name, offsetR(1), offsetR(2), offsetB(1), offsetB(2));
    fprintf(f_outputlog, 'Boundary (%d, %d, %d, %d) ', l, r, t, b);
    fprintf(f_outputlog, 'Processing time %f\n', telapsed);
    [path, name, ext] = fileparts(imfiles(i).name);
    out_file_name = fullfile(outputpath, ['color-ncc-', name, '.png']);
    out_crop_file_name = fullfile(outputpath, ['color-croped-ncc-', name, '.png']);
    out_enhanced_file_name = fullfile(outputpath, ['color-enhanced-ncc-', name, '.png']);
    imwrite(colorim, out_file_name);
    imwrite(colorim(t:b, l:r, :), out_crop_file_name);
    imwrite(enhancedim, out_enhanced_file_name);
end
fclose(f_outputlog);

%% Align images by SSD
offsetfile = fullfile(outputpath, 'ssd.txt');
f_outputlog = fopen(offsetfile,'w');
for i = 1 : length(imfiles)
    fprintf('Processing image %s\n', imfiles(i).name);
    tstart = tic;
    [colorim, offsetR, offsetB] = colorize_ssd(fullfile(datapath, imfiles(i).name));
    telapsed = toc(tstart);
    [l, r, t, b] = crop(colorim);
    enhancedim = cat(3, imadjust(colorim(t:b, l:r, 1)), ...
        imadjust(colorim(t:b, l:r, 2)), ...
        imadjust(colorim(t:b, l:r, 3)));
    fprintf(f_outputlog, 'File: %s Red offset (%2d, %2d) Green offset (%2d, %2d) ', imfiles(i).name, offsetR(1), offsetR(2), offsetB(1), offsetB(2));
    fprintf(f_outputlog, 'Boundary (%d, %d, %d, %d) ', l, r, t, b);
    fprintf(f_outputlog, 'Processing time %f\n', telapsed);
    [path, name, ext] = fileparts(imfiles(i).name);
    out_file_name = fullfile(outputpath, ['color-ssd-', name, '.png']);
    out_crop_file_name = fullfile(outputpath, ['color-croped-ssd-', name, '.png']);
    out_enhanced_file_name = fullfile(outputpath, ['color-enhanced-ssd-', name, '.png']);
    imwrite(colorim, out_file_name);
    imwrite(colorim(t:b, l:r, :), out_crop_file_name);
    imwrite(enhancedim, out_enhanced_file_name);
end
fclose(f_outputlog);