clear all;
close all;
clc;

datapath = '../../data/castle_dense/';
im_names = dir(fullfile(datapath, '*.png'));

segmentation1 = grabcut(imresize(im2double(imread(fullfile(datapath, im_names(19).name))),0.4));