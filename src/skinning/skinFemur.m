function data = skinFemur(data)
% Linear blend skinning (LBS) of femur changing femoral length, femoral 
% version, CCD angle and neck length

LE      = data.T.LE;
T.Scale = data.T.Scale;
S.Scale = data.S.Scale;

% Implant parameters
if isequal(S.Scale(2).FemoralLength,  T.Scale(2).FemoralLength) &&...
   isequal(S.Scale(2).FemoralVersion, T.Scale(2).FemoralVersion) &&...
   isequal(S.Scale(2).CCD,            T.Scale(2).CCD) &&...
   isequal(S.Scale(2).NeckLength,     T.Scale(2).NeckLength)
    return
else
    femoralVersion = S.Scale(2).FemoralVersion;
    CCD            = S.Scale(2).CCD;
    neckLength     = S.Scale(2).NeckLength;
end

% Load TLEMversion controls
% mat files are created with data\Skinning\femurTLEM2ConstructControls.m
load(['femur' data.Cadaver 'Controls'], 'Controls')

P = 1:size(Controls,1);

% Create TLEMversion weights
if ~exist(['femur' data.Cadaver 'Weights.mat'], 'file')
    disp('Skinning weights are calculated. This may take a few minutes ...')
    % Compute boundary conditions
    [bVertices,bConditions] = boundary_conditions(LE(2).Mesh.vertices, LE(2).Mesh.faces, Controls, P);
    % Compute weights
    Weights = biharmonic_bounded(LE(2).Mesh.vertices, LE(2).Mesh.faces, bVertices, bConditions, 'OptType', 'quad');
    % Normalize weights
    Weights = Weights./repmat(sum(Weights,2), 1, size(Weights,2));
    
    save(['data/Skinning/femur' data.Cadaver 'Weights'], 'Weights')
end
load(['femur' data.Cadaver 'Weights'], 'Weights')

scaleFemur = eye(4);
scaleFemur(2,2) = S.Scale(2).FemoralLength / T.Scale(2).FemoralLength;
newControls = transformPoint3d(Controls, scaleFemur);

% Femoral version
% Change position of control point by a rotation around the straight femur axis
ROT = createRotation3dLineAngle([newControls(3,:), newControls(3,:) - newControls(2,:)],...
    deg2rad(femoralVersion + T.Scale(2).FemoralVersion));
newControls(1,:) = transformPoint3d(newControls(1,:), ROT);

% CCD
tempCCD = rad2deg(vectorAngle3d(newControls(3,:) - newControls(2,:), newControls(1,:) - newControls(2,:)));
tempHeight = sind(tempCCD - 90) * distancePoints3d(newControls(1,:), newControls(2,:));
tempOffset = cosd(tempCCD - 90) * distancePoints3d(newControls(1,:), newControls(2,:));
HeightAdjust = tand(CCD - 90) * tempOffset - tempHeight;
newControls(1,:) = newControls(1,:) + HeightAdjust * normalizeVector3d(newControls(2,:) - newControls(3,:));

% Neck Length
neckLengthAdjust = neckLength - distancePoints3d(newControls(1,:), newControls(2,:));
newControls(1,:) = newControls(1,:) + neckLengthAdjust *...
    normalizeVector3d(newControls(1,:) - newControls(2,:));

% Femoral Length
% !!! Move newControls(3,:) in proximal direction, along the straight femur 
%     axis to adapt the length !!!

% Construct reference lines to measure femoral version 
postConds = transformPoint3d([...
    LE(2).Mesh.vertices(data.T.LE(2).Landmarks.MedialPosteriorCondyle.Node,:);...
    LE(2).Mesh.vertices(data.T.LE(2).Landmarks.LateralPosteriorCondyle.Node,:)],...
    scaleFemur);
transversePlane = createPlane(newControls(3,:), newControls(2,:) - newControls(3,:));
projPostCond = projPointOnPlane(postConds, transversePlane);
% Posterior condyle line projected onto the transverse plane
projPostCondLine = createLine3d(projPostCond(1,:), projPostCond(2,:));
projNeckPoints = projPointOnPlane(newControls(1:2,:), transversePlane);
projNeckLine = createLine3d(projNeckPoints(1,:), projNeckPoints(2,:));

% % Check if femoral version is correct
% assert(ismembertol(abs(femoralVersion),...
%     rad2deg(vectorAngle3d(projNeckLine(4:6), projPostCondLine(4:6))), 'DataScale', 10)) % !!! Set tolerance
% % Check if CCD angle is correct
% assert(ismembertol(CCD,...
%     rad2deg(vectorAngle3d(newControls(3,:) - newControls(2,:), newControls(1,:) - newControls(2,:)))))
% % Check if neck length is correct
% assert(ismembertol(neckLength, distancePoints3d(newControls(1,:), newControls(2,:))))
% % Check if femoral length is correct
% assert(ismembertol(S.Scale(2).FemoralLength, distancePoints3d(newControls(1,:), newControls(3,:))))

% Calculate skinning transformations
[T, AX, AN, Sm, O] = skinning_transformations(Controls, P, [], newControls);

% Number of handles
m = numel(P); % + size(BE,1);
% Dimension (2 or 3)
dim = size(Controls,2);
% Extract scale
TR = zeros(dim,dim+1,m);
TR(1:dim,1:dim,:) = Sm;
Sm = reshape(Sm,[dim dim*m])';
TR(1:dim,dim+1,:) = permute(O-stacktimes(Sm,O),[2 3 1]);
% Perform scale as linear blend skinning, before translations and rotations
skinnedMesh = LE(2).Mesh;
[scaledVertices] = lbs(skinnedMesh.vertices, TR, Weights);
Q = axisangle2quat(AX,AN);
% quattrans2udq expect 3D translations, so pad with zeros
T = [T zeros(size(T,1),1)];
% Convert quaternions and translations into dualquaternions
DQ = quattrans2udq(Q,T);
% Dual quaternions linear blend skinning deformation
skinnedMesh.vertices = dualquatlbs(scaledVertices, DQ, Weights);

%% Update struct LE of femur
% Mesh
LE(2).Mesh = skinnedMesh;

% Joints
LE(2).Joints.Hip.Pos = newControls(1,:);
joints = fieldnames(LE(2).Joints);
for s = 1:length(joints)
    if isfield(LE(2).Joints.(joints{s}), 'Axis')
        [LE(2).Joints.(joints{s}).Pos,LE(2).Joints.(joints{s}).Axis] = ...
            updateAxis(...
            LE(2).Joints.(joints{s}).Pos, ...
            LE(2).Joints.(joints{s}).Axis, ...
            data.T.LE(2).Mesh, LE(2).Mesh);
    end
end

% Muscles
% Calculate the translation of the nearest node to the muscle attachment 
% position (MAP) between the template femur and the skinned femur. Add this
% translation to the original MAP to get the skinned MAP.
muscles = fieldnames(LE(2).Muscle);
for m = 1:length(muscles)
    for n = 1:length(LE(2).Muscle.(muscles{m}).Type)
        trans = LE(2).Mesh.vertices(LE(2).Muscle.(muscles{m}).Node(n),:) ...
            - data.T.LE(2).Mesh.vertices(LE(2).Muscle.(muscles{m}).Node(n),:);
        LE(2).Muscle.(muscles{m}).Pos(n,:) = LE(2).Muscle.(muscles{m}).Pos(n,:) + trans;

    end
end

% Surfaces
surfaces = fieldnames(LE(2).Surface);
for s = 1:length(surfaces)
    [LE(2).Surface.(surfaces{s}).Center,LE(2).Surface.(surfaces{s}).Axis] = ...
        updateAxis(...
        LE(2).Surface.(surfaces{s}).Center, ...
        LE(2).Surface.(surfaces{s}).Axis, ...
        data.T.LE(2).Mesh, LE(2).Mesh);
end

% Landmarks
% Landmarks of the femur are on the surface of the mesh. Hence, use the
% nearest node to get the new position of the landmark.
landmarks = fieldnames(LE(2).Landmarks);
for lm = 1:length(landmarks)
    if isfield(LE(2).Landmarks.(landmarks{lm}), 'Node')
        LE(2).Landmarks.(landmarks{lm}).Pos = ...
            LE(2).Mesh.vertices(LE(2).Landmarks.(landmarks{lm}).Node,:);
    end
end
% Except landmark P1 [Bergmann 2016] that is not on the surface.
LE(2).Landmarks.P1.Pos = newControls(2,:);
    
data.S.LE(2) = LE(2);

end

function [sOrigin, sAxis] = updateAxis(origin, axis, tMesh, sMesh)

% Get intersections of the template axis with the template mesh
lIdx = lineToVertexIndices([origin, axis], tMesh);
tLinePoints = tMesh.vertices(lIdx,:);
% Create the template line with the template intersections
tLine = createLine3d(tLinePoints(1,:),tLinePoints(2,:));
tLine(4:6) = normalizeVector3d(tLine(4:6));
% Position of the template origin on the template line
tPos = linePosition3d(origin, tLine);
% Distance between the template intersections
tLength = distancePoints3d(tLinePoints(1,:),tLinePoints(2,:));

% Repeat for the skinned mesh
sLinePoints = sMesh.vertices(lIdx,:);
sLine = createLine3d(sLinePoints(1,:),sLinePoints(2,:));
sLine(4:6) = normalizeVector3d(sLine(4:6));
sLength = distancePoints3d(sLinePoints(1,:),sLinePoints(2,:));

% Calculate the origin and axis for the skinned mesh
sOrigin = sLine(1:3) + sLength/tLength * tPos * sLine(4:6);
sAxis = sLine(4:6);
end