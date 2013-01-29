%ALIGN_NCC Align color channels with Normalized Cross Correlation metric.
%   [offset] = align_ncc(template, A) retures the optimal offset when
%   aligning template to A.
%
%   Ke Wang (kewang@cs.unc.edu)
function [offset] = align_ncc(template, A)
    %automatically find searching window radius
    radius = floor(0.06 * min(size(A,1), size(A,2)));
    ncc = zeros( 2 * radius + 1 );
    
    % calculate NCC
    for r = -radius : radius
        for c = -radius : radius
            b = circshift(template, [r, c]);
            ncc(r + radius + 1,c + radius + 1) = dot(A(:),b(:))/norm(A(:))/norm(b(:));
        end
    end
    
    % find max NCC and related offset
    [~, ind] = max(ncc(:));
    [rpeak, cpeak] = ind2sub(size(ncc), ind);
    offset = [rpeak - radius - 1 cpeak - radius - 1];
end