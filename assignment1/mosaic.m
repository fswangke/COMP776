%MOSAIC takes a color image and returns a mosaic image sampled by standard
%   bayer pattern
%
%   Ke Wang (kewang@cs.unc.edu)
function bayer = mosaic(color)
    bayer = zeros(size(color, 1), size(color, 2), 'uint8');
    bayer(1:2:end, 1:2:end) = color(1:2:end, 1:2:end, 1);%R
    bayer(2:2:end, 2:2:end) = color(2:2:end, 2:2:end, 3);%B
    bayer(1:2:end, 2:2:end) = color(1:2:end, 2:2:end, 2);%G
    bayer(2:2:end, 1:2:end) = color(2:2:end, 1:2:end, 2);%G
end