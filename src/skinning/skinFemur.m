function data = skinFemur(data)
% Linear blend skinning (LBS) of femur changing femoral length, femoral 
% version, CCD angle and neck length

visu = 0;

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
    femoralLength  = S.Scale(2).FemoralLength;
    femoralVersion = S.Scale(2).FemoralVersion;
    CCD            = S.Scale(2).CCD;
    neckLength     = S.Scale(2).NeckLength;
end

% Load TLEMversion controls
% mat files are created with data\Skinning\femurTLEM2ConstructControls.m
load(['femur' data.Cadaver 'Controls'], 'Controls')
tC = cell2mat(struct2cell(Controls));
C = Controls;

P = 1:length(fieldnames(Controls));

% Create TLEMversion weights
if ~exist(['femur' data.Cadaver 'Weights.mat'], 'file')
    disp('Skinning weights are calculated. This may take a few minutes ...')
    % Compute boundary conditions
    [bVertices,bConditions] = boundary_conditions(LE(2).Mesh.vertices, LE(2).Mesh.faces, tC, P);
    % Compute weights
    Weights = biharmonic_bounded(LE(2).Mesh.vertices, LE(2).Mesh.faces, bVertices, bConditions, 'OptType', 'quad');
    % Normalize weights
    Weights = Weights./repmat(sum(Weights,2), 1, size(Weights,2));
    
    save(['data/Skinning/femur' data.Cadaver 'Weights'], 'Weights')
end
load(['femur' data.Cadaver 'Weights'], 'Weights')

if visu
    patchProps.EdgeColor = 'none'; %#ok<*UNRCH>
    patchProps.FaceColor = [223, 206, 161]/255;
    patchProps.FaceAlpha = 0.5;
    patchProps.FaceLighting = 'gouraud';
    visualizeMeshes(LE(2).Mesh,patchProps)
    pointProps.MarkerFaceColor='r';
    pointProps.MarkerEdgeColor='none';
    pointProps.Marker='o';
    structfun(@(x) drawPoint3d(x,pointProps),C);
end

% Femoral version
% Change position of HJC by a rotation around the shaft axis
ROT = createRotation3dLineAngle([C.ICN, C.ICN - C.P1],...
    deg2rad(femoralVersion - T.Scale(2).FemoralVersion));
C.HJC = transformPoint3d(C.HJC, ROT);

if visu
    pointProps.MarkerFaceColor='g';
    structfun(@(x) drawPoint3d(x,pointProps),C);
end

% CCD
tempCCD = rad2deg(vectorAngle3d(C.ICN - C.P1, C.HJC - C.P1));
tempHeight = sind(tempCCD - 90) * distancePoints3d(C.HJC, C.P1);
tempOffset = cosd(tempCCD - 90) * distancePoints3d(C.HJC, C.P1);
HeightAdjust = tand(CCD - 90) * tempOffset - tempHeight;
C.HJC = C.HJC + HeightAdjust * normalizeVector3d(C.P1 - C.ICN);

% Neck Length
neckLengthAdjust = neckLength - distancePoints3d(C.HJC, C.P1);
C.HJC = C.HJC + neckLengthAdjust * normalizeVector3d(C.HJC - C.P1);

if visu
    pointProps.MarkerFaceColor='b';
    structfun(@(x) drawPoint3d(x,pointProps),C);
end

% Femoral Length
% Construct the mechanical axis
ECmidPoint = midPoint3d(C.MEC, C.LEC);
mechAxis = createLine3d(C.HJC,ECmidPoint);
mechAxis(4:6) = normalizeVector3d(mechAxis(4:6));
mechAxisAdjust = linePosition3d(ECmidPoint, mechAxis) - femoralLength;
% Adjust femoral length by moving the epicondyles along the mechanical axis
% in inferior direction
C.MEC = C.MEC + mechAxisAdjust * -mechAxis(4:6);
C.LEC = C.LEC + mechAxisAdjust * -mechAxis(4:6);

newECmidPoint = mechAxis(1:3) + femoralLength * mechAxis(4:6);
shaftAxis = createLine3d(C.ICN,C.P1);
shaftAxis(4:6) = normalizeVector3d(shaftAxis(4:6));
shaftAxisAdjust = ...
    linePosition3d(newECmidPoint, shaftAxis) - ...
    linePosition3d(ECmidPoint, shaftAxis);
% Move ICN, MPC, and LPC along the straight femur axis
C.ICN = C.ICN + shaftAxisAdjust * shaftAxis(4:6);
C.MPC = C.MPC + shaftAxisAdjust * shaftAxis(4:6);
C.LPC = C.LPC + shaftAxisAdjust * shaftAxis(4:6);

if visu
    pointProps.MarkerFaceColor='m';
    structfun(@(x) drawPoint3d(x,pointProps),C);
    anatomicalViewButtons('ASR')
end

%% Check if femoral version is correct
assert(ismembertol(femoralVersion,...
    measureFemoralVersionBergmann2016(C.HJC, C.P1, C.ICN, C.MPC, C.LPC),'Datascale',10))
% Check if CCD angle is correct
assert(ismembertol(CCD, rad2deg(vectorAngle3d(C.ICN - C.P1, C.HJC - C.P1))))
% Check if neck length is correct
assert(ismembertol(neckLength, distancePoints3d(C.HJC,C.P1)))
% Check if femoral length is correct
assert(ismembertol(distancePoints3d(midPoint3d(C.MEC,C.LEC),C.HJC),femoralLength))

%% Calculate skinning transformations
[T, AX, AN, Sm, O] = skinning_transformations(tC, P, [], cell2mat(struct2cell(C)));

% Number of handles
m = numel(P); % + size(BE,1);
% Dimension (2 or 3)
dim = size(tC,2);
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
LE(2).Joints.Hip.Pos = C.HJC;
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
LE(2).Landmarks.P1.Pos = C.P1;
    
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