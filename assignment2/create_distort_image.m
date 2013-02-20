% This script is used to create distorted images for demos.
%% Different ways to create distortions
img = imread('output033.png');
img = im2double(img);

K1 = -0.135135;
% create distortion by sample input
[height, width, ~] = size(img);
S = max(height, width);
img_d_1 = zeros(height, width, 3);

for i = 1 : height
    for j = 1 : width
        ud = ( 2 * i - height ) / S;
        vd = ( 2 * j - width  ) / S;
        r2 =  ud ^ 2 + vd ^ 2;
        u  = ( 1 + K1 * r2 ) * ud;
        v  = ( 1 + K1 * r2 ) * vd;
        x  = round((u * S + height) / 2);
        y  = round((v * S + width ) / 2);
        img_d_1(i,j,:) = img(x,y,:);
    end
end
imwrite(imresize(img_d_1, [512, NaN]), 'pincushion_sampling.png');

% create distortion by displace input
img_d_2 = zeros(height, width, 3);

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
            if ( x >= 1 && x <= height && y >= 1 && y <= width)
                img_d_2(x,y,:) = img(i,j,:);
            end
        end
    end

imwrite(imresize(img_d_2, [512, NaN]), 'pincushion_displacement.png');
%% distortion removal
img = imread('distorted050.png');
img = im2double(img);

K1 = 0.324324;
[height, width, ~] = size(img);
S = max(height, width);
img_ud = zeros(height, width, 3);
for i = 1 : height
    disp(i);
    for j = 1 : width
        ud = ( 2 * i - height ) / S;
        vd = ( 2 * j - width  ) / S;
        r2 =  ud ^ 2 + vd ^ 2;
        u  = ( 1 + K1 * r2 ) * ud;
        v  = ( 1 + K1 * r2 ) * vd;
        x  = round((u * S + height) / 2);
        y  = round((v * S + width ) / 2);
        if (x >= 1 && x <= height && y >= 1 && y <= width)
            img_ud(x,y,:) = img(i,j,:);
        end
    end
end
imwrite(imresize(img_ud, [512, NaN]), 'undistorted050.png');

%% create tangent distortion
img = imread('output033.png');
img = im2double(img);
K1 = -0.135135;
K4 = 0.05;
K5 = -0.05;
% create distortion by sample input
[height, width, ~] = size(img);
S = max(height, width);
img_d_1 = zeros(height, width, 3);

for i = 1 : height
    for j = 1 : width
        ud = ( 2 * i - height ) / S;
        vd = ( 2 * j - width  ) / S;
        r2 =  ud ^ 2 + vd ^ 2;
        u  = ( 1 + K1 * r2 ) * ud + 2 * K4 * ud * vd + 2 * K5 * (r2 + 2 * ud ^ 2);
        v  = ( 1 + K1 * r2 ) * vd + 2 * K5 * ud * vd + 2 * K4 * (r2 + 2 * vd ^ 2);
        x  = round((u * S + height) / 2);
        y  = round((v * S + width ) / 2);
        if ( x >= 1 && x <= height && y >= 1 && y <= width)
            img_d_1(i,j,:) = img(x,y,:);
        end
    end
end
imwrite(imresize(img_d_1, [512, NaN]), 'tangent_distortion.png');
