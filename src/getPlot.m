% getPlot for Interface
clearvars

%% import stl. files
[Plot.Pelvis.Mesh.vertices, Plot.Pelvis.Mesh.faces] = ...
    stlRead('TLEM 2.0 - Bones - Local Reference Frame - Pelvis Right and Left (origin as midpoint between RASI and LASI).stl');

[Plot.Sacrum.Mesh.vertices, Plot.Sacrum.Mesh.faces] = ...
    stlRead('TLEM 2.0 - Bones - Local Reference Frame - Sacrum (origin as midpoint between RASI and LASI).stl');

%% Visualization
patchProps.EdgeColor = 'none';
patchProps.FaceColor = [0.95 0.91 0.8];
patchProps.FaceAlpha = 1;
patchProps.EdgeLighting = 'gouraud';
patchProps.FaceLighting = 'gouraud';

% New figure
MonitorsPos = get(0,'MonitorPositions');
figHandle = figure('Units','pixels','renderer','opengl', 'Color', 'w');
% figHandle.ToolBar='none';
% figHandle.MenuBar='none';
% figHandle.WindowScrollWheelFcn=@M_CB_Zoom;
% FigHandle.WindowButtonDownFcn=@M_CB_RotateWithLeftMouse;
if     size(MonitorsPos,1) == 1
    set(figHandle,'OuterPosition',[1 50 MonitorsPos(1,3)-1 MonitorsPos(1,4)-50]);
elseif size(MonitorsPos,1) == 2
    set(figHandle,'OuterPosition',[1+MonitorsPos(1,3) 50 MonitorsPos(2,3)-1 MonitorsPos(2,4)-50]);
end
hold on
test = patch(Plot.Sacrum.Mesh, patchProps);
test1 = patch(Plot.Pelvis.Mesh, patchProps);

H_Light(1) = light; light('Position', -1*(get(H_Light(1),'Position')));
% cameratoolbar('SetCoordSys','none')
axis off; axis equal; hold on
xlabel x; ylabel y; zlabel z;

mouseControl3d
viewButtonsASR