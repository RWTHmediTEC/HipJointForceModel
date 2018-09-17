clearvars; close all; opengl hardware

addpath('D:\Biomechanics\General\Code\#public')
addpath(genpath('D:\Biomechanics\General\Code\#external\matGeom\matGeom'))

if ~exist('..\TLEM2.mat', 'file')
    importDataTLEM2
end
% Load original data
load('..\TLEM2.mat', 'LE')

%% Automatic femoral coordinate system
femur = LE(2).Mesh;
HJC = LE(2).Joints.Hip.Pos;
if ~exist('femurTLEM2Controls.mat', 'file')
    addpath('D:\Biomechanics\Hip\Code\AutomaticFemoralCoordinateSystem')
    addpath('D:\Biomechanics\General\Code\ManualLandmarkSelection')
    
    [fwTFM2AFCS, LMIdx] = automaticFemoralCS(femur, 'r','HJC',HJC,...
        'definition','Bergmann2016','vis', true, 'verbose', true);
    % Correction of some of the landmarks
    landmarksIn{1,1} = 'IntercondylarNotch';
    landmarksIn{1,2} = femur.vertices(LMIdx.IntercondylarNotch,:);
    landmarksIn{2,1} = 'GreaterTrochanter';
    landmarksIn{2,2} = femur.vertices(LMIdx.GreaterTrochanter,:);
    landmarksIn{3,1} = 'LesserTrochanter';
    landmarksIn{3,2} = femur.vertices(LMIdx.LesserTrochanter,:);
    landmarksOut = selectLandmarks(femur, landmarksIn);
    LMIdx.IntercondylarNotch=knnsearch(femur.vertices, landmarksOut{1,2});
    save('data/femurTLEM2Controls', 'fwTFM2AFCS', 'LMIdx')
end


%% Construct controls
load('femurTLEM2Controls')

% Construction of P1 [Bergmann2016]
neckAxis=createLine3d(femur.vertices(LMIdx.NeckAxis(1),:), femur.vertices(LMIdx.NeckAxis(2),:));
shaftAxis=createLine3d(femur.vertices(LMIdx.ShaftAxis(1),:), femur.vertices(LMIdx.ShaftAxis(2),:));
[~, P1, ~] = distanceLines3d(neckAxis, shaftAxis);

% Controls
Controls(1,:)=projPointOnLine3d(HJC,neckAxis); % hip joint center projected on neck axis
Controls(2,:)=P1; % straight femur axis (distal point: P1) [Bergmann2016]
Controls(3,:)=femur.vertices(LMIdx.IntercondylarNotch,:); % straight femur axis (proximal point: ICN) [Bergmann2016]
Controls(4,:)=femur.vertices(LMIdx.GreaterTrochanter,:);
Controls(5,:)=femur.vertices(LMIdx.LesserTrochanter,:);

BE=[1,2; 2,3; 2,4; 2,5];

patchProps.EdgeColor = 'none';
patchProps.FaceColor = [223, 206, 161]/255;
patchProps.FaceAlpha = 0.5;
patchProps.FaceLighting = 'gouraud';
visualizeMeshes(femur, patchProps)

for b=1:size(BE,1)
    drawEdge3d(Controls(BE(b,1),:),Controls(BE(b,2),:),'Color','k');
end

pointProps.Marker='o';
pointProps.MarkerFaceColor='k';
pointProps.MarkerEdgeColor='y';
pointProps.MarkerSize=7;
pointProps.LineStyle='none';
drawPoint3d(Controls,pointProps)

mouseControl3d
medicalViewButtons('ASR')

drawLine3d(neckAxis,'Color','r');
drawLine3d(shaftAxis,'Color','r');

% save('femurTLEM2Controls', 'fwTFM2AFCS', 'LMIdx', 'Controls', 'BE')