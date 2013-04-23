function [label, GMM] = color_quant(pixels, K)
    label = ones(size(pixels, 1), 1);
    
    N1 = size(pixels, 1);
    
    cluster(1).cov = cov(pixels);
    cluster(1).mean = mean(pixels);
    cluster(1).numPoints = N1;
    cluster(1).points = 1:N1;
    
    [V, D] = eig(cluster(1).cov);
    eigenvectors = V(:,1);
    eigenvalues = abs(D(1,1));
    for i = 2 : K
        if(max(eigenvalues) == -1)
            break;
        end
        [~,idx] = max(eigenvalues(:));
        en = eigenvectors(:,idx);
        points = cluster(idx).points;
        left_pts = points(pixels(points,:) * en <= cluster(idx).mean * en);
        right_pts = points(pixels(points,:) * en > cluster(idx).mean * en);
        if (~isempty(left_pts) && ~isempty(right_pts))
            Nl = numel(left_pts);

            cluster_l.cov = cov(pixels(left_pts, :));
            cluster_l.mean = mean(pixels(left_pts, :));
            cluster_l.numPoints = Nl;
            cluster_l.points = left_pts;

            Nr = numel(right_pts);

            cluster_r.cov = cov(pixels(right_pts, :));
            cluster_r.mean = mean(pixels(right_pts, :));
            cluster_r.numPoints = Nr;
            cluster_r.points = right_pts;

            cluster(idx) = [];
            cluster = [cluster;cluster_l;cluster_r];
            [Vl, Dl] = eig(cluster_l.cov);
            [Vr, Dr] = eig(cluster_r.cov);
            eigenvalues(idx) = [];
            eigenvectors(:,idx) = [];
            eigenvalues = [eigenvalues abs(Dl(1,1)) abs(Dr(1,1))];
            eigenvectors = [eigenvectors Vl(:,1) Vr(:,1)];
        else
            eigenvalues(idx) = -1;
            i = i - 1;
        end
    end
    
    for i = 1 : K
        GMM(i).cov = cluster(i).cov;
        GMM(i).mean = cluster(i).mean;
        GMM(i).pi = cluster(i).numPoints / size(pixels, 1);
        label(cluster(i).points) = i;
    end
end