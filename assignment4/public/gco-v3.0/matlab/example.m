h = GCO_Create(4,3);             % Create new object with NumSites=4, NumLabels=3
GCO_SetDataCost(h,[0 9 2 0;      % Sites 1,4 prefer  label 1
    3 0 3 3;      % Site  2   prefers label 2 (strongly)
    5 9 0 5;]);   % Site  3   prefers label 3
GCO_SetSmoothCost(h,[0 1 2;      %
    1 0 1;      % Linear (Total Variation) pairwise cost
    2 1 0;]);   %

edges = sparse(4);
edges(1,2) = 1;
edges(2,3) = 1;
edges(3,4) = 2;
edges(4,4) = 0;

GCO_SetNeighbors(h,edges);
GCO_Expansion(h);                % Compute optimal labeling via alpha-expansion
GCO_GetLabeling(h)

[E D S] = GCO_ComputeEnergy(h)   % Energy = Data Energy + Smooth Energy
