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

%% Construct controls
load([fileFolder '\femur' TLEMversion 'Controls.mat'])

femur = LE(2).Mesh;
HJC = LE(2).Joints.Hip.Pos;
P1  = LE(2).Landmarks.P1.Pos;
ICN = femur.vertices(LE(2).Landmarks.IntercondylarNotch.Node,:);
GT  = femur.vertices(LE(2).Landmarks.GreaterTrochanter.Node,:);
LT  = femur.vertices(LE(2).Landmarks.LesserTrochanter.Node,:);

% Controls
Controls(1,:) = HJC; % Hip joint center
Controls(2,:) = P1; % Straight femur axis (proximal point: P1) [Bergmann2016]
Controls(3,:) = ICN; % Straight femur axis (distal point: P2) [Bergmann2016]
Controls(4,:) = GT; % Greater Trochanter
Controls(5,:) = LT; % Lesser Trochanter

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

anatomicalViewButtons('ASR')

save([fileFolder '\femur' TLEMversion 'Controls.mat'], 'Controls', 'BE')