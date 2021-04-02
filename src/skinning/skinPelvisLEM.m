function data = skinPelvisLEM(data, method, varargin)
%SKINPELVISLEM deforms the pelvis using linear blend skinning
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

% Parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'visualization', 0, logParValidFunc);
parse(p,varargin{:});
visu = p.Results.visualization;

sides={'R','L'};
boneIdx = 1; % Pelvis

% Create weights
if data.SurfaceData
    mesh = data.T.LE(boneIdx).Mesh;
    templateControls = data.T.Scale(boneIdx).Landmarks;
    weights = calculateSkinningWeights(mesh, templateControls, data.Cache);
else
    errMessage = ['No surface data available for cadaver ' data.Cadaver ...
        '! Skinning is not possible.'];
    msgbox(errMessage,mfilename,'error')
    error(errMessage)
end

LE      = data.T.LE;
S.Scale = data.S.Scale; % Subject (Patient)

switch method
    case 'LandmarkBased'
        subjectControls = S.Scale(boneIdx).Landmarks;
end

% Skinning
skinnedMesh = skinningWrapper(mesh, templateControls, weights, subjectControls);

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
    [LE(boneIdx).Surface.(surfaces{s}).Center, LE(boneIdx).Surface.(surfaces{s}).Axis] = ...
        updateAxis(...
        LE(boneIdx).Surface.(surfaces{s}).Center, ...
        LE(boneIdx).Surface.(surfaces{s}).Axis, ...
        data.T.LE(boneIdx).Mesh, LE(boneIdx).Mesh);
end

% Landmarks
% Landmarks of the pelvis are on the surface of the mesh. Hence, use the
% nearest node to get the new position of the landmark.
landmarks = fieldnames(LE(boneIdx).Landmarks);
for lm = 1:length(landmarks)
    if isfield(LE(boneIdx).Landmarks.(landmarks{lm}), 'Node')
        LE(boneIdx).Landmarks.(landmarks{lm}).Pos = ...
            LE(boneIdx).Mesh.vertices(LE(boneIdx).Landmarks.(landmarks{lm}).Node,:);
    end
end
% Except landmarks ASIS_L and PSIS_L that are not on the surface.
LE(boneIdx).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos = ...
    data.S.Scale(boneIdx).boneCSLandmarks.(['ASIS_' sides{~strcmp(data.S.Side,sides)}]);
LE(boneIdx).Landmarks.LeftPosteriorSuperiorIliacSpine.Pos = ...
    data.S.Scale(boneIdx).boneCSLandmarks.(['PSIS_' sides{~strcmp(data.S.Side,sides)}]);
    
data.S.LE(boneIdx) = LE(boneIdx);

if visu
    % Visualize template
    patchProps.EdgeColor = 'none';
    patchProps.FaceColor = [223, 206, 161]/255;
    patchProps.FaceAlpha = 0.5;
    patchProps.FaceLighting = 'gouraud';
    visualizeMeshes(data.T.LE(boneIdx).Mesh, patchProps)
    
    pointProps.Marker = 'o';
    pointProps.MarkerFaceColor = 'k';
    pointProps.MarkerEdgeColor = 'y';
    pointProps.MarkerSize = 7;
    pointProps.LineStyle = 'none';
    structfun(@(x) drawPoint3d(x,pointProps), data.T.Scale(boneIdx).Landmarks);
    
    % Visualize subject
    patchProps.FaceColor  = 'g';
    patch(data.S.LE(boneIdx).Mesh, patchProps)
    pointProps.MarkerEdgeColor = 'r';
    structfun(@(x) drawPoint3d(x,pointProps), data.S.Scale(boneIdx).Landmarks);
    
    anatomicalViewButtons('ASR')
end

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