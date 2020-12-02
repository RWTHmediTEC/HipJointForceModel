function weights = calculateSkinningWeights(mesh, controls, cache, varargin)

% Parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'visualization', 0, logParValidFunc);
parse(p,varargin{:});
visu = p.Results.visualization;

if visu
    % Visualize controls
    patchProps.EdgeColor = 'none';
    patchProps.FaceColor = [223, 206, 161]/255;
    patchProps.FaceAlpha = 0.5;
    patchProps.FaceLighting = 'gouraud';
    visualizeMeshes(mesh, patchProps)
    
    pointProps.Marker = 'o';
    pointProps.MarkerFaceColor = 'k';
    pointProps.MarkerEdgeColor = 'y';
    pointProps.MarkerSize = 7;
    pointProps.LineStyle = 'none';
    structfun(@(x) drawPoint3d(x,pointProps), controls);
    
    anatomicalViewButtons('ASR')
end

key = [meshHash(mesh) DataHash(controls)];
if cache.isCached(key)
    % Get weights from cache
    weights = cache.get(key);
else
    % Create weights
    disp('Skinning weights are calculated. This may take about 5 to 10 minutes ...')
    % Compute boundary conditions
    [bVertices, bConditions] = boundary_conditions(mesh.vertices, mesh.faces, ...
        cell2mat(struct2cell(controls)), 1:length(fieldnames(controls)));
    % Compute weights
    weights = biharmonic_bounded(mesh.vertices, mesh.faces, bVertices, bConditions, 'OptType', 'quad');
    % Normalize weights
    weights = weights./repmat(sum(weights,2), 1, size(weights,2));
    % Store weights in cache
    cache.store(key, weights)
end

end