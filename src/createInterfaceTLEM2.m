function gui = createInterfaceTLEM2(data)

% Create GUI
gui.Window = figure(...
    'Name', 'Hip Joint Reaction Force Model',...
    'NumberTitle', 'off',...
    'MenuBar', 'figure',...
    'Toolbar', 'figure');

monitorsPosition = get(0, 'MonitorPositions');
if size(monitorsPosition, 1) == 1
    set(gui.Window, 'OuterPosition' ,monitorsPosition(1,:));
elseif size(monitorsPosition, 1) == 2
    set(gui.Window, 'OuterPosition', monitorsPosition(2,:));
end

gui.Tabs = uiextras.TabPanel('Parent', gui.Window, 'TabSize', 100);

% Create home tab
gui.Home.Layout_H       = uix.HBox('Parent', gui.Tabs,          'Spacing', 3);
gui.Home.Layout_V_Left  = uix.VBox('Parent', gui.Home.Layout_H, 'Spacing', 3);
gui.Home.Layout_V_Mid   = uix.VBox('Parent', gui.Home.Layout_H, 'Spacing', 3);
gui.Home.Layout_V_Right = uix.VBox('Parent', gui.Home.Layout_H, 'Spacing', 3);

% Create validation tab
gui.Validation.Layout_Grid = uix.Grid('Parent', gui.Tabs, 'Spacing', 3);

gui.Tabs.TabNames = {'Home', 'Validation'};
gui.Tabs.SelectedChild = 1;

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                                 HOME TAB                                %
%_________________________________________________________________________%

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                                  PANELS                                 %
%_________________________________________________________________________%

%% Box panel settings
gui.Home.Settings.BoxPanel = uix.BoxPanel('Parent', gui.Home.Layout_V_Left,...
    'Title', 'Settings',...
    'FontWeight', 'bold');

gui.Home.Settings.Layout_V = uix.VBox('Parent', gui.Home.Settings.BoxPanel,...
    'Spacing', 3);

% Panel TLEMversion
gui.Home.Settings.Panel_TLEMversion = uix.Panel('Parent', gui.Home.Settings.Layout_V,...
    'Title', 'Used TLEM Version');

gui.Home.Settings.RadioButtonBox_TLEMversion = uix.VButtonBox('Parent', gui.Home.Settings.Panel_TLEMversion,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left',...
    'ButtonSize', [80 20]);

gui.Home.Settings.RadioButton_TLEM2_0 = uicontrol('Parent', gui.Home.Settings.RadioButtonBox_TLEMversion,...
    'Style', 'radiobutton',...
    'String', 'TLEM 2.0',...
    'Callback', @onTLEM2_0);

gui.Home.Settings.RadioButton_TLEM2_1 = uicontrol('Parent', gui.Home.Settings.RadioButtonBox_TLEMversion,...
    'Style', 'radiobutton',...
    'String', 'TLEM 2.1',...
    'Callback', @onTLEM2_1);

set(gui.Home.Settings.(['RadioButton_' data.TLEMversion]), 'Value', 1)

% Panel view
gui.Home.Settings.Panel_View = uix.Panel('Parent', gui.Home.Settings.Layout_V,...
    'Title', 'Show Hip Joint Force for');

gui.Home.Settings.RadioButtonBox_View = uix.VButtonBox('Parent', gui.Home.Settings.Panel_View,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left',...
    'ButtonSize', [80 20]);

gui.Home.Settings.RadioButton_Pelvis = uicontrol('Parent', gui.Home.Settings.RadioButtonBox_View,...
    'Style', 'radiobutton',...
    'String', 'Pelvis',...
    'Callback', @onPelvis);

gui.Home.Settings.RadioButton_Femur = uicontrol('Parent', gui.Home.Settings.RadioButtonBox_View,...
    'Style', 'radiobutton',...
    'String', 'Femur',...
    'Callback', @onFemur);

set(gui.Home.Settings.(['RadioButton_' data.View]), 'Value', 1)

% Panel femoral transformation
gui.Home.Settings.Panel_FemoralTransformation = uix.Panel('Parent', gui.Home.Settings.Layout_V,...
    'Title', 'Execute Femoral Transformation by');

gui.Home.Settings.RadioButtonBox_FemoralTransformation = uix.VButtonBox('Parent', gui.Home.Settings.Panel_FemoralTransformation,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left',...
    'ButtonSize', [200 20]);

gui.Home.Settings.RadioButton_Scaling = uicontrol('Parent', gui.Home.Settings.RadioButtonBox_FemoralTransformation,...
    'Style', 'radiobutton',...
    'String', 'Scaling',...
    'Callback', @onScaling);

gui.Home.Settings.RadioButton_Skinning = uicontrol('Parent', gui.Home.Settings.RadioButtonBox_FemoralTransformation,...
    'Style', 'radiobutton',...
    'String', 'Linear Blend Skinning',...
    'Callback', @onSkinning);

set(gui.Home.Settings.(['RadioButton_' data.FemoralTransformation]), 'Value', 1)

% % Adjust layout
% set(gui.Home.Settings.Layout_V, 'Height', [-1, -1, -1])

%% Box panel patient specific parameters
gui.Home.Parameters.BoxPanel = uix.BoxPanel('Parent', gui.Home.Layout_V_Left,...
    'Title', 'Patient Specific Parameters',...
    'FontWeight', 'bold');

gui.Home.Parameters.Layout_V = uix.VBox('Parent', gui.Home.Parameters.BoxPanel,...
    'Spacing', 3);

% Panel side
gui.Home.Parameters.Panel_Side = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Side');

gui.Home.Parameters.RadioButtonBox_Side = uix.VButtonBox('Parent', gui.Home.Parameters.Panel_Side,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left',...
    'ButtonSize', [80 20]);

gui.Home.Parameters.RadioButton_L = uicontrol('Parent', gui.Home.Parameters.RadioButtonBox_Side,...
    'Style', 'radiobutton',...
    'String', 'Left',...
    'Callback', @onLeftSide);

gui.Home.Parameters.RadioButton_R = uicontrol('Parent', gui.Home.Parameters.RadioButtonBox_Side,...
    'Style', 'radiobutton',...
    'String', 'Right',...
    'Callback', @onRightSide);

set(gui.Home.Parameters.(['RadioButton_' data.T.Side]), 'Value', 1)

% Panel body weight
gui.Home.Parameters.Panel_BodyWeight = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Body Weight [kg]');

gui.Home.Parameters.EditText_BodyWeight = uicontrol('Parent', gui.Home.Parameters.Panel_BodyWeight,...
    'Style', 'edit',...
    'String', data.T.BodyWeight,...
    'Callback', @onEditText_BodyWeight);

% Panel hip joint width
gui.Home.Parameters.Panel_HipJointWidth = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Hip Joint Width [mm]');

gui.Home.Parameters.EditText_HipJointWidth = uicontrol('Parent', gui.Home.Parameters.Panel_HipJointWidth,...
    'Style', 'edit',...
    'String', data.T.Scale(1).HipJointWidth,...
    'Callback', @onEditText_HipJointWidth);

% Panel pelvic bend
gui.Home.Parameters.Panel_PelvicBend = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Pelvic Bend [°]');

gui.Home.Parameters.EditText_PelvicBend = uicontrol('Parent', gui.Home.Parameters.Panel_PelvicBend,...
    'Style', 'edit',...
    'String', data.T.PelvicBend,...
    'Callback', @onEditText_PelvicBend);

% Panel pelvic width
gui.Home.Parameters.Panel_PelvicWidth = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Pelvic Width [mm]');

gui.Home.Parameters.EditText_PelvicWidth = uicontrol('Parent', gui.Home.Parameters.Panel_PelvicWidth,...
    'Style', 'edit',...
    'String', data.T.Scale(1).PelvicWidth,...
    'Callback', @onEditText_PelvicWidth);

% Panel pelvic height
gui.Home.Parameters.Panel_PelvicHeight = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Pelvic Height [mm]');

gui.Home.Parameters.EditText_PelvicHeight = uicontrol('Parent', gui.Home.Parameters.Panel_PelvicHeight,...
    'Style', 'edit',...
    'String', data.T.Scale(1).PelvicHeight,...
    'Callback', @onEditText_PelvicHeight);

% Panel pelvic depth
gui.Home.Parameters.Panel_PelvicDepth = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Pelvic Depth [mm]');

gui.Home.Parameters.EditText_PelvicDepth = uicontrol('Parent', gui.Home.Parameters.Panel_PelvicDepth,...
    'Style', 'edit',...
    'String', data.T.Scale(1).PelvicDepth,...
    'Callback', @onEditText_PelvicDepth);

% Panel femoral length
gui.Home.Parameters.Panel_FemoralLength = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Femoral Length [mm]');

gui.Home.Parameters.EditText_FemoralLength = uicontrol('Parent', gui.Home.Parameters.Panel_FemoralLength,...
    'Style', 'edit',...
    'String', data.T.Scale(2).FemoralLength,...
    'Callback', @onEditText_FemoralLength);

% Panel femoral version
gui.Home.Parameters.Panel_FemoralVersion = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Femoral Version [°]');

gui.Home.Parameters.EditText_FemoralVersion = uicontrol('Parent', gui.Home.Parameters.Panel_FemoralVersion,...
    'Style', 'edit',...
    'String', data.T.Scale(2).FemoralVersion,...
    'Callback', @onEditText_FemoralVersion);

% Panel CCD
gui.Home.Parameters.Panel_CCD = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'CCD Angle [°]');

gui.Home.Parameters.EditText_CCD = uicontrol('Parent', gui.Home.Parameters.Panel_CCD,...
    'Style', 'edit',...
    'String', data.T.Scale(2).CCD,...
    'Callback', @onEditText_CCD);

% Panel neck length
gui.Home.Parameters.Panel_NeckLength = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Neck Length [mm]');

gui.Home.Parameters.EditText_NeckLength = uicontrol('Parent', gui.Home.Parameters.Panel_NeckLength,...
    'Style', 'edit',...
    'String', data.T.Scale(2).NeckLength,...
    'Callback', @onEditText_NeckLength);

% Reset button
gui.Home.Parameters.PushButton_ResetParameters = uicontrol('Parent', gui.Home.Parameters.Layout_V,...
    'Style', 'PushButton',...
    'String', 'Reset',...
    'Callback', @onPushButton_ResetParameters);

% Adjust layout
set(gui.Home.Parameters.Layout_V, 'Height', [-2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -0.6])

%% Box panel model
gui.Home.Model.BoxPanel = uix.BoxPanel('Parent', gui.Home.Layout_V_Right,...
    'Title', 'Model',...
    'FontWeight', 'bold');

gui.Home.Model.Layout_H = uix.HBox('Parent', gui.Home.Model.BoxPanel,...
    'Spacing', 3);

% Panel posture
gui.Home.Model.Panel_Posture = uix.Panel('Parent', gui.Home.Model.Layout_H,...
    'Title', 'Posture');

% Get models
models = dir('src\models\*.m');
[~, models] = arrayfun(@(x) fileparts(x.name), models, 'uni', 0);
data.Model = models{2};
updatePosture()
gui.Home.Model.ListBox_Posture = uicontrol( 'Parent', gui.Home.Model.Panel_Posture,...
    'BackgroundColor', 'w',...
    'Style', 'list',...
    'String', models,...
    'Value', 2,...
    'Callback', @onListSelection_Posture);

% Panel muscle list
gui.Home.Model.Panel_Muscle = uix.Panel('Parent', gui.Home.Model.Layout_H,...
    'Title', 'Muscle List');
gui.Home.Model.Layout_V_Muscle = uix.VBox('Parent', gui.Home.Model.Panel_Muscle, 'Spacing', 3);

gui.Home.Model.ListBox_MuscleList = uicontrol('Parent', gui.Home.Model.Layout_V_Muscle, 'Style', 'list', ...
    'BackgroundColor', 'w',...
    'String', data.MuscleList(:,1),...
    'Min', 1,...
    'Max', length(data.MuscleList),...
    'Callback', @onListSelection_Muscles);
updateMuscleList()

% Reset button
gui.Home.Model.PushButton_ResetMuscle = uicontrol('Parent', gui.Home.Model.Layout_V_Muscle,...
    'Style', 'PushButton',...
    'String', 'Reset',...
    'Callback', @onPushButton_ResetMuscle);

% Adjust layout
set(gui.Home.Model.Layout_V_Muscle, 'Height', [-10, -1])

%% Box panel visualization
gui.Home.Visualization.BoxPanel = uix.BoxPanel('Parent', gui.Home.Layout_V_Mid,...
    'Title', 'Visualization',...
    'FontWeight', 'bold');

gui.Home.Visualization.Layout_V = uix.VBox('Parent', gui.Home.Visualization.BoxPanel, 'Spacing', 3);

% Panel visualization
gui.Home.Visualization.Panel_Visualization = uix.Panel('Parent', gui.Home.Visualization.Layout_V);

gui.Home.Visualization.Axis_Visualization = axes('Parent', gui.Home.Visualization.Panel_Visualization);

data = globalizeTLEM2(data);
visualizeTLEM2(data.S.LE, data.MuscleList, gui.Home.Visualization.Axis_Visualization, 'Muscles', data.activeMuscles);

gui.Home.Visualization.Axis_Visualization.View = [90, 0];
gui.Home.Visualization.Axis_Visualization.CameraUpVector = [0, 1, 0];

% Push buttons
gui.Home.Visualization.Layout_Grid = uix.Grid('Parent', gui.Home.Visualization.Layout_V, 'Spacing', 3);

uicontrol('Parent', gui.Home.Visualization.Layout_Grid, 'Style', 'PushButton',...
    'String', 'Front',  'Callback', @onPushButton_Front);
uicontrol('Parent', gui.Home.Visualization.Layout_Grid, 'Style', 'PushButton',...
    'String', 'Back',   'Callback', @onPushButton_Back);
uicontrol('Parent', gui.Home.Visualization.Layout_Grid, 'Style', 'PushButton',...
    'String', 'Top',    'Callback', @onPushButton_Top);
uicontrol('Parent', gui.Home.Visualization.Layout_Grid, 'Style', 'PushButton',...
    'String', 'Bottom', 'Callback', @onPushButton_Bottom);
uicontrol('Parent', gui.Home.Visualization.Layout_Grid, 'Style', 'PushButton',...
    'String', 'Right',  'Callback', @onPushButton_Right);
uicontrol('Parent', gui.Home.Visualization.Layout_Grid, 'Style', 'PushButton',...
    'String', 'Left',   'Callback', @onPushButton_Left);

% Adjust layout
set(gui.Home.Visualization.Layout_V,    'Height', [-18, -1])
set(gui.Home.Visualization.Layout_Grid, 'Widths', [-1, -1, -1], 'Heights', [-1, -1])

%% Box panel results
gui.Home.Results.BoxPanel = uix.BoxPanel('Parent', gui.Home.Layout_V_Right,...
    'Title', 'Results',...
    'FontWeight', 'bold');

gui.Home.Results.Layout_V        = uix.VBox('Parent', gui.Home.Results.BoxPanel, 'Spacing', 3);
gui.Home.Results.Layout_H_Top    = uix.HBox('Parent', gui.Home.Results.Layout_V, 'Spacing', 3);
gui.Home.Results.Layout_H_Bottom = uix.HBox('Parent', gui.Home.Results.Layout_V, 'Spacing', 3);

% Panel frontal view
gui.Home.Results.Panel_FrontalView = uix.Panel('Parent', gui.Home.Results.Layout_H_Top, 'Title', 'Frontal View');
gui.Home.Results.Axis_FrontalView = axes(gui.Home.Results.Panel_FrontalView);
visualizeTLEM2(data.S.LE, data.MuscleList, gui.Home.Results.Axis_FrontalView,...
    'Bones', find(strcmp({data.S.LE.Name}, data.View)), 'Joints', false, 'Muscles', {});
gui.Home.Results.Axis_FrontalView.View = [90, 0];
gui.Home.Results.Axis_FrontalView.CameraUpVector = [0, 1, 0];

% Panel sagittal view
gui.Home.Results.Panel_SagittalView = uix.Panel('Parent', gui.Home.Results.Layout_H_Top, 'Title', 'Sagittal View');
gui.Home.Results.Axis_SagittalView = axes(gui.Home.Results.Panel_SagittalView);
visualizeTLEM2(data.S.LE, data.MuscleList, gui.Home.Results.Axis_SagittalView,...
    'Bones', find(strcmp({data.S.LE.Name}, data.View)), 'Joints', false, 'Muscles', {});
switch data.S.Side
    case 'R'
        gui.Home.Results.Axis_SagittalView.View = [0, 90];
    case 'L'
        gui.Home.Results.Axis_SagittalView.View = [0, -90];
end
gui.Home.Results.Axis_SagittalView.CameraUpVector = [0, 1, 0];

% Panel transverse view
gui.Home.Results.Panel_TransverseView = uix.Panel('Parent', gui.Home.Results.Layout_H_Top, 'Title', 'Transverse View');
gui.Home.Results.Axis_TransverseView = axes(gui.Home.Results.Panel_TransverseView);

visualizeTLEM2(data.S.LE, data.MuscleList, gui.Home.Results.Axis_TransverseView,...
    'Bones', find(strcmp({data.S.LE.Name}, data.View)), 'Joints', false, 'Muscles', {});
            
switch data.View
    case 'Pelvis'
        DefaultTransverseViewAngle = 0;                    
    case 'Femur'
        DefaultTransverseViewAngle = 180;
end

gui.Home.Results.Axis_TransverseView.View = [0, DefaultTransverseViewAngle];
gui.Home.Results.Axis_TransverseView.CameraUpVector = [1, 0, 0];

% Panel magnitude of force in [N]
gui.Home.Results.Panel_MagnitudeNewton = uix.Panel(...
    'Parent', gui.Home.Results.Layout_H_Bottom,...
    'Title', 'Magnitude of Force [N]');

gui.Home.Results.Label_MagnitudeNewton = uicontrol('Parent', gui.Home.Results.Panel_MagnitudeNewton,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Panel magnitude of force in [%BW]
gui.Home.Results.Panel_MagnitudePercentageBodyWeight = uix.Panel(...
    'Parent', gui.Home.Results.Layout_H_Bottom,...
    'Title', 'Magnitude of Force [%BW]');

gui.Home.Results.Label_MagnitudePercentageBodyWeight = uicontrol('Parent', gui.Home.Results.Panel_MagnitudePercentageBodyWeight,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Panel frontal angle
gui.Home.Results.Panel_FrontalAngle = uix.Panel(...
    'Parent', gui.Home.Results.Layout_H_Bottom,...
    'Title', 'Frontal Angle [°]');

gui.Home.Results.Label_FrontalAngle = uicontrol('Parent', gui.Home.Results.Panel_FrontalAngle,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Panel sagittal angle
gui.Home.Results.Panel_SagittalAngle = uix.Panel(...
    'Parent', gui.Home.Results.Layout_H_Bottom,...
    'Title', 'Sagittal Angle [°]');

gui.Home.Results.Label_SagittalAngle = uicontrol('Parent', gui.Home.Results.Panel_SagittalAngle,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Panel transverse angle
gui.Home.Results.Panel_TransverseAngle = uix.Panel(...
    'Parent', gui.Home.Results.Layout_H_Bottom,...
    'Title', 'Transverse Angle [°]');

gui.Home.Results.Label_TransverseAngle = uicontrol('Parent', gui.Home.Results.Panel_TransverseAngle,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Push button for calculation
gui.IsUpdated = false;

gui.Home.Results.PushButton_RunCalculation = uicontrol('Parent', gui.Home.Results.Layout_H_Bottom,...
    'Style', 'PushButton',...
    'String', 'Run Calculation',...
    'BackgroundColor', 'y',...
    'Callback',@onPushButton_RunCalculation);

gui.Home.Results.Checkbox_Validation = uicontrol('Parent', gui.Home.Results.Layout_H_Bottom,...
    'Style', 'Checkbox',...
    'String', 'and Validation');

% Adjust layout
set(gui.Home.Results.Layout_V,        'Height', [-9, -1])
set(gui.Home.Results.Layout_H_Bottom, 'Width',  [-2, -2, -2, -2, -2, -1.5, -1.5])

%% Adjust home layout
set(gui.Home.Layout_H,       'Width',  [-1, -2, -4])
set(gui.Home.Layout_V_Left,  'Height', [-6, -12])
set(gui.Home.Layout_V_Right, 'Height', [-1, -2])

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                              VALIDATION TAB                             %
%_________________________________________________________________________%

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                                  PANELS                                 %
%_________________________________________________________________________%

gui.Validation.Panel_MagnitudePercentageBodyWeightSingle = uix.Panel('Parent', gui.Validation.Layout_Grid,...
    'Title', 'Magnitude of Force [%BW]',...
    'FontWeight', 'bold');
gui.Validation.Panel_SagittalAngleSingle = uix.Panel('Parent', gui.Validation.Layout_Grid,...
    'Title', 'Sagittal Angle [°]',...
    'FontWeight', 'bold');
gui.Validation.Panel_MagnitudePercentageBodyWeightBoxPlot = uix.Panel('Parent', gui.Validation.Layout_Grid,...
    'Title', 'Boxplot',...
    'FontWeight', 'bold');
gui.Validation.Panel_SagittalAngleBoxPlot = uix.Panel('Parent', gui.Validation.Layout_Grid,...
    'Title', 'Boxplot',...
    'FontWeight', 'bold');
gui.Validation.Panel_FrontalAngleSingle = uix.Panel('Parent', gui.Validation.Layout_Grid,...
    'Title', 'Frontal Angle [°]',...
    'FontWeight', 'bold');
gui.Validation.Panel_TransverseAngleSingle = uix.Panel('Parent', gui.Validation.Layout_Grid,...
    'Title', 'Transverse Angle [°]',...
    'FontWeight', 'bold');
gui.Validation.Panel_FrontalAngleBoxPlot = uix.Panel('Parent', gui.Validation.Layout_Grid,...
    'Title', 'Boxplot',...
    'FontWeight', 'bold');
gui.Validation.Panel_TransverseAngleBoxPlot = uix.Panel('Parent', gui.Validation.Layout_Grid,...
    'Title', 'Boxplot',...
    'FontWeight', 'bold');

gui.Validation.Axis_MagnitudePercentageBodyWeightSingle = axes(gui.Validation.Panel_MagnitudePercentageBodyWeightSingle);
gui.Validation.Axis_SagittalAngleSingle = axes(gui.Validation.Panel_SagittalAngleSingle);
gui.Validation.Axis_MagnitudePercentageBodyWeightBoxPlot = axes(gui.Validation.Panel_MagnitudePercentageBodyWeightBoxPlot);
gui.Validation.Axis_SagittalAngleBoxPlot = axes(gui.Validation.Panel_SagittalAngleBoxPlot);
gui.Validation.Axis_FrontalAngleSingle = axes(gui.Validation.Panel_FrontalAngleSingle);
gui.Validation.Axis_TransverseAngleSingle = axes(gui.Validation.Panel_TransverseAngleSingle);
gui.Validation.Axis_FrontalAngleBoxPlot = axes(gui.Validation.Panel_FrontalAngleBoxPlot);
gui.Validation.Axis_TransverseAngleBoxPlot = axes(gui.Validation.Panel_TransverseAngleBoxPlot);

set(gui.Validation.Layout_Grid, 'Widths', [-2, -1, -2, -1], 'Heights', [-1, -1])

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                           CALLBACK FUNCTIONS                            %
%_________________________________________________________________________%

%% Box panel settings

    function onTLEM2_0(~, ~)
        % User has chosen TLEM 2.0 version
        data = createDataTLEM2(data, 'TLEM2_0');
        data = scaleTLEM2(data);
        updateParameters();
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onTLEM2_1(~, ~)
        % User has chosen TLEM 2.1 version
        data = createDataTLEM2(data, 'TLEM2_1');
        data = scaleTLEM2(data);
        updateParameters();
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onPelvis(~, ~)
        % User has set view to pelvis
        data.View = 'Pelvis';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onFemur(~, ~)
        % User has set view to femur
        data.View = 'Femur';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onScaling(~, ~)
        % User has set femoral transformation to scaling
        data.FemoralTransformation = 'Scaling';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onSkinning(~, ~)
        % User has set femoral transformation to skinning
        data.FemoralTransformation = 'Skinning';
        gui.IsUpdated = false;
        updateHomeTab();
    end

%% Box panel patient specific parameters

    function onLeftSide(~, ~)
        % User has set side to left
        data.S.Side = 'L';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onRightSide(~, ~)
        % User has set side to right
        data.S.Side = 'R';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_BodyWeight(scr, ~)
        % User has edited the body weight
        data.S.BodyWeight = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_HipJointWidth(scr, ~)
        % User has edited the hip joint width
        data.S.Scale(1).HipJointWidth = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PelvicBend(scr, ~)
        % User has edited the pelvic bend
        data.S.PelvicBend = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PelvicWidth(scr, ~)
        % User has edited the pelvic width
        data.S.Scale(1).PelvicWidth = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PelvicHeight(scr, ~)
        % User has edited the pelvic height
        data.S.Scale(1).PelvicHeight = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PelvicDepth(scr, ~)
        % User has edited the pelvic depth
        data.S.Scale(1).PelvicDepth = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_FemoralLength(scr, ~)
        % User has edited the femoral length
        data.S.Scale(2).FemoralLength = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_FemoralVersion(scr, ~)
        % User has edited the femoral version
        data.S.Scale(2).FemoralVersion = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_CCD(scr, ~)
        % User has edited the CCD angle
        data.S.Scale(2).CCD = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_NeckLength(scr, ~)
        % User has edited the neck length
        data.S.Scale(2).NeckLength = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onPushButton_ResetParameters(~, ~)
        data.S.Side = data.T.Side;
        data.S.BodyWeight = data.T.BodyWeight;
        data.S.PelvicBend = data.T.PelvicBend;
        data.S.Scale = data.T.Scale;
        updateParameters();
        gui.IsUpdated = false;
        updateHomeTab();
    end

%% Box panel model

    function onListSelection_Posture(src, ~)
        % User has selected a posture from the list
        data.Model = models{get(src, 'Value')};
        gui.IsUpdated = false;
        updatePosture();
        updateHomeTab();
    end

    function onListSelection_Muscles(src, ~)
        % User has selected muscles from the list
        tempMuscleIdx = get(src, 'Value');
        tempMuscles = data.MuscleList(tempMuscleIdx,[1,4]);
        tempFascicles = {};
        for m = 1:size(tempMuscles,1)
            tempFascicles = [tempFascicles;...
                cellstr(num2str((1:tempMuscles{m,2})', [tempMuscles{m,1} '%d']))];
        end
        data.activeMuscles = tempFascicles;
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onPushButton_ResetMuscle(~, ~)
        [data.activeMuscles, gui.Home.Model.MuscleListEnable] = gui.Home.Model.modelHandle.Muscles();
        gui.IsUpdated = false;
        updateHomeTab();
    end

%% Box panel visualization

    function onPushButton_Front(~, ~)
        gui.Home.Visualization.Axis_Visualization.View = [90 ,0];
        gui.Home.Visualization.Axis_Visualization.CameraUpVector = [0, 1, 0];
    end

    function onPushButton_Back(~, ~)
        gui.Home.Visualization.Axis_Visualization.View = [-90, 0];
        gui.Home.Visualization.Axis_Visualization.CameraUpVector = [0, 1, 0];
    end

    function onPushButton_Top(~, ~)
        gui.Home.Visualization.Axis_Visualization.View = [0, 180];
        gui.Home.Visualization.Axis_Visualization.CameraUpVector = [1, 0, 0];
    end

    function onPushButton_Left(~, ~)
        gui.Home.Visualization.Axis_Visualization.View = [0, -90];
        gui.Home.Visualization.Axis_Visualization.CameraUpVector = [0, 1, 0];
    end

    function onPushButton_Right(~, ~)
        gui.Home.Visualization.Axis_Visualization.View = [0, 90];
        gui.Home.Visualization.Axis_Visualization.CameraUpVector = [0, 1, 0];
    end

    function onPushButton_Bottom(~, ~)
        gui.Home.Visualization.Axis_Visualization.View = [0, 0];
        gui.Home.Visualization.Axis_Visualization.CameraUpVector = [1, 0, 0];
    end

%% Box panel results

    function onPushButton_RunCalculation(~, ~)
        % User has pressed the run calculation button
        set(gui.Home.Results.PushButton_RunCalculation, 'BackgroundColor', 'r', 'Enable', 'off');
        
        % Validtion with OrthoLoad data
        if gui.Home.Results.Checkbox_Validation.Value == 1
            data.View = 'Femur';
            updateHipJointForceView();
            data.Results = validateTLEM2(data, gui);
            writetable(struct2table(data.Results), 'Results.xlsx')
            updateValidationTab();
        end

        % Calculation with inserted data
        data = gui.Home.Model.modelHandle.Calculation(data); % !!! Review: If validation was run this is not the inserted data anymore
        
        gui.IsUpdated = true;
        updateResults();
        drawnow
    end

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                             UPDATE FUNCTIONS                            %
%_________________________________________________________________________%

%% Home tab

    function updateHomeTab()
        updateTLEMversion();
        updateHipJointForceView();
        updateFemoralTransformation();
        updateSide();
        updateMuscleList();
        updateVisualization();
        updateResults();
    end

%% Box panel settings

    function updateTLEMversion()
        set(gui.Home.Settings.RadioButton_TLEM2_0, 'Value', 0);
        set(gui.Home.Settings.RadioButton_TLEM2_1, 'Value', 0);
        switch data.TLEMversion
            case 'TLEM2_0'
                set(gui.Home.Settings.RadioButton_TLEM2_0, 'Value', 1);
            case 'TLEM2_1'
                set(gui.Home.Settings.RadioButton_TLEM2_1, 'Value', 1);
        end
    end

    function updateHipJointForceView()
        set(gui.Home.Settings.RadioButton_Pelvis, 'Value', 0);
        set(gui.Home.Settings.RadioButton_Femur,  'Value', 0);
        switch data.View
            case 'Pelvis'
                set(gui.Home.Settings.RadioButton_Pelvis, 'Value', 1);
            case 'Femur'
                set(gui.Home.Settings.RadioButton_Femur,  'Value', 1);
        end
    end

    function updateFemoralTransformation()
        set(gui.Home.Settings.RadioButton_Scaling,  'Value', 0);
        set(gui.Home.Settings.RadioButton_Skinning, 'Value', 0);
        switch data.FemoralTransformation
            case 'Scaling'
                set(gui.Home.Settings.RadioButton_Scaling,  'Value', 1);
                set([gui.Home.Parameters.EditText_FemoralVersion,...
                     gui.Home.Parameters.EditText_CCD,...
                     gui.Home.Parameters.EditText_NeckLength], 'Enable', 'off');
            case 'Skinning'
                set(gui.Home.Settings.RadioButton_Skinning, 'Value', 1);
                set([gui.Home.Parameters.EditText_FemoralVersion,...
                     gui.Home.Parameters.EditText_CCD,...
                     gui.Home.Parameters.EditText_NeckLength], 'Enable', 'on');
        end
    end

%% Box panel patient specific parameters

    function updateSide()
        set(gui.Home.Parameters.RadioButton_L, 'Value', 0);
        set(gui.Home.Parameters.RadioButton_R, 'Value', 0);
        switch data.S.Side
            case 'L'
                set(gui.Home.Parameters.RadioButton_L, 'Value', 1);
            case 'R'
                set(gui.Home.Parameters.RadioButton_R, 'Value', 1);
        end
    end

    function updateParameters()
        set(gui.Home.Parameters.EditText_BodyWeight,     'String', data.S.BodyWeight);
        set(gui.Home.Parameters.EditText_HipJointWidth,  'String', data.S.Scale(1).HipJointWidth);
        set(gui.Home.Parameters.EditText_PelvicBend,     'String', data.S.PelvicBend);
        set(gui.Home.Parameters.EditText_PelvicWidth,    'String', data.S.Scale(1).PelvicWidth);
        set(gui.Home.Parameters.EditText_PelvicHeight,   'String', data.S.Scale(1).PelvicHeight);
        set(gui.Home.Parameters.EditText_PelvicDepth,    'String', data.S.Scale(1).PelvicDepth);
        set(gui.Home.Parameters.EditText_FemoralLength,  'String', data.S.Scale(2).FemoralLength);        
        set(gui.Home.Parameters.EditText_FemoralVersion, 'String', data.S.Scale(2).FemoralVersion);        
        set(gui.Home.Parameters.EditText_CCD,            'String', data.S.Scale(2).CCD);        
        set(gui.Home.Parameters.EditText_NeckLength,     'String', data.S.Scale(2).NeckLength);
    end

%% Box panel model

    function updatePosture()
        calculateTLEM2 = str2func(data.Model);
        gui.Home.Model.modelHandle = calculateTLEM2();
        [data.activeMuscles, gui.Home.Model.MuscleListEnable] = gui.Home.Model.modelHandle.Muscles();
    end

    function updateMuscleList()
        % Get the indices of the muscles used in the current model
        mListValues = find(ismember(data.MuscleList(:,1), unique(cellfun(@(x)...
            regexp(x,'\D+','match'), data.activeMuscles(:,1)))));
        gui.Home.Model.ListBox_MuscleList.Value = mListValues;
        gui.Home.Model.ListBox_MuscleList.Enable = gui.Home.Model.MuscleListEnable;
    end

%% Box panel visualization

    function updateVisualization()
        data = scaleTLEM2(data);
        data = globalizeTLEM2(data);
        delete(gui.Home.Visualization.Axis_Visualization.Children);
        visualizeTLEM2(data.S.LE, data.MuscleList, gui.Home.Visualization.Axis_Visualization, 'Muscles', data.activeMuscles);
    end

%% Box panel results

    function updateResults
        % Plot hip joint force vector
        if gui.IsUpdated
            
            delete([gui.Home.Results.Axis_FrontalView   .Children,...
                    gui.Home.Results.Axis_SagittalView  .Children,...
                    gui.Home.Results.Axis_TransverseView.Children])
            
            visualizeTLEM2(data.S.LE, data.MuscleList, gui.Home.Results.Axis_FrontalView,...
                'Bones', find(strcmp({data.S.LE.Name}, data.View)), 'Joints', false, 'Muscles', {});
            visualizeTLEM2(data.S.LE, data.MuscleList, gui.Home.Results.Axis_SagittalView,...
                'Bones', find(strcmp({data.S.LE.Name}, data.View)), 'Joints', false, 'Muscles', {});
            visualizeTLEM2(data.S.LE, data.MuscleList, gui.Home.Results.Axis_TransverseView,...
                'Bones', find(strcmp({data.S.LE.Name}, data.View)), 'Joints', false, 'Muscles', {});
            
            gui.Home.Results.Axis_FrontalView.View = [90 ,0];
            gui.Home.Results.Axis_FrontalView.CameraUpVector = [0, 1, 0];
                    
            switch data.S.Side
                case 'R'
                    gui.Home.Results.Axis_SagittalView.View = [0, 90];
                case 'L'
                    gui.Home.Results.Axis_SagittalView.View = [0, -90];
            end
            gui.Home.Results.Axis_SagittalView.CameraUpVector = [0, 1, 0];
            
            switch data.View
                case 'Pelvis'
                    TransverseViewAngle = 0;                    
                case 'Femur'
                    TransverseViewAngle = 180;
            end
            gui.Home.Results.Axis_TransverseView.View = [0, TransverseViewAngle];
            gui.Home.Results.Axis_TransverseView.CameraUpVector = [1, 0, 0];
            
            quiver3D(gui.Home.Results.Axis_FrontalView,    -data.rDir*75, data.rDir*55, 'r')
            quiver3D(gui.Home.Results.Axis_SagittalView,   -data.rDir*75, data.rDir*55, 'r')
            quiver3D(gui.Home.Results.Axis_TransverseView, -data.rDir*75, data.rDir*55, 'r')
        
            set(gui.Home.Results.Label_MagnitudeNewton,               'String',     data.rMag);
            set(gui.Home.Results.Label_MagnitudePercentageBodyWeight, 'String',     data.rMagP);
            set(gui.Home.Results.Label_FrontalAngle,                  'String', abs(data.rPhi));
            set(gui.Home.Results.Label_SagittalAngle,                 'String', abs(data.rTheta));
            set(gui.Home.Results.Label_TransverseAngle,               'String', abs(data.rAlpha));     
        
            % Disable push button
            set(gui.Home.Results.PushButton_RunCalculation, 'BackgroundColor', 'g', 'Enable', 'off');
        else
            set(gui.Home.Results.PushButton_RunCalculation, 'BackgroundColor', 'y', 'Enable', 'on');
        end
    end

%% Update validation tab

    function updateValidationTab
        NoS = length(data.Results);
%         delete([gui.Validation.Axis_MagnitudePercentageBodyWeightSingle.Children, gui.Validation.Axis_FrontalAngleSingle.Children,...
%             gui.Validation.Axis_SagittalAngleSingle.Children, gui.Validation.Axis_TransverseAngleSingle.Children]);   
        [gui.Validation.Axis_MagnitudePercentageBodyWeightSingle.XTick, gui.Validation.Axis_FrontalAngleSingle.XTick,...
            gui.Validation.Axis_SagittalAngleSingle.XTick, gui.Validation.Axis_TransverseAngleSingle.XTick] = deal(1:length(data.Results));   
        [gui.Validation.Axis_MagnitudePercentageBodyWeightSingle.XTickLabel, gui.Validation.Axis_FrontalAngleSingle.XTickLabel,...
            gui.Validation.Axis_SagittalAngleSingle.XTickLabel, gui.Validation.Axis_TransverseAngleSingle.XTickLabel] = deal({data.Results.Subject}); 
        [gui.Validation.Axis_MagnitudePercentageBodyWeightSingle.XLim, gui.Validation.Axis_FrontalAngleSingle.XLim,...
            gui.Validation.Axis_SagittalAngleSingle.XLim, gui.Validation.Axis_TransverseAngleSingle.XLim] = deal([0.5, length(data.Results) + 0.5]);

        markerProps.Marker = 'x';
        markerProps.Markersize = 7;
        
        % Panel magnitude of force in [%BW]
        hold (gui.Validation.Axis_MagnitudePercentageBodyWeightSingle, 'on')
        drawPoint(gui.Validation.Axis_MagnitudePercentageBodyWeightSingle, 1:NoS, [data.Results(:).rMagP],   'color', 'b', markerProps)
        drawPoint(gui.Validation.Axis_MagnitudePercentageBodyWeightSingle, 1:NoS, [data.Results(:).OrrMagP], 'color', 'g', markerProps)
        S.rMagP.mean = mean([data.Results(:).rMagP]);
        O.rMagP.mean = mean([data.Results(:).OrrMagP]);
        plot(gui.Validation.Axis_MagnitudePercentageBodyWeightSingle, [1,NoS], [S.rMagP.mean,S.rMagP.mean], 'color', 'b')
        plot(gui.Validation.Axis_MagnitudePercentageBodyWeightSingle, [1,NoS], [O.rMagP.mean,O.rMagP.mean], 'color', 'g')
        
        % Panel frontal angle
        hold (gui.Validation.Axis_FrontalAngleSingle, 'on')
        drawPoint(gui.Validation.Axis_FrontalAngleSingle, 1:NoS, [data.Results(:).rPhi],  'color', 'b', markerProps)
        drawPoint(gui.Validation.Axis_FrontalAngleSingle, 1:NoS, [data.Results(:).OrPhi], 'color', 'g', markerProps)
        S.rPhi.mean = mean([data.Results(:).rPhi]);
        O.rPhi.mean = mean([data.Results(:).OrPhi]);
        plot(gui.Validation.Axis_FrontalAngleSingle, [1,NoS], [S.rPhi.mean,S.rPhi.mean], 'color', 'b')
        plot(gui.Validation.Axis_FrontalAngleSingle, [1,NoS], [O.rPhi.mean,O.rPhi.mean], 'color', 'g')
        
        % Panel sagittal angle
        hold (gui.Validation.Axis_SagittalAngleSingle, 'on')
        drawPoint(gui.Validation.Axis_SagittalAngleSingle, 1:NoS, [data.Results(:).rTheta],  'color', 'b', markerProps)
        drawPoint(gui.Validation.Axis_SagittalAngleSingle, 1:NoS, [data.Results(:).OrTheta], 'color', 'g', markerProps)
        S.rTheta.mean = mean([data.Results(:).rTheta]);
        O.rTheta.mean = mean([data.Results(:).OrTheta]);
        plot(gui.Validation.Axis_SagittalAngleSingle, [1,NoS], [S.rTheta.mean,S.rTheta.mean], 'color', 'b')
        plot(gui.Validation.Axis_SagittalAngleSingle, [1,NoS], [O.rTheta.mean,O.rTheta.mean], 'color', 'g')
        
        % Panel transverse angle
        hold (gui.Validation.Axis_TransverseAngleSingle, 'on')
        drawPoint(gui.Validation.Axis_TransverseAngleSingle, 1:NoS, [data.Results(:).rAlpha],  'color', 'b', markerProps)
        drawPoint(gui.Validation.Axis_TransverseAngleSingle, 1:NoS, [data.Results(:).OrAlpha], 'color', 'g', markerProps)
        S.rAlpha.mean = mean([data.Results(:).rAlpha]);
        O.rAlpha.mean = mean([data.Results(:).OrAlpha]);
        plot(gui.Validation.Axis_TransverseAngleSingle, [1,NoS], [S.rAlpha.mean,S.rAlpha.mean], 'color', 'b')
        plot(gui.Validation.Axis_TransverseAngleSingle, [1,NoS], [O.rAlpha.mean,O.rAlpha.mean], 'color', 'g')
        
        % Boxplots
        boxplot(gui.Validation.Axis_MagnitudePercentageBodyWeightBoxPlot,[[data.Results(:).OrrMagP]',[data.Results(:).rMagP]'],{'In-vivo','Simulated'})
        boxplot(gui.Validation.Axis_FrontalAngleBoxPlot,[[data.Results(:).OrPhi]',[data.Results(:).rPhi]'],{'In-vivo','Simulated'})
        boxplot(gui.Validation.Axis_SagittalAngleBoxPlot,[[data.Results(:).OrTheta]',[data.Results(:).rTheta]'],{'In-vivo','Simulated'})
        boxplot(gui.Validation.Axis_TransverseAngleBoxPlot,[[data.Results(:).OrAlpha]',[data.Results(:).rAlpha]'],{'In-vivo','Simulated'})
    end

end