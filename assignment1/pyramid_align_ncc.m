%PYRAMID_ALIGN_NCC Align high resolution color channels with Normalized
%   Cross Correlation
%
%   Ke Wang (kewang@cs.unc.edu)
function [offset] = pyramid_align_ncc(template, A) 
    if size(template, 1) > 128 
        I1 = impyramid(template, 'reduce'); 
        I2 = impyramid(A, 'reduce'); 
        coarse_offset = pyramid_align_ncc(I1, I2); 
        offset = refine_align_ncc(template, A, coarse_offset * 2); 
    else 
        offset = align_ncc(template, A); 
    end 
end

%REFINE_ALIGN_NCC refines a coarse offset offered by a lower level image
%   pyramid by searching in a small window
function [offset] = refine_align_ncc(template, A, coarse_offset)
    radius = 5;
    best_ncc = -realmax;

    for r = coarse_offset(1) - radius : coarse_offset(1) + radius
        for c = coarse_offset(2) - radius : coarse_offset(2) + radius
            b = circshift(template, [r, c]);
            ncc = dot(A(:),b(:))/norm(A(:))/norm(b(:));
            if ncc > best_ncc
                best_ncc = ncc;
                offset = [r, c];
            end
        end
    end
end