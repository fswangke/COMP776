%DEMOSAICING_FREEMAN takes a standard Bayer pattern image and returns a
%   colorized image with Freeman method
%
%   Ke Wang (kewang@cs.unc.edu)
function [output] = demosaicing_freeman(bayer)
    % Seperate color channels
    R = zeros(size(bayer));
    G = zeros(size(bayer));
    B = zeros(size(bayer));

    R(1:2:end, 1:2:end) = bayer(1:2:end, 1:2:end);
    B(2:2:end, 2:2:end) = bayer(2:2:end, 2:2:end);
    G(1:2:end, 2:2:end) = bayer(1:2:end, 2:2:end);
    G(2:2:end, 1:2:end) = bayer(2:2:end, 1:2:end);

    %Create filter kernels
    fR = [0.25, 0.5, 0.25;
        0.5, 1.0, 0.5;
        0.25, 0.5, 0.25];
    fG = [0    0.25 0
       0.25  1.0  0.25
       0     0.25 0];
    fB = [0.25, 0.5, 0.25;
        0.5, 1.0, 0.5;
        0.25, 0.5, 0.25];

    % Linear interpolate color channels
    R = imfilter(R, fR);
    G = imfilter(G, fG);
    B = imfilter(B, fB);
    
    % Refine R/B channels by Freeman method
    R = G + medfilt2(R - G);
    B = G + medfilt2(B - G);

    % Combine to get color images
    output = cat(3, R, G, B);
end