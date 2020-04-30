function calculateSkinningWeights(data, boneIdx)

mesh = data.T.LE(boneIdx).Mesh;
controls = data.T.Scale(boneIdx).Landmarks;

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
structfun(@(x) drawPoint3d(x,pointProps),controls);

anatomicalViewButtons('ASR')

%% Create weights
disp('Skinning weights are calculated. This may take a few minutes ...')
% Compute boundary conditions
[bVertices, bConditions] = boundary_conditions(mesh.vertices, mesh.faces, ...
    cell2mat(struct2cell(controls)), 1:length(fieldnames(controls)));
% Compute weights
weights = biharmonic_bounded(mesh.vertices, mesh.faces, bVertices, bConditions, 'OptType', 'quad');
% Normalize weights
weights = weights./repmat(sum(weights,2), 1, size(weights,2));

%% Save
save(['data\Skinning\' data.T.LE(boneIdx).Name 'Weights' data.Cadaver '.mat'], 'mesh', 'controls', 'weights')

end
