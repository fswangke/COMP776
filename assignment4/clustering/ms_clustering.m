function [label] = ms_clustering(data, h2)
    [n_data, n_dims] = size(data);
    converage_point = data;
    % h2 = 0.32; gist & hists
    % h2 = 0.55; % hists
    tol = 1e-7;
    DBG = 0;
    
    for i = 1 : n_data
        shift = zeros(1, n_dims) + realmax;
        iter = 0;
        while norm(shift) > tol
            % fprintf('%d iteration of mean shifting of %d data\n', iter, i);
            iter = iter + 1;
            dist = dist2(data, converage_point(i,:));
            neighbor_idx = find(dist < h2);
            if DBG
                figure(123);
                clf(123);
                hold on;
                scatter(data(dist >= h2, 1), data(dist >= h2, 2));drawnow;
                scatter(data(neighbor_idx, 1), data(neighbor_idx, 2));drawnow;
                axis equal;
            end
            numerator = 0;
            denominator = 0;
            for j = 1 : length(neighbor_idx)
                %kernel = exp(-norm(converage_point(i,:) - data(neighbor_idx(j),:)).^2./h2);
                kernel = hist_isect_c(converage_point(i,:), data(neighbor_idx(j),:));
                numerator = numerator + data(neighbor_idx(j),:) * kernel;
                denominator = denominator + kernel;
            end
            shift = converage_point(i,:) - numerator ./ denominator;
            converage_point(i,:) = numerator ./ denominator;
            % pause(0.05);
        end
        % fprintf('converage mode for point %d is (%f, %f)\n', i, converage_point(i,1), converage_point(i,2));
    end
    
    % figure, scatter(converage_point(:,1), converage_point(:,2)),title('modes'),axis([-6 6 -6 6]);
    dd = dist2(converage_point, converage_point);
    figure, imagesc(dd), title('Distance matrix');
    % agglomerative cluster converging points
    label = zeros(1, n_data);
    n_cluster = 1;
    label(1) = 1;
    for i = 2 : n_data
        MERGE = 0;
        for cluster_idx = 1 : n_cluster
            dist = dist2(converage_point(label == cluster_idx, :), converage_point(i, :));
            if mean(dist) < h2 %* 1.50
                label(i) = cluster_idx;
                MERGE = 1;
                break;
            end
        end
        if MERGE == 0
            n_cluster = n_cluster + 1;
            label(i) = n_cluster;
        end
    end
end