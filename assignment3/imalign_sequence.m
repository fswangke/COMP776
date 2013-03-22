function mosaic = imalign_sequence(images, method)
    switch method
        case 'affine'
            fcn = @imalign_affine;
        case 'homography'
            fcn = @imalign_homo;
        case 'sift'
            fcn = @imalign_sift_homo;
        otherwise
            fcn = @imalign_homo;
    end
    while length(images) > 1
        im_left_num = length(images);
        j = 1;
        for i = 1 : 2 : im_left_num
            if i < im_left_num
                new_images{j} = fcn(images{i}, images{i+1});
            else
                new_images{j} = images{i};
            end
            j = j + 1;
        end
        images = new_images;new_images={};
        fprintf('%d left\n', length(images));
    end
    mosaic = images{1};
end