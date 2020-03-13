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
femur = LE(2).Mesh;
HJC = LE(2).Joints.Hip.Pos; % Hip joint center
P1  = LE(2).Landmarks.P1.Pos; % Straight femur axis (proximal point: P1) [Bergmann2016]
ICN = femur.vertices(LE(2).Landmarks.IntercondylarNotch.Node,:); % Straight femur axis (distal point: P2) [Bergmann2016]
MEC = LE(2).Landmarks.MedialEpicondyle.Pos; 
LEC = LE(2).Landmarks.LateralEpicondyle.Pos;
MPC = femur.vertices(LE(2).Landmarks.MedialPosteriorCondyle.Node,:);
LPC = femur.vertices(LE(2).Landmarks.LateralPosteriorCondyle.Node,:);
GT  = femur.vertices(LE(2).Landmarks.GreaterTrochanter.Node,:);
LT  = femur.vertices(LE(2).Landmarks.LesserTrochanter.Node,:);

Controls=struct('HJC',HJC, 'P1',P1, 'ICN',ICN, 'MEC',MEC, 'LEC',LEC, ...
    'MPC',MPC, 'LPC',LPC, 'GT',GT, 'LT',LT);

patchProps.EdgeColor = 'none';
patchProps.FaceColor = [223, 206, 161]/255;
patchProps.FaceAlpha = 0.5;
patchProps.FaceLighting = 'gouraud';
visualizeMeshes(femur, patchProps)

pointProps.Marker = 'o';
pointProps.MarkerFaceColor = 'k';
pointProps.MarkerEdgeColor = 'y';
pointProps.MarkerSize = 7;
pointProps.LineStyle = 'none';
structfun(@(x) drawPoint3d(x,pointProps),Controls);

anatomicalViewButtons('ASR')

save([fileFolder '\femur' TLEMversion 'Controls.mat'], 'Controls')