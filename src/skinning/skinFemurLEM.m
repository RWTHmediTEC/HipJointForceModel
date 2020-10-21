function data = skinFemurLEM(data, method)
% Linear blend skinning (LBS) of the femur

boneIdx = 2; % femur
weightsFile = [data.T.LE(boneIdx).Name 'Weights' data.Cadaver '.mat'];

% Create controls - !!! Caching should be included here !!!
if data.SurfaceData
    if ~exist(weightsFile,'file')
        calculateSkinningWeights(data, boneIdx)
    end
    load(weightsFile, 'controls')
else
    errMessage = ['No surface data available for cadaver ' data.Cadaver ...
        '! Skinning is not possible.'];
    msgbox(errMessage,mfilename,'error')
    error(errMessage)
end

LE      = data.T.LE;
T.Scale = data.T.Scale; % Template (Cadaver)
S.Scale = data.S.Scale; % Subject (Patient)

switch method
    case 'ParameterBased'
        % Change of the control points based on the femoral length, femoral
        % version, CCD angle and neck length
        subjectControls = parameterBased(controls,T,S);
    case 'LandmarkBased'
        subjectControls = S.Scale(boneIdx).Landmarks;
end

% Skinning
skinnedMesh = skinningWrapper(weightsFile, subjectControls);

%% Update struct LE of femur
% Mesh
LE(boneIdx).Mesh = skinnedMesh;

% Joints
LE(boneIdx).Joints.Hip.Pos = subjectControls.HJC;
joints = fieldnames(LE(boneIdx).Joints);
for s = 1:length(joints)
    if isfield(LE(boneIdx).Joints.(joints{s}), 'Axis')
        [LE(boneIdx).Joints.(joints{s}).Pos,LE(boneIdx).Joints.(joints{s}).Axis] = ...
            updateAxis(...
            LE(boneIdx).Joints.(joints{s}).Pos, ...
            LE(boneIdx).Joints.(joints{s}).Axis, ...
            data.T.LE(boneIdx).Mesh, LE(boneIdx).Mesh);
    end
end

% Muscles
% Calculate the translation of the nearest node to the muscle attachment 
% position (MAP) between the template femur and the skinned femur. Add this
% translation to the original MAP to get the skinned MAP.
muscles = fieldnames(LE(boneIdx).Muscle);
for m = 1:length(muscles)
    for n = 1:length(LE(boneIdx).Muscle.(muscles{m}).Type)
        trans = LE(boneIdx).Mesh.vertices(LE(boneIdx).Muscle.(muscles{m}).Node(n),:) ...
            - data.T.LE(boneIdx).Mesh.vertices(LE(boneIdx).Muscle.(muscles{m}).Node(n),:);
        LE(boneIdx).Muscle.(muscles{m}).Pos(n,:) = LE(boneIdx).Muscle.(muscles{m}).Pos(n,:) + trans;

    end
end

% Surfaces
surfaces = fieldnames(LE(boneIdx).Surface);
for s = 1:length(surfaces)
    [LE(boneIdx).Surface.(surfaces{s}).Center,LE(boneIdx).Surface.(surfaces{s}).Axis] = ...
        updateAxis(...
        LE(boneIdx).Surface.(surfaces{s}).Center, ...
        LE(boneIdx).Surface.(surfaces{s}).Axis, ...
        data.T.LE(boneIdx).Mesh, LE(boneIdx).Mesh);
end

% Landmarks
% Landmarks of the femur are on the surface of the mesh. Hence, use the
% nearest node to get the new position of the landmark.
landmarks = fieldnames(LE(boneIdx).Landmarks);
for lm = 1:length(landmarks)
    if isfield(LE(boneIdx).Landmarks.(landmarks{lm}), 'Node')
        LE(boneIdx).Landmarks.(landmarks{lm}).Pos = ...
            LE(boneIdx).Mesh.vertices(LE(boneIdx).Landmarks.(landmarks{lm}).Node,:);
    end
end
% Except landmark P1 [Bergmann 2016] that is not on the surface.
LE(boneIdx).Landmarks.P1.Pos = subjectControls.P1;
    
data.S.LE(boneIdx) = LE(boneIdx);

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


function C = parameterBased(C, T, S, varargin)
% Change of the control points based on the femoral length, femoral 
% version, CCD angle and neck length

% Parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'visualization',0, logParValidFunc);
parse(p,varargin{:});
visu = p.Results.visualization;

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

if visu
    patchProps.EdgeColor = 'none'; %#ok<*UNRCH>
    patchProps.FaceColor = [223, 206, 161]/255;
    patchProps.FaceAlpha = 0.5;
    patchProps.FaceLighting = 'gouraud';
    visualizeMeshes(data.T.LE(2).Mesh,patchProps)
    pointProps.MarkerFaceColor='y';
    pointProps.MarkerEdgeColor='none';
    pointProps.Marker='o';
    structfun(@(x) drawPoint3d(x,pointProps),C);
end

% Femoral version
% Change position of HJC by a rotation around the shaft axis
ROT = createRotation3dLineAngle([C.P2, C.P2 - C.P1],...
    deg2rad(femoralVersion - T.Scale(2).FemoralVersion));
C.HJC = transformPoint3d(C.HJC, ROT);

if visu
    pointProps.MarkerFaceColor='g';
    structfun(@(x) drawPoint3d(x,pointProps),C);
end

% CCD
tempCCD = rad2deg(vectorAngle3d(C.P2 - C.P1, C.HJC - C.P1));
tempHeight = sind(tempCCD - 90) * distancePoints3d(C.HJC, C.P1);
tempOffset = cosd(tempCCD - 90) * distancePoints3d(C.HJC, C.P1);
HeightAdjust = tand(CCD - 90) * tempOffset - tempHeight;
C.HJC = C.HJC + HeightAdjust * normalizeVector3d(C.P1 - C.P2);

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
mechAxis = normalizeLine3d(createLine3d(C.HJC,ECmidPoint));
mechAxisAdjust = linePosition3d(ECmidPoint, mechAxis) - femoralLength;
% Adjust femoral length by moving the epicondyles along the mechanical axis
% in inferior direction
C.MEC = C.MEC + mechAxisAdjust * -mechAxis(4:6);
C.LEC = C.LEC + mechAxisAdjust * -mechAxis(4:6);
% Calculate the new epicondylar midpoint
newECmidPoint = mechAxis(1:3) + femoralLength * mechAxis(4:6);
shaftAxis = normalizeLine3d(createLine3d(C.P2,C.P1));
% Project the old and new epicondylar midpoint on the straight femur axis
% and calculate the difference along the straight femur axis.
shaftAxisAdjust = ...
    linePosition3d(newECmidPoint, shaftAxis) - ...
    linePosition3d(ECmidPoint, shaftAxis);
% Move P2, MPC, and LPC along the straight femur axis
C.P2 = C.P2 + shaftAxisAdjust * shaftAxis(4:6);
C.MPC = C.MPC + shaftAxisAdjust * shaftAxis(4:6);
C.LPC = C.LPC + shaftAxisAdjust * shaftAxis(4:6);

if visu
    pointProps.MarkerFaceColor='m';
    structfun(@(x) drawPoint3d(x,pointProps),C);
    anatomicalViewButtons('ASR')
end

%% Check if femoral version is correct
assert(ismembertol(femoralVersion,...
    measureFemoralVersionBergmann2016(C.HJC, C.P1, C.P2, C.MPC, C.LPC),'Datascale',10))
% Check if CCD angle is correct
assert(ismembertol(CCD, rad2deg(vectorAngle3d(C.P2 - C.P1, C.HJC - C.P1))))
% Check if neck length is correct
assert(ismembertol(neckLength, distancePoints3d(C.HJC,C.P1)))
% Check if femoral length is correct
assert(ismembertol(distancePoints3d(midPoint3d(C.MEC,C.LEC),C.HJC),femoralLength))

end

