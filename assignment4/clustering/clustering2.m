clear all;
close all;
clc;

disp('reading in images');
datapath = '../../../data/cluster';
% datapath = '../../data/cluster_extra';
im_names = dir(fullfile(datapath, '*.png'));
n_imgs = length(im_names);
images = cell(n_imgs, 1);
n_bins = 128;
hists  = zeros(n_imgs, n_bins * 3);

filenames = cell(n_imgs, 1);
for i = 1 : n_imgs
    disp(i);
    images{i} = imresize(im2double(imread(fullfile(datapath, im_names(i).name))), [512, NaN]);
    hists(i,:) = color_hist(images{i}, n_bins);
    filenames{i} = im_names(i).name;
end
params.dictionarySize = 400;
pyramid = BuildPyramid(filenames, datapath, datapath, params, 1);

for i = 1 : n_imgs
    pyramid(i,:) = pyramid(i,:) ./ norm(pyramid(i,:));
end

[height, width, ~] = size(images{1});


%% clustering
disp('mean-shift clustering');
close all;
% tic; label = ms_clustering([pyramid hists], 0.70); toc;
tic; label = ms_clustering([pyramid hists], 0.70); toc;

cluster_nums = numel(unique(label));
for i = 1 : cluster_nums
    current_cluster_idx = find(label == i);
    current_cluster_img = zeros(200, 300, 3, numel(current_cluster_idx));
    for j = 1 : numel(current_cluster_idx)
        current_cluster_img(:,:,:,j) = imresize(im2double(images{current_cluster_idx(j)}), [200, 300]);
    end
    figure, montage(current_cluster_img);title(sprintf('mean shift cluster %d\n', i));
end