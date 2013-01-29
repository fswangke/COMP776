%CROP automatically crops the aligned color images.
%   [left, right, top, bottom] = corp(input) takes the input color images
%   and removes the white margin, black image borders and color artifacts
%   along the image borders, and returns the bounding box.
%
%   Ke Wang (kewang@cs.unc.edu)
function [left, right, top, bottom] = crop(input)
    crop_ratio = 0.10;
    black_threshold = 0.95;
    white_threshold = 0.95;
    band_threshold = 0.85;
    [height, width, ~] = size(input);
    left = 1;
    right = width;
    top = 1;
    bottom = height;
    
    % detect left boarder
    for left_col = 1 : floor(width * crop_ratio)
        if count_black(rgb2gray(input(:,left_col,:))) > black_threshold
            left = left_col;
            continue;
        end
        
        if count_white(rgb2gray(input(:,left_col,:))) > white_threshold
            left = left_col;
            continue;
        end
        
        if is_color_border(input(:,left_col,:)) < band_threshold
            left = left_col;
            continue;
        end
    end
    
    % detect right boarder
    for right_col = width : -1 : width - floor(width * crop_ratio)
        if count_black(rgb2gray(input(:,right_col,:))) > black_threshold
            right = right_col;
            continue;
        end
        
        if count_white(rgb2gray(input(:,right_col,:))) > white_threshold
            right = right_col;
            continue;
        end
        
        if is_color_border(input(:,right_col,:)) < band_threshold
            right = right_col;
            continue;
        end
    end
    
    % detect top boarder
    for top_row = 1 : floor(height * crop_ratio)
        if count_black(rgb2gray(input(top_row,:,:))) > black_threshold
            top = top_row;
            continue;
        end
        
        if count_white(rgb2gray(input(top_row,:,:))) > white_threshold
            top = top_row;
            continue;
        end
        
        if is_color_border(input(top_row,:,:)) < band_threshold
            top = top_row;
            continue;
        end
    end
    
    % detech bottom boarder
    for bottom_row = height : -1 : height - floor(height * crop_ratio)
        if count_black(rgb2gray(input(bottom_row,:,:))) > black_threshold
            bottom = bottom_row;
            continue;
        end
        
        if count_white(rgb2gray(input(bottom_row,:,:))) > white_threshold
            bottom = bottom_row;
            continue;
        end
        
        if is_color_border(input(bottom_row,:,:)) < band_threshold
            bottom = bottom_row;
            continue;
        end
    end
end

%COUNT_BLACK(LINE) takes a pixel vector and count the black pixel ratio
function black_ratio = count_black(line)
    black_pixels = (line <= 0.1);
    black_ratio = sum(black_pixels(:)) / ( length(line) );
end

%COUNT_WHITE(LINE) takes a pixel vector and count the white pixel ratio
function white_ratio = count_white(line)
    white_pixels = (line == 1);
    white_ratio = sum(white_pixels(:)) / ( length(line) );
end

%IS_COLOR_BORDER(LINE) takes a pixel vector and computed the NCC among
%   color channels to determine the likelihood of such vector being a color
%   artifact line.
function border_prob = is_color_border(line)
    cc = zeros(3, 1);
    r = line(:,:,1);
    g = line(:,:,2);
    b = line(:,:,3);
    cc(1) = dot(r,g)/norm(r)/norm(g);%R-G NCC
    cc(2) = dot(r,b)/norm(r)/norm(b);%R-B NCC
    cc(3) = dot(g,b)/norm(g)/norm(b);%G-B NCC
    border_prob = mean(abs(cc));
end