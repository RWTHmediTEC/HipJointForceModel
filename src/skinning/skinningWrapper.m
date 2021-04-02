function skinnedMesh = skinningWrapper(mesh, tControls, weights, sControls)
%SKINNINGWRAPPER Wrapper for linear blend skinning to deform meshes using control points.
%
% Reference: [Jacobson 2014] 2014 - Jacobson - Bounded biharmonic weights 
%   for real-time deformation
%   https://doi.org/10.1145/2578850
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

% Number of controls
NoC = length(fieldnames(tControls));
% Convert to point matrix
tC = cell2mat(struct2cell(tControls));
sC = cell2mat(struct2cell(sControls));

%% Calculate skinning transformations
[T, AX, AN, Sm, O] = skinning_transformations(tC, 1:NoC, [], sC);

% Number of handles
m = numel(1:NoC); % + size(BE,1);
% Dimension (2 or 3)
dim = size(tC,2);
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