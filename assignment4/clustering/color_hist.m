function h = color_hist(img, n)
    if size(img, 3) ~= 3
        error('Not RGB image');
    end
    r = img(:,:,1);
    g = img(:,:,2);
    b = img(:,:,3);
    h = [hist(r(:), n) hist(g(:), n) hist(b(:), n)];
    h = h ./ norm(h);
end