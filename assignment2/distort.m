function [im_distort] = distort(img, K1)
    [height, width, ~] = size(img);
    S = max(height, width);
    im_distort = zeros(height, width, 3);
    for i = 1 : height
        for j = 1 : width
            ud = ( 2 * i - height ) / S;
            vd = ( 2 * j - width  ) / S;
            r2 = ud^2 + vd^2;
            u  = ( 1 + K1 * r2 ) * ud;
            v  = ( 1 + K1 * r2 ) * vd;
            x  = round((u * S + height) / 2);
            y  = round((v * S + width ) / 2);
            if ( x >= 1 && x <= height && y >= 1 && y <= width)
                im_distort(i,j,:) = img(x,y,:);
            end
        end
    end
end
