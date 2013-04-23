function [cost] = img_ssd(img1, img2)
    [height, width, channel] = size(img1);
    [~, ~, channel2] = size(img2);
    if (channel ~= channel2)
        error('Color channel mismatch');
    end
    if (channel == 1)
        cost = (img1 - img2) .^ 2;
    end
    if (channel == 3)
        cost = abs(img1(:,:,1) - img2(:,:,1)) .^ 2 + ...
            abs(img1(:,:,2) - img2(:,:,2)) .^ 2 + ...
            abs(img1(:,:,3) - img2(:,:,3)) .^ 2;
    end
    h = ones(15);
    cost = imfilter(cost, h);
end