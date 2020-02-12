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

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
%                                 HOME TAB                                %
%_________________________________________________________________________%

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
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

% Panel muscle path design
gui.Home.Settings.Panel_MusclePath = uix.Panel('Parent', gui.Home.Settings.Layout_V,...
    'Title', 'Design Muscle Paths per');

gui.Home.Settings.RadioButtonBox_MusclePath = uix.VButtonBox('Parent', gui.Home.Settings.Panel_MusclePath,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left',...
    'ButtonSize', [200 20]);

gui.Home.Settings.RadioButton_StraightLine = uicontrol('Parent', gui.Home.Settings.RadioButtonBox_MusclePath,...
    'Style', 'radiobutton',...
    'String', 'Straight Line Model',...
    'Callback', @onStraightLine);

gui.Home.Settings.RadioButton_ViaPoint = uicontrol('Parent', gui.Home.Settings.RadioButtonBox_MusclePath,...
    'Style', 'radiobutton',...
    'String', 'Via Point Model',...
    'Callback', @onViaPoint);

gui.Home.Settings.RadioButton_ObstacleSet = uicontrol('Parent', gui.Home.Settings.RadioButtonBox_MusclePath,...
    'Style', 'radiobutton',...
    'String', 'Obstacle Set Method',...
    'Callback', @onObstacleSet);

set(gui.Home.Settings.(['RadioButton_' data.MusclePath]), 'Value', 1)

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

% Panel body height
gui.Home.Parameters.Panel_BodyHeight = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Body Height [cm]');

gui.Home.Parameters.EditText_BodyHeight = uicontrol('Parent', gui.Home.Parameters.Panel_BodyHeight,...
    'Style', 'edit',...
    'String', data.T.BodyHeight,...
    'Callback', @onEditText_BodyHeight);

% Panel hip joint width
gui.Home.Parameters.Panel_HipJointWidth = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Hip Joint Width [mm]');

gui.Home.Parameters.EditText_HipJointWidth = uicontrol('Parent', gui.Home.Parameters.Panel_HipJointWidth,...
    'Style', 'edit',...
    'String', data.T.Scale(1).HipJointWidth,...
    'Callback', @onEditText_HipJointWidth);

% Panel pelvic tilt
gui.Home.Parameters.Panel_PelvicTilt = uix.Panel('Parent', gui.Home.Parameters.Layout_V,...
    'Title', 'Pelvic Tilt [°]');

gui.Home.Parameters.EditText_PelvicTilt = uicontrol('Parent', gui.Home.Parameters.Panel_PelvicTilt,...
    'Style', 'edit',...
    'String', data.T.PelvicTilt,...
    'Callback', @onEditText_PelvicTilt);

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
set(gui.Home.Parameters.Layout_V, 'Height', [-2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -0.6])

%% Box panel model
gui.Home.Model.BoxPanel = uix.BoxPanel('Parent', gui.Home.Layout_V_Right,...
    'Title', 'Model',...
    'FontWeight', 'bold');

gui.Home.Model.Layout_H = uix.HBox('Parent', gui.Home.Model.BoxPanel,...
    'Spacing', 3);

gui.Home.Model.Layout_V = uix.VBox('Parent', gui.Home.Model.Layout_H,...
    'Spacing', 3);

% Panel model
gui.Home.Model.Panel_Model = uix.Panel('Parent', gui.Home.Model.Layout_V,...
    'Title', 'Model');

% Get models
models = dir('src\models\*.m');
defaultModel=1;
[~, models] = arrayfun(@(x) fileparts(x.name), models, 'uni', 0);
data.Model = models{defaultModel};
postures ={}; default=nan;
updateModel()
gui.Home.Model.ListBox_Model = uicontrol( 'Parent', gui.Home.Model.Panel_Model,...
    'BackgroundColor', 'w',...
    'Style', 'list',...
    'String', models,...
    'Value', defaultModel,...
    'Callback', @onListSelection_Model);

% Panel posture
gui.Home.Model.Panel_Posture = uix.Panel('Parent', gui.Home.Model.Layout_V,...
    'Title', 'Posture');

% Get postures
gui.Home.Model.ListBox_Posture = uicontrol( 'Parent', gui.Home.Model.Panel_Posture,...
    'BackgroundColor', 'w',...
    'Style', 'list',...
    'String', postures(:,1),...
    'Value', default,...
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

data = scaleTLEM2(data);
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
gui.Home.Results.Axis_TransverseView.CameraUpVector = [-1, 0, 0];

% Panel post. ant. HJF [%BW]
gui.Home.Results.Panel_post_antHJFpercBW = uix.Panel(...
    'Parent', gui.Home.Results.Layout_H_Bottom,...
    'Title', 'post. ant. HJF [%BW]');
gui.Home.Results.Label_post_antHJFpercBW = uicontrol('Parent', gui.Home.Results.Panel_post_antHJFpercBW,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Panel inf. sup. HJF [%BW]
gui.Home.Results.Panel_inf_supHJFpercBW = uix.Panel(...
    'Parent', gui.Home.Results.Layout_H_Bottom,...
    'Title', 'inf. sup. HJF [%BW]');
gui.Home.Results.Label_inf_supHJFpercBW = uicontrol('Parent', gui.Home.Results.Panel_inf_supHJFpercBW,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Panel med. lat. HJF [%BW]
gui.Home.Results.Panel_med_latHJFpercBW = uix.Panel(...
    'Parent', gui.Home.Results.Layout_H_Bottom,...
    'Title', 'med. lat. HJF [%BW]');
gui.Home.Results.Label_med_latHJFpercBW = uicontrol('Parent', gui.Home.Results.Panel_med_latHJFpercBW,...
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
set(gui.Home.Results.Layout_H_Bottom, 'Width',  [-1, -1, -1, -1, -1, -1, -0.75, -0.75])

%% Adjust home layout
set(gui.Home.Layout_H,       'Width',  [-1, -2, -4])
set(gui.Home.Layout_V_Left,  'Height', [-8, -12])
set(gui.Home.Layout_V_Right, 'Height', [-1, -2])

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
%                              VALIDATION TAB                             %
%_________________________________________________________________________%

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
%                                  PANELS                                 %
%_________________________________________________________________________%

gui.Validation.Panel.post_antHJFpercBWsingle = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'posterior anterior HJF [%BW]', 'FontWeight','bold');
gui.Validation.Panel.SagittalAngleSingle = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'Sagittal Angle [°]','FontWeight', 'bold');
gui.Validation.Panel.post_antHJFpercBWBoxPlot = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'posterior anterior HJF [%BW]', 'FontWeight','bold');
gui.Validation.Panel.SagittalAngleBoxPlot = uix.Panel('Parent', gui.Validation.Layout_Grid,...
    'Title', 'Sagittal Angle [°]','FontWeight', 'bold');
gui.Validation.Panel.inf_supHJFpercBWsingle = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'inferior superior HJF [%BW]', 'FontWeight','bold');
gui.Validation.Panel.FrontalAngleSingle = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'Frontal Angle [°]', 'FontWeight','bold');
gui.Validation.Panel.inf_supHJFpercBWBoxPlot = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'inferior superior HJF [%BW]', 'FontWeight','bold');
gui.Validation.Panel.FrontalAngleBoxPlot = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'Frontal Angle [°]','FontWeight', 'bold');
gui.Validation.Panel.med_latHJFpercBWsingle = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'medial lateral HJF [%BW]', 'FontWeight','bold');
gui.Validation.Panel.TransverseAngleSingle = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'Transverse Angle [°]','FontWeight','bold');
gui.Validation.Panel.med_latHJFpercBWBoxPlot = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'medial lateral HJF [%BW]', 'FontWeight','bold');
gui.Validation.Panel.TransverseAngleBoxPlot = uix.Panel('Parent',gui.Validation.Layout_Grid,...
    'Title', 'Transverse Angle [°]', 'FontWeight','bold');

gui.Validation.Axes.post_antHJFpercBWsingle = axes(gui.Validation.Panel.post_antHJFpercBWsingle);
gui.Validation.Axes.SagittalAngleSingle = axes(gui.Validation.Panel.SagittalAngleSingle);
gui.Validation.Axes.post_antHJFpercBWBoxPlot = axes(gui.Validation.Panel.post_antHJFpercBWBoxPlot);
gui.Validation.Axes.SagittalAngleBoxPlot = axes(gui.Validation.Panel.SagittalAngleBoxPlot);
gui.Validation.Axes.inf_supHJFpercBWsingle = axes(gui.Validation.Panel.inf_supHJFpercBWsingle);
gui.Validation.Axes.FrontalAngleSingle = axes(gui.Validation.Panel.FrontalAngleSingle);
gui.Validation.Axes.inf_supHJFpercBWBoxPlot = axes(gui.Validation.Panel.inf_supHJFpercBWBoxPlot);
gui.Validation.Axes.FrontalAngleBoxPlot = axes(gui.Validation.Panel.FrontalAngleBoxPlot);
gui.Validation.Axes.med_latHJFpercBWsingle = axes(gui.Validation.Panel.med_latHJFpercBWsingle);
gui.Validation.Axes.TransverseAngleSingle = axes(gui.Validation.Panel.TransverseAngleSingle);
gui.Validation.Axes.med_latHJFpercBWBoxPlot = axes(gui.Validation.Panel.med_latHJFpercBWBoxPlot);
gui.Validation.Axes.TransverseAngleBoxPlot = axes(gui.Validation.Panel.TransverseAngleBoxPlot);

set(gui.Validation.Layout_Grid, 'Widths', [-2, -1, -2, -1, -2, -1], 'Heights', [-1, -1])

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
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

    function onStraightLine(~, ~)
        % User has set the muscle path model to straight line
        data.MusclePath = 'StraightLine';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onViaPoint(~, ~)
        % User has set the muscle path model to via point
        data.MusclePath = 'ViaPoint';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onObstacleSet(~, ~)
        % User has set the muscle path model to obstacle set
        data.MusclePath = 'ObstacleSet';
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

    function onEditText_BodyHeight(scr, ~)
        % User has edited the body height
        data.S.BodyHeight = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_HipJointWidth(scr, ~)
        % User has edited the hip joint width
        data.S.Scale(1).HipJointWidth = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PelvicTilt(scr, ~)
        % User has edited the pelvic tilt
        data.S.PelvicTilt = str2double(get(scr, 'String'));
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
        data.S.PelvicTilt = data.T.PelvicTilt;
        data.S.Scale = data.T.Scale;
        updateParameters();
        gui.IsUpdated = false;
        updateHomeTab();
    end

%% Box panel model

    function onListSelection_Model(src, ~)
        % User has selected a model from the list
        data.Model = models{get(src, 'Value')};
        gui.IsUpdated = false;
        updateModel();
        updateHomeTab();
    end

    function onListSelection_Posture(src, ~)
        % User has selected a posture from the list
        data.Posture = postures{get(src, 'Value'), 2};
        gui.IsUpdated = false;
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
        [data.activeMuscles, gui.Home.Model.MuscleListEnable] = gui.Home.Model.modelHandle.Muscles(gui);
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
        data = gui.Home.Model.modelHandle.Calculation(data);
        
        gui.IsUpdated = true;
        updateResults();
        drawnow
    end

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
%                             UPDATE FUNCTIONS                            %
%_________________________________________________________________________%

%% Home tab

    function updateHomeTab()
        updateTLEMversion();
        updateHipJointForceView();
        updateFemoralTransformation();
        updateMusclePath();
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

    function updateMusclePath()
        set(gui.Home.Settings.RadioButton_StraightLine, 'Value', 0);
        set(gui.Home.Settings.RadioButton_ViaPoint, 'Value', 0);
        set(gui.Home.Settings.RadioButton_ObstacleSet, 'Value', 0);
        switch data.MusclePath
            case 'StraightLine'
                set(gui.Home.Settings.RadioButton_StraightLine, 'Value', 1);
            case 'ViaPoint'
                set(gui.Home.Settings.RadioButton_ViaPoint, 'Value', 1);
            case 'ObstacleSet'
                set(gui.Home.Settings.RadioButton_ObstacleSet, 'Value', 1);
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
        set(gui.Home.Parameters.EditText_PelvicTilt,     'String', data.S.PelvicTilt);
        set(gui.Home.Parameters.EditText_PelvicWidth,    'String', data.S.Scale(1).PelvicWidth);
        set(gui.Home.Parameters.EditText_PelvicHeight,   'String', data.S.Scale(1).PelvicHeight);
        set(gui.Home.Parameters.EditText_PelvicDepth,    'String', data.S.Scale(1).PelvicDepth);
        set(gui.Home.Parameters.EditText_FemoralLength,  'String', data.S.Scale(2).FemoralLength);        
        set(gui.Home.Parameters.EditText_FemoralVersion, 'String', data.S.Scale(2).FemoralVersion);        
        set(gui.Home.Parameters.EditText_CCD,            'String', data.S.Scale(2).CCD);        
        set(gui.Home.Parameters.EditText_NeckLength,     'String', data.S.Scale(2).NeckLength);
    end

%% Box panel model

    function updateModel()
        calculateTLEM2 = str2func(data.Model);
        gui.Home.Model.modelHandle = calculateTLEM2();
        [data.activeMuscles, gui.Home.Model.MuscleListEnable] = gui.Home.Model.modelHandle.Muscles(gui);
        % Set muscle path model to straight line
        data.MusclePath = 'StraightLine';
        updateMusclePath();
        [postures, default] = gui.Home.Model.modelHandle.Posture();
        data.Posture = postures(default, 2);
        if isfield(gui.Home.Model, 'ListBox_Posture') == 1
            set(gui.Home.Model.ListBox_Posture, 'String', postures(:,1), 'Value', default);
        end
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
            gui.Home.Results.Axis_TransverseView.CameraUpVector = [-1, 0, 0];
            
            quiver3D(gui.Home.Results.Axis_FrontalView,    -data.rDir*75, data.rDir*55, 'r')
            quiver3D(gui.Home.Results.Axis_SagittalView,   -data.rDir*75, data.rDir*55, 'r')
            quiver3D(gui.Home.Results.Axis_TransverseView, -data.rDir*75, data.rDir*55, 'r')
        
            set(gui.Home.Results.Label_post_antHJFpercBW,  'String', round(data.rX));
            set(gui.Home.Results.Label_inf_supHJFpercBW,   'String', round(data.rY));
            set(gui.Home.Results.Label_med_latHJFpercBW,   'String', round(data.rZ));
            set(gui.Home.Results.Label_FrontalAngle,       'String', abs(data.rPhi));
            set(gui.Home.Results.Label_SagittalAngle,      'String', abs(data.rTheta));
            set(gui.Home.Results.Label_TransverseAngle,    'String', abs(data.rAlpha));     
        
            % Disable push button
            set(gui.Home.Results.PushButton_RunCalculation, 'BackgroundColor', 'g', 'Enable', 'off');
        else
            set(gui.Home.Results.PushButton_RunCalculation, 'BackgroundColor', 'y', 'Enable', 'on');
        end
    end

%% Update validation tab

    function updateValidationTab
        % Reset x axes
        structfun(@(x) delete(x.Children), gui.Validation.Axes)
        structfun(@(x) set(x,'XTick',1:length(data.Results)), gui.Validation.Axes)
        structfun(@(x) set(x,'XTickLabel',{data.Results.Subject}), gui.Validation.Axes)
        structfun(@(x) set(x,'XLim',[0.5, length(data.Results) + 0.5]), gui.Validation.Axes)

        markerProps.Marker = 'x';
        markerProps.Markersize = 7;
        
        
        invivo=reshape([data.Results.OL_R_pBW],[3,10])';
        simulated=reshape([data.Results.R_pBW],[3,10])';
        % Panel posterior anterior HJF [%BW]
        
        plotValidationResults(gui.Validation.Axes.post_antHJFpercBWsingle,...
            gui.Validation.Axes.post_antHJFpercBWBoxPlot,invivo(:,1),simulated(:,1))
        % Panel inferior superior HJF [%BW]
        plotValidationResults(gui.Validation.Axes.inf_supHJFpercBWsingle,...
            gui.Validation.Axes.inf_supHJFpercBWBoxPlot,invivo(:,2),simulated(:,2))
        % Panel medial lateral HJF [%BW]
        plotValidationResults(gui.Validation.Axes.med_latHJFpercBWsingle,...
            gui.Validation.Axes.med_latHJFpercBWBoxPlot,invivo(:,3),simulated(:,3))
        
        % Panel sagittal angle
        plotValidationResults(gui.Validation.Axes.SagittalAngleSingle,...
            gui.Validation.Axes.SagittalAngleBoxPlot,...
            [data.Results(:).OL_Theta]',[data.Results(:).rTheta]')
        % Panel frontal angle
        plotValidationResults(gui.Validation.Axes.FrontalAngleSingle,...
            gui.Validation.Axes.FrontalAngleBoxPlot,...
            [data.Results(:).OL_Phi]',[data.Results(:).rPhi]')
        % Panel transverse angle
        plotValidationResults(gui.Validation.Axes.TransverseAngleSingle,...
            gui.Validation.Axes.TransverseAngleBoxPlot,...
            [data.Results(:).OL_Alpha]',[data.Results(:).rAlpha]')
        
        function plotValidationResults(singleHandle, boxPlotHandle, invivo, simulated)
            hold(singleHandle,'on');
            drawPoint(singleHandle, 1:length(invivo),    invivo,    'color', 'g', markerProps)
            drawPoint(singleHandle, 1:length(simulated), simulated, 'color', 'b', markerProps)
            plot(singleHandle, [1,length(simulated)], [median(simulated),median(simulated)], 'color', 'b')
            plot(singleHandle, [1,length(invivo)],    [median(invivo),median(invivo)],       'color', 'g')
            boxplot(boxPlotHandle,[invivo, simulated],{'In-vivo','Simulated'},'notch','on')
            boxPlotHandle.YLim=singleHandle.YLim;
            boxPlotHandle.YTick=singleHandle.YTick;
            boxPlotHandle.YTickLabel=singleHandle.YTickLabel;
        end
    end

end