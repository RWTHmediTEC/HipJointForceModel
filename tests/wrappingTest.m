% Before running use following code in Command Window whlie in
% HipJointReactionForceModel directory

addpath(genpath('..\src'))
addpath(genpath('..\data'))

close;
clearvars;

data = createData();
gui = createInterface(data);


function data = createData()
%%CREATEDATA creates initial data for wrapping
data.Pos = [0 0 0];
data.Radius = 25;
data.Length = 50;
data.Axis = [0 0 1];
data.O = [-10 50 0];
data.I = [-10 -50 0];
data.mCyl = matGeomCyl(data);
data.Rot = createRotationVector3d([0 0 1], data.Axis);
data.Rot = data.Rot(1:3,1:3);
data.wCyl = wrappingCyl(data);
data.MusWrapSys(1) = initalizeWrapping(data, 'positive');
data.MusWrapSys(2) = initalizeWrapping(data, 'negative');
data.Newton = 0;
end

function gui = createInterface(data)
%%CREATEGUI creates interface
gui.Window = figure(...
    'Name', 'Wrapping Test',...
    'NumberTitle', 'off');

monitorsPosition = get(0, 'MonitorPositions');
gui.Window.OuterPosition = monitorsPosition(2,:);
gui.Window.WindowState='maximized';

gui.Layout = uix.HBox(...
    'Parent', gui.Window, ...
    'Spacing', 3);

gui.Settings.BoxPanel = uix.BoxPanel(...
    'Parent', gui.Layout, ...
    'Title', 'Settings');

%% Settings

gui.Settings.V_Left = uix.VBox(...
    'Parent', gui.Settings.BoxPanel);

% Origin Panel

gui.Settings.Panel_Origin = uix.Panel(...
    'Parent', gui.Settings.V_Left, ...
    'Title', 'Origin');

gui.Settings.Slider_Origin = uix.VButtonBox(...
    'Parent', gui.Settings.Panel_Origin,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left', ...
    'ButtonSize', [500 20]);

gui.Settings.HBox_OriginX = uix.HBox(...
    'Parent', gui.Settings.Slider_Origin);

gui.Settings.OriginX = uicontrol(...
    'Parent', gui.Settings.HBox_OriginX, ...
    'Style', 'Slider', ...
    'Min', -100, ...
    'Max', 100, ...
    'Value', data.O(1), ...
    'Callback', @onEdit_OriginX);

gui.Settings.Text_OriginX = uicontrol(...
    'Parent', gui.Settings.HBox_OriginX, ...
    'Style', 'Text', ...
    'String', 'dsadsad');

gui.Settings.HBox_OriginY = uix.HBox(...
    'Parent', gui.Settings.Slider_Origin);

gui.Settings.OriginY = uicontrol(...
    'Parent', gui.Settings.HBox_OriginY, ...
    'Style', 'Slider', ...
    'Min', -100, ...
    'Max', 100, ...
    'Value', data.O(2), ...
    'Callback', @onEdit_OriginY);

gui.Settings.Text_OriginY = uicontrol(...
    'Parent', gui.Settings.HBox_OriginY, ...
    'Style', 'Text', ...
    'String', 'dsadsad');

gui.Settings.HBox_OriginZ = uix.HBox(...
    'Parent', gui.Settings.Slider_Origin);

gui.Settings.OriginZ = uicontrol(...
    'Parent', gui.Settings.HBox_OriginZ, ...
    'Style', 'Slider', ...
    'Min', -100, ...
    'Max', 100, ...
    'Value', data.O(3), ...
    'Callback', @onEdit_OriginZ);

gui.Settings.Text_OriginZ = uicontrol(...
    'Parent', gui.Settings.HBox_OriginZ, ...
    'Style', 'Text', ...
    'String', 'dsadsad');

% Insertion Panel

gui.Settings.Panel_Insertion = uix.Panel(...
    'Parent', gui.Settings.V_Left, ...
    'Title', 'Insertion');

gui.Settings.Slider_Insertion = uix.VButtonBox(...
    'Parent', gui.Settings.Panel_Insertion,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left', ...
    'ButtonSize', [500 20]);


gui.Settings.HBox_InsertionX = uix.HBox(...
    'Parent', gui.Settings.Slider_Insertion);

gui.Settings.InsertionX = uicontrol(...
    'Parent', gui.Settings.HBox_InsertionX, ...
    'Style', 'Slider', ...
    'Min', -100, ...
    'Max', 100, ...
    'Value', data.I(1), ...
    'Callback', @onEdit_InsertionX);

gui.Settings.Text_InsertionX = uicontrol(...
    'Parent', gui.Settings.HBox_InsertionX, ...
    'Style', 'Text', ...
    'String', 'dsadsad');

gui.Settings.HBox_InsertionY = uix.HBox(...
    'Parent', gui.Settings.Slider_Insertion);

gui.Settings.InsertionY = uicontrol(...
    'Parent', gui.Settings.HBox_InsertionY, ...
    'Style', 'Slider', ...
    'Min', -100, ...
    'Max', 100, ...
    'Value', data.I(2), ...
    'Callback', @onEdit_InsertionY);

gui.Settings.Text_InsertionY = uicontrol(...
    'Parent', gui.Settings.HBox_InsertionY, ...
    'Style', 'Text', ...
    'String', 'dsadsad');

gui.Settings.HBox_InsertionZ = uix.HBox(...
    'Parent', gui.Settings.Slider_Insertion);

gui.Settings.InsertionZ = uicontrol(...
    'Parent', gui.Settings.HBox_InsertionZ, ...
    'Style', 'Slider', ...
    'Min', -100, ...
    'Max', 100, ...
    'Value', data.I(3), ...
    'Callback', @onEdit_InsertionZ);

gui.Settings.Text_InsertionZ = uicontrol(...
    'Parent', gui.Settings.HBox_InsertionZ, ...
    'Style', 'Text', ...
    'String', 'dsadsad');

% Axis Panel

gui.Settings.Panel_Axis = uix.Panel(...
    'Parent', gui.Settings.V_Left, ...
    'Title', 'Axis');

gui.Settings.Slider_Axis = uix.VButtonBox(...
    'Parent', gui.Settings.Panel_Axis,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left', ...
    'ButtonSize', [500 20]);

gui.Settings.HBox_AxisX = uix.HBox(...
    'Parent', gui.Settings.Slider_Axis);

gui.Settings.AxisX = uicontrol(...
    'Parent', gui.Settings.HBox_AxisX, ...
    'Style', 'Slider', ...
    'Min', -1, ...
    'Max', 1, ...
    'Value', data.Axis(1), ...
    'Callback', @onEdit_AxisX);

gui.Settings.Text_AxisX = uicontrol(...
    'Parent', gui.Settings.HBox_AxisX, ...
    'Style', 'Text', ...
    'String', 'dsadsad');

gui.Settings.HBox_AxisY = uix.HBox(...
    'Parent', gui.Settings.Slider_Axis);

gui.Settings.AxisY = uicontrol(...
    'Parent', gui.Settings.HBox_AxisY, ...
    'Style', 'Slider', ...
    'Min', -1, ...
    'Max', 1, ...
    'Value', data.Axis(2), ...
    'Callback', @onEdit_AxisY);

gui.Settings.Text_AxisY = uicontrol(...
    'Parent', gui.Settings.HBox_AxisY, ...
    'Style', 'Text', ...
    'String', 'dsadsad');

gui.Settings.HBox_AxisZ = uix.HBox(...
    'Parent', gui.Settings.Slider_Axis);

gui.Settings.AxisZ = uicontrol(...
    'Parent', gui.Settings.HBox_AxisZ, ...
    'Style', 'Slider', ...
    'Min', -1, ...
    'Max', 1, ...
    'Value', data.Axis(3), ...
    'Callback', @onEdit_AxisZ);

gui.Settings.Text_AxisZ = uicontrol(...
    'Parent', gui.Settings.HBox_AxisZ, ...
    'Style', 'Text', ...
    'String', 'dsadsad');

% Results Panel

gui.Settings.Panel_Results = uix.Panel(...
    'Parent', gui.Settings.V_Left, ...
    'Title', 'Results');

gui.Settings.Text_Results = uix.VBox(...
    'Parent', gui.Settings.Panel_Results,...
    'Spacing', 3);

gui.Settings.Panel_Vector1Rad = uix.Panel(...
    'Parent', gui.Settings.Text_Results, ...
    'Title', 'Vector 1 radial');

gui.Settings.Text_Vect1Rad = uicontrol(...
    'Parent', gui.Settings.Panel_Vector1Rad, ...
    'Style', 'Text', ...
    'HorizontalAlignment', 'left', ...
    'String', 'dies das');

gui.Settings.Panel_Vector1Ax = uix.Panel(...
    'Parent', gui.Settings.Text_Results, ...
    'Title', 'Vector 1 axial');

gui.Settings.Text_Vect1Ax = uicontrol(...
    'Parent', gui.Settings.Panel_Vector1Ax, ...
    'Style', 'Text', ...
    'HorizontalAlignment', 'left', ...
    'String', 'dies das');

gui.Settings.Panel_Vector2Rad = uix.Panel(...
    'Parent', gui.Settings.Text_Results, ...
    'Title', 'Vector 2 radial');

gui.Settings.Text_Vect2Rad = uicontrol(...
    'Parent', gui.Settings.Panel_Vector2Rad, ...
    'Style', 'Text', ...
    'HorizontalAlignment', 'left', ...
    'String', 'dies das');

gui.Settings.Panel_Vector2Ax = uix.Panel(...
    'Parent', gui.Settings.Text_Results, ...
    'Title', 'Vector 2 axial');

gui.Settings.Text_Vect2Ax = uicontrol(...
    'Parent', gui.Settings.Panel_Vector2Ax, ...
    'Style', 'Text', ...
    'HorizontalAlignment', 'left', ...
    'String', 'dies das');

gui.Settings.checkBox_ActivateNewtonStep = uicontrol( ...
    'Parent', gui.Settings.Text_Results, ...
    'Style', 'checkbox', ...
    'String', 'Show with Newton step', ...
    'Callback', @edit_Newton);

gui.Settings.Empty = uix.HBox(...
    'Parent', gui.Settings.V_Left);

set(gui.Settings.V_Left, 'Height', [-1, -1, -1, -2, -3]);

%% Visulaization

gui.Visualization.BoxPanel = uix.BoxPanel(...
    'Parent', gui.Layout, ...
    'Title', 'Visualzation');

gui.Visualization.Axis = axes(...
    'Parent', gui.Visualization.BoxPanel, ...
    'ClippingStyle', '3dbox');

axtoolbar({'export', 'pan', 'zoomin', 'zoomout', 'restoreview'});

xlabel(gui.Visualization.Axis, 'X');
ylabel(gui.Visualization.Axis, 'Y');
zlabel(gui.Visualization.Axis, 'Z');

axis equal;
view([190 30]);

draw();

set(gui.Layout, 'Width', [-1, -4]);

    function onEdit_OriginX(src, ~)
        data.O(1) = src.Value;
        update();
        draw();
    end

    function onEdit_OriginY(src, ~)
        data.O(2) = src.Value;
        update();
        draw();
    end

    function onEdit_OriginZ(src, ~)
        data.O(3) = src.Value;
        update();
        draw();
    end

    function onEdit_InsertionX(src, ~)
        data.I(1) = src.Value;
        update();
        draw();
    end

    function onEdit_InsertionY(src, ~)
        data.I(2) = src.Value;
        update();
        draw();
    end

    function onEdit_InsertionZ(src, ~)
        data.I(3) = src.Value;
        update();
        draw();
    end

    function onEdit_AxisX(src, ~)
        data.Axis(1) = src.Value;
        update();
        draw();
    end

    function onEdit_AxisY(src, ~)
        data.Axis(2) = src.Value;
        update();
        draw();
    end

    function onEdit_AxisZ(src, ~)
        data.Axis(3) = src.Value;
        update();
        draw();
    end

    function edit_Newton(src, ~)
        data.Newton = src.Value;
        update();
        draw();
    end

    function draw
	%%DRAW plots lines and cylinder
	
        cla(gui.Visualization.Axis);
        hold on;
        lineProps.Marker = 'o';
        lineProps.Linestyle = '-';
        lineProps.MarkerSize = 2;
		% plots two lines with different starting conditions
        for i = 1:2
            lineProps.Color = [1-i/2 1-i/2 1-i/2];
            lineProps.MarkerEdgeColor = lineProps.Color;
            lineProps.MarkerFaceColor = lineProps.Color;
            if data.Newton
                for z = 1:4
                    data.MusWrapSys(i) = data.MusWrapSys(1).doNewtonStep();
                end
            end
            lineProps.MarkerEdgeColor = lineProps.Color;
            lineProps.MarkerFaceColor = lineProps.Color;
            data.MusWrapSys(i).plotWrappingSystem(lineProps, gui.Visualization.Axis);
        end
        drawCylinder(gui.Visualization.Axis, data.mCyl, 'open', ...
            'FaceColor', 'red', ...
            'FaceAlpha', 0.2, ...
            'FaceLighting', 'gouraud');
        updateText();
    end

    function updateText()
	%%UPDATTEXT changes every text display in the GUI
	
        gui.Settings.Text_OriginX.String = ['OriginX = ', num2str(round(data.O(1),3))];
        gui.Settings.Text_OriginY.String = ['OriginY = ', num2str(round(data.O(2),3))];
        gui.Settings.Text_OriginZ.String = ['OriginZ = ', num2str(round(data.O(3),3))];
        gui.Settings.Text_InsertionX.String = ['InsertionX = ', num2str(round(data.I(1),3))];
        gui.Settings.Text_InsertionY.String = ['InsertionY = ', num2str(round(data.I(2),3))];
        gui.Settings.Text_InsertionZ.String = ['InsertionZ = ', num2str(round(data.I(3),3))];
        gui.Settings.Text_AxisX.String = ['AxisX = ', num2str(round(data.Axis(1),3))];
        gui.Settings.Text_AxisY.String = ['AxisY = ', num2str(round(data.Axis(2),3))];
        gui.Settings.Text_AxisZ.String = ['AxisZ = ', num2str(round(data.Axis(3),3))];
        gui.Settings.AxisX.Value = data.Axis(1);
        gui.Settings.AxisY.Value = data.Axis(2);
        gui.Settings.AxisZ.Value = data.Axis(3);
        gui.Settings.Text_Vect1Rad.String = num2str(round(data.MusWrapSys(1).q(2),3));
        gui.Settings.Text_Vect1Ax.String = num2str(round(data.MusWrapSys(1).q(3),3));
        gui.Settings.Text_Vect2Rad.String = num2str(round(data.MusWrapSys(2).q(2),3));
        gui.Settings.Text_Vect2Ax.String = num2str(round(data.MusWrapSys(2).q(3),3));
        text(data.O(1)+5, data.O(2)+5, data.O(3)+5, 'Origin');
        text(data.I(1)+5, data.I(2)+5, data.I(3)+5, 'Insertion');
        text(data.MusWrapSys(1).straightLineSegments{1, 2}.startPoint(1)+5, ...
             data.MusWrapSys(1).straightLineSegments{1, 2}.startPoint(2)+5, ...
             data.MusWrapSys(1).straightLineSegments{1, 2}.startPoint(3)+5, ...
             'Vector 1', 'Color', [0.5 0.5 0.5]);
        text(data.MusWrapSys(2).straightLineSegments{1, 2}.startPoint(1)-5, ...
             data.MusWrapSys(2).straightLineSegments{1, 2}.startPoint(2)-5, ...
             data.MusWrapSys(2).straightLineSegments{1, 2}.startPoint(3)-5, ...
             'Vector 2', 'Color', [0 0 0]);
    end

    function update()
	%%UPDATE updates wrapping
	
        data.Axis = normalize(data.Axis);
        data.mCyl = matGeomCyl(data);
        data.Rot = createRotationVector3d([0 0 1], data.Axis);
        data.Rot = data.Rot(1:3,1:3);
        data.wCyl = wrappingCyl(data);
        data.MusWrapSys(1) = initalizeWrapping(data, 'positive');
        data.MusWrapSys(2) = initalizeWrapping(data, 'negative');
        gui.Settings.Text_Vect1Rad.String = num2str(round(data.MusWrapSys(1).q(2),3));
        gui.Settings.Text_Vect1Ax.String = num2str(round(data.MusWrapSys(1).q(3),3));
        gui.Settings.Text_Vect2Rad.String = num2str(round(data.MusWrapSys(2).q(2),3));
        gui.Settings.Text_Vect2Ax.String = num2str(round(data.MusWrapSys(2).q(3),3));
    end

end

function cCylinder = matGeomCyl(data)
%%MATGEOMCYL initializes cylinder for MatGeom

    Start = data.Pos + data.Axis * data.Length;
    End = data.Pos - data.Axis * data.Length;
    cCylinder = [Start, End, data.Radius];
end

function cCylinder = wrappingCyl(data)
%%WRAPPINGCYL initializes cylinder for wrapping

    cCylinder = Cylinder(data.Pos', ...
        data.Rot, ...
        [0 0 0]', ...
        [0 0 0]', ...
        data.Radius, ...
        data.Length);
end

function muscleWrappingSystem = initalizeWrapping(data, varargin)
%%INITALIZEWRAPPING creates data for wrapping
    [~, theta, height, arcLength, vector] = startingPoint3d(data.mCyl, data.O, data.I, data.Pos, data.Axis);
    if isequal(varargin{1}, 'positive')
        initialConditions = [theta height vector(1) vector(2) arcLength];
    elseif isequal(varargin{1}, 'negative')
        initialConditions = [theta height -vector(1) vector(2) arcLength];
    end
    wrappingCylinder = WrappingObstacle(data.wCyl);
    muscleWrappingSystem = MuscleWrappingSystem(data.O', data.I');
    muscleWrappingSystem = muscleWrappingSystem.addWrappingObstacle(wrappingCylinder, initialConditions);
end

function [points, thetaO, heightO, length, vector] = startingPoint3d(cyl, O, I, Center, Axis)
%STARTINGPOINT3D creates starting point for geodesic element

    line = createLine3d(O, I);
    points = intersectLineCylinder(line, cyl, 'checkBounds', false);
    rot = createRotationVector3d(Axis, [0 0 1]);
    rot(1:3,4) = Center;
    points(1,:) = points(1,:) - Center;
    points(1,:) = transformPoint3d(points(1,:), rot(1:3,1:3));
    points(2,:) = points(2,:) - Center;
    points(2,:) = transformPoint3d(points(2,:), rot(1:3,1:3));
    length = distancePoints3d(points(2,:),points(1,:));
    [thetaO,~,heightO] = cart2cyl(points(1,:));
    [thetaI,~,heightI] = cart2cyl(points(2,:));
    vector = normalizeVector3d([thetaI-thetaO, heightI-heightO]);
end