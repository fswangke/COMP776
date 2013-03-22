function [best_A, best_affine_inlier_num, best_affine_inlier_idx] = computeA(x1, x2)
numMatches = size(x1, 1);
inlier_dist = 36;
best_A = zeros(3);
best_affine_inlier_num = 0;
best_affine_mean_residual = realmax;
best_affine_inlier_idx = [];
for iter = 1 : 200
    % Draw points uniformly at random
    pts_idx = randperm(numMatches);
    
    % Fit model to these points
    X1 = x1(pts_idx(1:4),:);
    X2 = x2(pts_idx(1:4),:);
    
    current_A = X1 \ X2;
    
    % Find inliers to this model: distance from the model is less than
    % threshold
    x2_ = x1 * current_A;
    du = x2_(:,1) ./ x2_(:,3) - x2(:,1) ./ x2(:,3);
    dv = x2_(:,2) ./ x2_(:,3) - x2(:,2) ./ x2(:,3);
    affine_error = du .* du + dv .* dv;
    inlier_idx = (affine_error < inlier_dist);
    current_affine_inlier_num = sum(inlier_idx);
    current_affine_mean_residual = mean(affine_error);
    %fprintf('RANSAC for Homography: Iteration %d: Inlier Num: %d, Average residual %f\n', iter, current_homography_inlier_num, current_homography_mean_residual);
    
    inlier_idx = find(affine_error < inlier_dist);
    
    % If more than d inliers, accept model and refit
    if current_affine_inlier_num == best_affine_inlier_num && current_affine_mean_residual < best_affine_mean_residual
        best_affine_inlier_num = current_affine_inlier_num;
        best_affine_inlier_idx = inlier_idx;
        %refit model
        X1 = x1(inlier_idx,:);
        X2 = x2(inlier_idx,:);
        best_A = X1 \ X2;
        best_affine_mean_residual = current_affine_mean_residual;
    end
    if current_affine_inlier_num > best_affine_inlier_num
        best_affine_inlier_num = current_affine_inlier_num;
        best_affine_inlier_idx = inlier_idx;
        %refit model
        X1 = x1(inlier_idx,:);
        X2 = x2(inlier_idx,:);
        best_A = X1 \ X2;
        best_affine_mean_residual = current_affine_mean_residual;
    end
end
best_A(:,3) = [0;0;1];
end
