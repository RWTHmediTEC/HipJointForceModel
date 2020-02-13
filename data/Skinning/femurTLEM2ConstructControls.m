clearvars; close all; opengl hardware

addpath(genpath('..\..\..\HipJointReactionForceModel'))

fileFolder=fullfile(fileparts([mfilename('fullpath'), '.m']));

TLEMversion = 'TLEM2_0';

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
% Correction of some of the landmarks
landmarksIn{1,1} = 'IntercondylarNotch';
if exist([fileFolder '\femurTLEM2manualLandmarks.mat'], 'file')
    load([fileFolder '\femurTLEM2manualLandmarks.mat'], 'manuaLMIdx')
    landmarksIn{1,2}=femur.vertices(manuaLMIdx.IntercondylarNotch,:);
    landmarksIn{1,3}=manuaLMIdx.IntercondylarNotch; 
end
landmarksOut = selectLandmarks(femur, landmarksIn);
manuaLMIdx.(landmarksIn{1,1}) = landmarksOut{1,3};
save([fileFolder '\femurTLEM2manualLandmarks.mat'], 'manuaLMIdx')

%% Automatic femoral coordinate system
HJC = LE(2).Joints.Hip.Pos;
if ~exist([fileFolder '\femur' TLEMversion 'Controls.mat'], 'file')
    addpath('D:\Biomechanics\Hip\Code\AutomaticFemoralCoordinateSystem')
    [TFM2femoralCS.Bergmann2016, LMIdx] = automaticFemoralCS(femur, 'r', 'HJC', HJC,...
        'definition', 'Bergmann2016', 'visu', true, 'verbose', true);
    save([fileFolder '\femur' TLEMversion 'Controls.mat'], 'TFM2femoralCS', 'LMIdx')
end

%% Construct controls
load([fileFolder '\femur' TLEMversion 'Controls.mat'])

% Replace automatic detected ICN with manual detected ICN
LMIdx.IntercondylarNotch=manuaLMIdx.IntercondylarNotch;
LMIdx.GreaterTrochanter=LE(2).Landmarks.GreaterTrochanter.Node;
LMIdx.LesserTrochanter=LE(2).Landmarks.LesserTrochanter.Node;

% Construction of P1 [Bergmann 2016]
neckAxis = createLine3d(femur.vertices(LMIdx.NeckAxis(1),:), femur.vertices(LMIdx.NeckAxis(2),:));
shaftAxis = createLine3d(femur.vertices(LMIdx.ShaftAxis(1),:), femur.vertices(LMIdx.ShaftAxis(2),:));
[~, P1, ~] = distanceLines3d(neckAxis, shaftAxis);

% Controls
Controls(1,:) = projPointOnLine3d(HJC,neckAxis); % hip joint center projected on neck axis
Controls(2,:) = P1; % straight femur axis (proximal point: P1) [Bergmann2016]
Controls(3,:) = femur.vertices(LMIdx.IntercondylarNotch,:); % straight femur axis (distal point: P2) [Bergmann2016]
Controls(4,:) = femur.vertices(LMIdx.GreaterTrochanter,:);
Controls(5,:) = femur.vertices(LMIdx.LesserTrochanter,:);

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

save([fileFolder '\femur' TLEMversion 'Controls.mat'], 'TFM2femoralCS', 'LMIdx', 'Controls', 'BE')