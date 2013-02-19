function [im_distort] = distort(img, K1)
    if K1 > 0
        im_distort = barrel_distort(img, K1);
    elseif K1 < 0
        im_distort = pincushion_distort(img, K1);
    else
        im_distort = img;
    end
end

function [im_distort] = barrel_distort(img, K1)
    [height, width, ~] = size(img);
    S = max(height, width);
    %-1 account for pincushion
    % 1 account for barrel
    im_distort = zeros(height, width, 3);

    [Vu, Uu] = meshgrid(1:width, 1:height);
    Uu = (Uu .* 2 - height) ./ S;
    Vu = (Vu .* 2 - width ) ./ S;

    R2 = Uu.^2 + Vu.^2;
    coef = ( 1 + K1 .* R2 );

    Ud = Uu ./ coef;
    Vd = Vu ./ coef;

    Ud = round( (Ud .* S + height) / 2);
    Vd = round( (Vd .* S + width ) / 2);
    
    for i = 1 : height
        for j = 1 : width
            x = Ud(i, j);
            y = Vd(i, j);
            im_distort(x,y,:) = img(i,j,:);
        end
    end
end

function [im_distort] = pincushion_distort(img, K1)
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
            im_distort(i,j,:) = img(x,y,:);
        end
    end
end
