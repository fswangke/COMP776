datapath = '../../../data/fountain_dense';
%datapath = '../../data/herzjesu_dense';
%datapath = '../../data/castle_entry_dense';

%sweep(datapath, n_disparity, ref_cam_id, n_nearby_cam, DOWNSAMPLE, PLOT_CAMERA, PLOT_DEPTH)
tic;fountain_depth = sweep(datapath, 50, 6, 4, 1, 1, 1);toc;