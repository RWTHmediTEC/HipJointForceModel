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
mesh = LE(2).Mesh;
HJC = LE(2).Joints.Hip.Pos; % Hip joint center
P1  = LE(2).Landmarks.P1.Pos; % Straight femur axis (proximal point: P1) [Bergmann2016]
ICN = mesh.vertices(LE(2).Landmarks.IntercondylarNotch.Node,:); % Straight femur axis (distal point: P2) [Bergmann2016]
MEC = LE(2).Landmarks.MedialEpicondyle.Pos; 
LEC = LE(2).Landmarks.LateralEpicondyle.Pos;
MPC = mesh.vertices(LE(2).Landmarks.MedialPosteriorCondyle.Node,:);
LPC = mesh.vertices(LE(2).Landmarks.LateralPosteriorCondyle.Node,:);
GT  = mesh.vertices(LE(2).Landmarks.GreaterTrochanter.Node,:);
LT  = mesh.vertices(LE(2).Landmarks.LesserTrochanter.Node,:);

controls=struct(...
    'HJC',HJC, 'P1',P1, 'ICN',ICN, 'MEC',MEC, 'LEC',LEC, ...
    'MPC',MPC, 'LPC',LPC, 'GT',GT, 'LT',LT);

% Visualize controls
patchProps.EdgeColor = 'none';
patchProps.FaceColor = [223, 206, 161]/255;
patchProps.FaceAlpha = 0.5;
patchProps.FaceLighting = 'gouraud';
visualizeMeshes(mesh, patchProps)

pointProps.Marker = 'o';
pointProps.MarkerFaceColor = 'k';
pointProps.MarkerEdgeColor = 'y';
pointProps.MarkerSize = 7;
pointProps.LineStyle = 'none';
structfun(@(x) drawPoint3d(x,pointProps),controls);

anatomicalViewButtons('ASR')

%% Create weights
disp('Skinning weights are calculated. This may take a few minutes ...')
% Compute boundary conditions
[bVertices, bConditions] = boundary_conditions(mesh.vertices, mesh.faces, ...
    cell2mat(struct2cell(controls)), 1:length(fieldnames(controls)));
% Compute weights
weights = biharmonic_bounded(mesh.vertices, mesh.faces, bVertices, bConditions, 'OptType', 'quad');
% Normalize weights
weights = weights./repmat(sum(weights,2), 1, size(weights,2));

%% Save
save([fileFolder '\skinFemur' TLEMversion '.mat'], 'mesh', 'controls', 'weights')
