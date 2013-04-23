function [segmentation] = grabcut(img)
[height, width, ~] = size(img);
pixel_num = height * width;
trimap = zeros(height, width);
segmentation = zeros(height, width);

imshow(img);
rect = uint32(getrect);

% initialization
TrimapBack = 2;
TrimapFore = 1;
TrimapUkwn = 0;
trimap = trimap + TrimapBack;
trimap( rect(2) : rect(2) + rect(4), rect(1) : rect(1) + rect(3)) = TrimapUkwn;

back_idx = find(trimap == TrimapBack);
ukwn_idx = find(trimap == TrimapUkwn);

SegmentationBack = 2;
SegmentationFore = 1;
segmentation(back_idx) = SegmentationBack;
segmentation(ukwn_idx) = SegmentationFore;

pixels = [reshape(img(:,:,1), pixel_num, 1) reshape(img(:,:,2), pixel_num, 1) reshape(img(:,:,3), pixel_num, 1)];
K = 5;

% initialize foreground and background GMMs
component = zeros(height, width);
[component(ukwn_idx), fore_gmm] = color_quant(pixels(ukwn_idx, :), K);
[component(back_idx), back_gmm] = color_quant(pixels(back_idx, :), K);

% build smooth term for graph cut
pairwise = buildsmooth(pixels, height, width);

iter = 1;
num_pixel_change = rect(3) * rect(4);
while num_pixel_change > 500
    fprintf('iteration %d of optimazation\n', iter);
    assign_gmm;
    learn_gmm;
    
    
    
    
    labels = graph_cut;
    labels = reshape(labels, height, width);
    figure(25+iter);
    imshow(imfuse(img, labels));
    axis image;title(sprintf('segmentation %d', iter));drawnow;
    iter = iter + 1;
    num_pixel_change = numel(find(segmentation ~= labels));
    fprintf('%d pixels changed\n', num_pixel_change);
    segmentation = labels;
end

% user modification
user_editing;

    function assign_gmm
        fore_idx = find(trimap == TrimapUkwn & segmentation == SegmentationFore);
        if ~isempty(fore_idx)
            fore_p = zeros(K, length(fore_idx));
            for i = 1 : K
                fore_p(i,:) = mvnpdf(pixels(fore_idx, :), fore_gmm(i).mean, fore_gmm(i).cov);
            end
            [~, component(fore_idx)] = max(fore_p);
        end
        
        back_idx = find(trimap == TrimapUkwn & segmentation == SegmentationBack);
        if ~isempty(back_idx)
            back_p = zeros(K, length(back_idx));
            for i = 1 : K
                back_p(i,:) = mvnpdf(pixels(back_idx, :), back_gmm(i).mean, back_gmm(i).cov);
            end
            [~, component(back_idx)] = max(back_p);
        end
        
    end
    function learn_gmm
        for i = 1 : K
            fore_idx_i = find(segmentation == SegmentationFore & component == i);
            back_idx_i = find(segmentation == SegmentationBack & component == i);
            
            fore_gmm(i).mean = mean(pixels(fore_idx_i, :));
            back_gmm(i).mean = mean(pixels(back_idx_i, :));
            
            fore_gmm(i).cov  = cov(pixels(fore_idx_i, :));
            back_gmm(i).cov  = cov(pixels(back_idx_i, :));
            
            fore_gmm(i).pi   = numel(fore_idx_i) / numel(find(segmentation == SegmentationFore));
            back_gmm(i).pi   = numel(back_idx_i) / numel(find(segmentation == SegmentationBack));
        end
    end
    function labels = graph_cut
        unary = zeros(2, pixel_num);
        % background data term
        unary(1, (trimap == TrimapFore)) = 0;
        unary(1, (trimap == TrimapBack)) = 4 * 50 + 1;
        % foreground data term
        unary(2, (trimap == TrimapFore)) = 4 * 50 + 1;
        unary(2, (trimap == TrimapBack)) = 0;
        
        unknown_idx = find(trimap == TrimapUkwn);
        fore_p = zeros(K, numel(unknown_idx));
        back_p = zeros(K, numel(unknown_idx));
        for i = 1 : K
            fore_p(i,:) = fore_gmm(i).pi * mvnpdf(pixels(unknown_idx,:), fore_gmm(i).mean, fore_gmm(i).cov);
            back_p(i,:) = back_gmm(i).pi * mvnpdf(pixels(unknown_idx,:), back_gmm(i).mean, back_gmm(i).cov);
        end
        
        unary(1, unknown_idx) = -log(sum(fore_p));
        unary(2, unknown_idx) = -log(sum(back_p));
        
        h = GCO_Create(pixel_num, 2);
        GCO_SetDataCost(h, unary);
        GCO_SetNeighbors(h, pairwise);
        GCO_Expansion(h);
        labels = GCO_GetLabeling(h);
        GCO_Delete(h)
    end
    function user_editing
        MODIFY_NOTHING = 0;
        MODIFY_FORE = 1;
        MODIFY_BACK = 2;
        modification_switch = MODIFY_NOTHING;
        fore_list_x = [];
        fore_list_y = [];
        back_list_x = [];
        back_list_y = [];
        imshow(imfuse(img, segmentation));hold on;title('User editing');
        set(gcf, 'WindowButtonDownFcn', @modification_start);
        
        function modification_start(src, evnt)
            if strcmp(get(src, 'SelectionType'), 'normal')
                modification_switch = MODIFY_FORE;
                set(src, 'Pointer', 'crosshair');
                set(src, 'WindowButtonMotionFcn', @modification_motion);
                set(src, 'WindowButtonUpFcn', @modification_end);
            else if strcmp(get(src, 'SelectionType'), 'alt')
                    modification_switch = MODIFY_BACK;
                    set(src, 'Pointer', 'crosshair');
                    set(src, 'WindowButtonMotionFcn', @modification_motion);
                    set(src, 'WindowButtonUpFcn', @modification_end);
                else if strcmp(get(src, 'SelectionType'), 'open')
                        close(gcf);
                    end
                end
            end
        end
        
        function modification_motion(src, evnt)
            cp = uint32(get(gca, 'CurrentPoint'));
            switch modification_switch
                case MODIFY_FORE
                    fprintf('(%d, %d) labeled as foreground\n', int32(cp(1,1)), int32(cp(1,2)));
                    fore_list_x = [fore_list_x, cp(1,1)];
                    fore_list_y = [fore_list_y, cp(1,2)];
                    plot(fore_list_x, fore_list_y, 'r');
                    [x, y] = meshgrid(cp(1,2) - 5 : cp(1,2) + 5, cp(1,1) - 5 : cp(1,1) + 5);
                    trimap(x, y) = TrimapFore;
                case MODIFY_BACK
                    fprintf('(%d, %d) labeled as background\n', int32(cp(1,1)), int32(cp(1,2)));
                    back_list_x = [back_list_x, cp(1,1)];
                    back_list_y = [back_list_y, cp(1,2)];
                    plot(back_list_x, back_list_y, 'g');
                    [x, y] = meshgrid(cp(1,2) - 5 : cp(1,2) + 5, cp(1,1) - 5 : cp(1,1) + 5);
                    trimap(x, y) = TrimapBack;
                case MODIFY_NOTHING
                    fprintf('just moving :)\n');
                otherwise
                    warning('unexpected thing happens');
            end
        end
        
        function modification_end(src, evnt)
            if modification_switch ~= MODIFY_NOTHING
                set(src, 'Pointer', 'arrow');
                set(src, 'WindowButtonMotionFcn', '');
                set(src, 'WindowButtonUpFcn', '');
                modification_switch = MODIFY_NOTHING;
                figure(315),imagesc(trimap);
                assign_gmm;
                learn_gmm;
                labels = graph_cut;
                labels = reshape(labels, height, width);
                figure(25+iter);
                imshow(imfuse(img, labels));
                axis image;%title(sprintf('segmentation %d', iter));
                drawnow;
                iter = iter + 1;
                num_pixel_change = numel(find(segmentation ~= labels));
                fprintf('%d pixels changed\n', num_pixel_change);
                segmentation = labels;
                fore_list_x = [];
                fore_list_y = [];
                back_list_x = [];
                back_list_y = [];
            end
        end
    end

end
