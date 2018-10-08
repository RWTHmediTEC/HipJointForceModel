clearvars; close all; opengl hardware

addpath(genpath('..\..\..\HipJointReactionForceModel'))

TLEMversion = 'TLEM2_1';

% Load original data
switch TLEMversion
    case 'TLEM2_0'
        if ~exist('TLEM2_0.mat', 'file')
            importDataTLEM2_0
        end
        load('TLEM2_0', 'LE')
    case 'TLEM2_1'
        if ~exist('TLEM2_1.mat', 'file')
            if ~exist('TLEM2_0.mat', 'file')
                importDataTLEM2_0
            end
            load('TLEM2_0', 'LE', 'muscleList')
            importDataTLEM2_1(LE, muscleList);
        end
        load('TLEM2_1', 'LE')
    otherwise
        error('No valid TLEM version')
end

%% Manual landmarks
femur = LE(2).Mesh;
if ~exist('femurTLEM2Landmarks.mat', 'file')
    addpath('D:\Biomechanics\General\Code\ManualLandmarkSelection')
        % Correction of some of the landmarks
    landmarksIn{1,1} = 'IntercondylarNotch';
    landmarksOut = selectLandmarks(femur, landmarksIn);
    LandmarksIdx.(landmarksIn{1,1}) = landmarksOut{1,3};
    save('femurTLEM2Landmarks.mat', 'LandmarksIdx')
end
load('femurTLEM2Landmarks.mat', 'LandmarksIdx')

%% Automatic femoral coordinate system
HJC = LE(2).Joints.Hip.Pos;
if ~exist(['femur' TLEMversion 'Controls.mat'], 'file')
    addpath('..\..\..\mediTEC\matlab\AutomaticFemoralCoordinateSystem')
    [fwTFM2AFCS, LMIdx] = automaticFemoralCS(femur, 'r', 'HJC', HJC,...
        'definition', 'Bergmann2016', 'vis', true, 'verbose', true);
    save(['femur' TLEMversion 'Controls.mat'], 'fwTFM2AFCS', 'LMIdx')
end

%% Construct controls
load(['femur' TLEMversion 'Controls.mat'])

% Construction of P1 [Bergmann2016]
neckAxis = createLine3d(femur.vertices(LMIdx.NeckAxis(1),:), femur.vertices(LMIdx.NeckAxis(2),:));
shaftAxis = createLine3d(femur.vertices(LMIdx.ShaftAxis(1),:), femur.vertices(LMIdx.ShaftAxis(2),:));
[~, P1, ~] = distanceLines3d(neckAxis, shaftAxis);

% Controls
Controls(1,:) = projPointOnLine3d(HJC,neckAxis); % hip joint center projected on neck axis
Controls(2,:) = P1; % straight femur axis (proximal point: P1) [Bergmann2016]
Controls(3,:) = femur.vertices(LandmarksIdx.IntercondylarNotch,:); % straight femur axis (distal point: ICN) [Bergmann2016]
Controls(4,:) = femur.vertices(LMIdx.GreaterTrochanter,:); % !!! Use the landmarks of the TLEM2_0 !!! 
Controls(5,:) = femur.vertices(LMIdx.LesserTrochanter,:); % !!! Use the landmarks of the TLEM2_0 !!!

BE = [1,2; 2,3; 2,4; 2,5];

patchProps.EdgeColor = 'none';
patchProps.FaceColor = [223, 206, 161]/255;
patchProps.FaceAlpha = 0.5;
patchProps.FaceLighting = 'gouraud';
visualizeMeshes(femur, patchProps)

for b = 1:size(BE,1)
    drawEdge3d(Controls(BE(b,1),:), Controls(BE(b,2),:), 'Color', 'k');
end

pointProps.Marker = 'o';
pointProps.MarkerFaceColor = 'k';
pointProps.MarkerEdgeColor = 'y';
pointProps.MarkerSize = 7;
pointProps.LineStyle = 'none';
drawPoint3d(Controls, pointProps)

mouseControl3d
medicalViewButtons('ASR')

drawLine3d(neckAxis, 'Color', 'r');
drawLine3d(shaftAxis, 'Color', 'r');

save(['femur' TLEMversion 'Controls.mat'], 'fwTFM2AFCS', 'LMIdx', 'Controls', 'BE')