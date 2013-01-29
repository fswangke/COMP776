%ALIGN_SSD Align color channels with Sum of Squared Differences metric.
%   [offset] = align_ssd(template, A) returns the optimal offset when
%   aligning template to A
%
%   Ke Wang (kewang@cs.unc.edu)
function [offset] = align_ssd(template, A)

    % automatically find searching window radius
    radius = floor(0.06 * min(size(A,1), size(A,2)));
    ssd = zeros( 2 * radius + 1 );
    
    % calculate SSD
    for r = -radius : radius
        for c = -radius : radius
            b = circshift(template, [r, c]);
            ssd(r + radius + 1,c + radius + 1) = sum((A(:)-b(:)).^2);
        end
    end
    
    % find min SSD and related offset
    [~, ind] = min(ssd(:));
    [rpeak, cpeak] = ind2sub(size(ssd), ind);
    offset = [rpeak - radius - 1 cpeak - radius - 1];
end