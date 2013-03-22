function [best_H, best_homography_inlier_num, best_homography_inlier_idx] = computeH(x1, x2)
numMatches = size(x1, 1);
inlier_dist = 36;
best_H = zeros(3);
best_homography_inlier_num = 0;
best_homography_mean_residual = realmax;
best_homography_inlier_idx = [];
for iter = 1 : 200
    % Draw points uniformly at random
    pts_idx = randperm(numMatches);
    
    % Fit model to these points
    A = [];
    X1 = x1(pts_idx(1:4),:);
    X2 = x2(pts_idx(1:4),:);
    
    for i = 1 : 4
        Ai = [ 0, 0, 0, -X1(i,:), X2(i,2) * X1(i,:);
            X1(i,:), 0, 0, 0, -X2(i,1) * X1(i,:)];
        A = [A; Ai];
    end
    [~,~,V] = svd(A);
    current_H = reshape(V(:,9), 3, 3);
    current_H = current_H ./ current_H(3,3);
    
    % Find inliers to this model: distance from the model is less than
    % threshold
    x2_ = x1 * current_H;
    du = x2_(:,1) ./ x2_(:,3) - x2(:,1) ./ x2(:,3);
    dv = x2_(:,2) ./ x2_(:,3) - x2(:,2) ./ x2(:,3);
    homography_error = du .* du + dv .* dv;
    inlier_idx = (homography_error < inlier_dist);
    current_homography_inlier_num = sum(inlier_idx);
    current_homography_mean_residual = mean(homography_error);
    %fprintf('RANSAC for Homography: Iteration %d: Inlier Num: %d, Average residual %f\n', iter, current_homography_inlier_num, current_homography_mean_residual);
    
    inlier_idx = find(homography_error < inlier_dist);
    
    % If more than d inliers, accept model and refit
    if current_homography_inlier_num == best_homography_inlier_num && current_homography_mean_residual < best_homography_mean_residual
        best_homography_inlier_num = current_homography_inlier_num;
        best_homography_inlier_idx = inlier_idx;
        %refit model
        A = [];
        X1 = x1(inlier_idx,:);
        X2 = x2(inlier_idx,:);
        for i = 1 : length(inlier_idx)
            Ai = [ 0, 0, 0, -X1(i,:), X2(i,2) * X1(i,:);
                X1(i,:), 0, 0, 0, -X2(i,1) * X1(i,:)];
            A = [A; Ai];
        end
        [~,~,V] = svd(A);
        best_H = reshape(V(:,9), 3, 3);
        best_H = best_H ./ best_H(3,3);
        best_homography_mean_residual = current_homography_mean_residual;
    end
    if current_homography_inlier_num > best_homography_inlier_num
        best_homography_inlier_num = current_homography_inlier_num;
        best_homography_inlier_idx = inlier_idx;
        %refit model
        A = [];
        X1 = x1(inlier_idx,:);
        X2 = x2(inlier_idx,:);
        for i = 1 : length(inlier_idx)
            Ai = [ 0, 0, 0, -X1(i,:), X2(i,2) * X1(i,:);
                X1(i,:), 0, 0, 0, -X2(i,1) * X1(i,:)];
            A = [A; Ai];
        end
        [~,~,V] = svd(A);
        best_H = reshape(V(:,9), 3, 3);
        best_H = best_H ./ best_H(3,3);
        best_homography_mean_residual = current_homography_mean_residual;
    end
end

% --------------------------------------------------------------------
%                                                  Optional refinement
% --------------------------------------------------------------------

    function err = residual(H)
        x2_ = x1 * current_H;
        du = x2_(:,1) ./ x2_(:,3) - x2(:,1) ./ x2(:,3);
        dv = x2_(:,2) ./ x2_(:,3) - x2(:,2) ./ x2(:,3);
        
        u = H(1) * x1(best_homography_inlier_idx, 1) + H(4) * x1(best_homography_inlier_idx,2) + H(7) ;
        v = H(2) * x1(best_homography_inlier_idx, 1) + H(5) * x1(best_homography_inlier_idx,2) + H(8) ;
        d = H(3) * x1(best_homography_inlier_idx, 1) + H(6) * x1(best_homography_inlier_idx,2) + 1 ;
        du = x2(best_homography_inlier_idx,1) - u ./ d ;
        dv = x2(best_homography_inlier_idx,2) - v ./ d ;
        err = sum(du.*du + dv.*dv) ;
    end

if exist('fminsearch') == 2
    best_H = best_H / best_H(3,3) ;
    best_H = best_H';
    opts = optimset('Display', 'none', 'TolFun', 1e-8, 'TolX', 1e-8) ;
    best_H(1:8) = fminsearch(@residual, best_H(1:8)', opts) ;
    best_H = best_H';
else
    warning('Refinement disabled as fminsearch was not found.') ;
end
end


