%PYRAMID_ALIGN_SSD Align high resolution color channels with Sum of Squared
%   Difference metric.
%
%   Ke Wang (kewang@cs.unc.edu)
function [offset] = pyramid_align_ssd(template, A) 
    if size(template, 1) > 128 
        I1 = impyramid(template, 'reduce'); 
        I2 = impyramid(A, 'reduce'); 
        coarse_offset = pyramid_align_ssd(I1, I2); 
        offset = refine_align_ssd(template, A, coarse_offset * 2); 
    else 
        offset = align_ncc(template, A); 
    end 
end 

%REFINE_ALIGN_SSD refines a coarse offset offered by a lower level image
%   pyramid by searching in a small window
function [offset] = refine_align_ssd(template, A, coarse_offset)
    radius = 5;
    best_ssd = realmax;

    for r = coarse_offset(1) - radius : coarse_offset(1) + radius
        for c = coarse_offset(2) - radius : coarse_offset(2) + radius
            b = circshift(template, [r, c]);
            ssd = sum((A(:)-b(:)).^2);
            if ssd < best_ssd
                best_ssd = ssd;
                offset = [r, c];
            end
        end
    end
end