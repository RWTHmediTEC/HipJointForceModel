function skinnedMesh = skinningWrapper(weightsFile, newControls)
% Wrapper for linear blend skinning (LBS)

% Load mesh, controls and weights
load(weightsFile, 'mesh', 'controls', 'weights')
% Number of controls
NoC = length(fieldnames(controls));
% Convert to point matrix
C = cell2mat(struct2cell(controls));
new_C = cell2mat(struct2cell(newControls));

%% Calculate skinning transformations
[T, AX, AN, Sm, O] = skinning_transformations(C, 1:NoC, [], new_C);

% Number of handles
m = numel(1:NoC); % + size(BE,1);
% Dimension (2 or 3)
dim = size(C,2);
% Extract scale
TR = zeros(dim,dim+1,m);
TR(1:dim,1:dim,:) = Sm;
Sm = reshape(Sm,[dim dim*m])';
TR(1:dim,dim+1,:) = permute(O-stacktimes(Sm,O),[2 3 1]);
% Perform scale as linear blend skinning, before translations and rotations
skinnedMesh = mesh;
[scaledVertices] = lbs(skinnedMesh.vertices, TR, weights);
Q = axisangle2quat(AX,AN);
% quattrans2udq expect 3D translations, so pad with zeros
T = [T zeros(size(T,1),1)];
% Convert quaternions and translations into dualquaternions
DQ = quattrans2udq(Q,T);
% Dual quaternions linear blend skinning deformation
skinnedMesh.vertices = dualquatlbs(scaledVertices, DQ, weights);

end