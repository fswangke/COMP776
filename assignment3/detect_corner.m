function [cim, r, c] = detect_corner(Ix, Iy, sigma, num, radius)
    h = fspecial('gaussian', max(1, fix(6 * sigma)), sigma);
    Ix2 = imfilter(Ix .^ 2, h, 'replicate', 'same');
    Iy2 = imfilter(Iy .^ 2, h, 'replicate', 'same');
    Ixy = imfilter(Ix .* Iy, h, 'replicate', 'same');

    k = 0.04;
    cim = (Ix2 .* Iy2 - Ixy .^ 2) - k * ( Ix2 + Iy2 ) .^ 2;

    sze = 2 * radius + 1;
    mx = ordfilt2(cim, sze ^ 2, ones(sze));
    cim(cim ~= mx) = 0;

    [~, idx] = sort(cim(:), 'descend');
    num = min(num, floor(0.50 * length(find(cim ~= 0))));
    [r, c] = ind2sub(size(cim), idx(1:num));
end