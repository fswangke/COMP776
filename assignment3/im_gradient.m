function [Ix, Iy] = im_gradient(im)
    if size(im,3) > 1, im = rgb2gray(im); end
    dx = [-1 0 1; -1 0 1; -1 0 1];
    dy = dx';
    
    Ix = imfilter(im, dx, 'replicate', 'same');
    Iy = imfilter(im, dy, 'replicate', 'same');
end