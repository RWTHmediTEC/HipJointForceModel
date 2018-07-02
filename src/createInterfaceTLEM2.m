function gui = createInterfaceTLEM2(data)

% Create GUI
gui.Window = figure(...
    'Name', 'Hip Joint Reaction Force Model',...
    'NumberTitle', 'off',...
    'MenuBar', 'figure',...
    'Toolbar', 'figure');

monitorsPosition = get(0,'MonitorPositions');
if     size(monitorsPosition,1) == 1
    set(gui.Window,'OuterPosition',monitorsPosition(1,:));
elseif size(monitorsPosition,1) == 2
    set(gui.Window,'OuterPosition',monitorsPosition(2,:));
end

gui.Tabs = uiextras.TabPanel('Parent', gui.Window, 'TabSize', 100);

% Create Home Tab
gui.Layout_Home_Main_H       = uix.HBox('Parent', gui.Tabs,               'Spacing', 3);
gui.Layout_Home_Main_V_Left  = uix.VBox('Parent', gui.Layout_Home_Main_H, 'Spacing', 3);
gui.Layout_Home_Main_V_Mid   = uix.VBox('Parent', gui.Layout_Home_Main_H, 'Spacing', 3);
gui.Layout_Home_Main_V_Right = uix.VBox('Parent', gui.Layout_Home_Main_H, 'Spacing', 3);

% Create Validation Tab
gui.Layout_Validation_Main_H       = uix.HBox('Parent', gui.Tabs,                     'Spacing', 3);
gui.Layout_Validation_Main_V_Left  = uix.VBox('Parent', gui.Layout_Validation_Main_H, 'Spacing', 3);
gui.Layout_Validation_Main_V_Right = uix.VBox('Parent', gui.Layout_Validation_Main_H, 'Spacing', 3);

gui.Tabs.TabNames = {'Home', 'Validation'};
gui.Tabs.SelectedChild = 1;

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                                 HOME TAB                                %
%_________________________________________________________________________%

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                                  PANELS                                 %
%_________________________________________________________________________%

%% Patient Specific Parameters Panel
gui.Panel_PSP = uix.BoxPanel('Parent', gui.Layout_Home_Main_V_Left,...
    'Title', 'Patient Specific Parameters',...
    'FontWeight', 'bold');

gui.Layout_PSP = uix.VBox('Parent', gui.Panel_PSP,...
    'Spacing', 3);

% Panel HJF Selection
gui.Panel_HJF = uix.Panel('Parent', gui.Layout_PSP,...
    'Title', 'Show HJF for');

gui.RadioButtonBox_HJF = uix.VButtonBox('Parent', gui.Panel_HJF,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left',...
    'ButtonSize', [80 20]);

gui.RadioButton_Pelvis = uicontrol('Parent', gui.RadioButtonBox_HJF,...
    'Style', 'radiobutton',...
    'String', 'Pelvis',...
    'Value', 1,...
    'Callback', @onPelvis);

gui.RadioButton_Femur = uicontrol('Parent', gui.RadioButtonBox_HJF,...
    'Style', 'radiobutton',...
    'String', 'Femur',...
    'Callback', @onFemur);

% Panel Side Selection
gui.Panel_Side = uix.Panel('Parent', gui.Layout_PSP,...
    'Title', 'Side');

gui.RadioButtonBox_Side = uix.VButtonBox('Parent', gui.Panel_Side,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left',...
    'ButtonSize', [80 20]);

gui.RadioButton_Left = uicontrol('Parent', gui.RadioButtonBox_Side,...
    'Style', 'radiobutton',...
    'String', 'Left',...
    'Callback', @onLeftSide);

gui.RadioButton_Right = uicontrol('Parent', gui.RadioButtonBox_Side,...
    'Style', 'radiobutton',...
    'String', 'Right',...
    'Value', 1,...
    'Callback', @onRightSide);

% Panel Bodyweight
gui.Panel_BW = uix.Panel('Parent', gui.Layout_PSP,...
    'Title', 'Bodyweight [kg]');

gui.EditText_BW = uicontrol('Parent', gui.Panel_BW,...
    'Style', 'edit',...
    'String', data.BW,...
    'Callback', @onEditText_BW);

% Panel Pelvic Bend
gui.Panel_PB = uix.Panel('Parent', gui.Layout_PSP,...
    'Title', 'Pelvic Bend [°]');

gui.EditText_PB = uicontrol('Parent', gui.Panel_PB,...
    'Style', 'edit',...
    'String', data.PB,...
    'Callback', @onEditText_PB);

% Panel Distance HRC
gui.Panel_HRC = uix.Panel('Parent', gui.Layout_PSP,...
    'Title', 'Distance between HRCs [mm]');

gui.EditText_HRC = uicontrol('Parent', gui.Panel_HRC,...
    'Style', 'edit',...
    'Callback', @onEditText_HRC);

% Scaling Parameters
gui.Layout_SP = uix.HBox('Parent', gui.Layout_PSP,...
    'Spacing', 3);

gui.Layout_P = uix.VBox('Parent', gui.Layout_SP,...
    'Spacing', 3);

gui.Layout_S = uix.VBox('Parent', gui.Layout_SP,...
    'Spacing', 3);

% Panel Pelvic Width
gui.Panel_PW = uix.Panel('Parent', gui.Layout_P,...
    'Title', 'Pelvic Width [mm]');
gui.EditText_PW = uicontrol('Parent', gui.Panel_PW,...
    'Style', 'edit',...
    'Callback', @onEditText_PW);

% Panel Pelvic Height
gui.Panel_PH = uix.Panel('Parent', gui.Layout_P,...
    'Title', 'Pelvic Height [mm]');
gui.EditText_PH = uicontrol('Parent', gui.Panel_PH,...
    'Style', 'edit',...
    'Callback', @onEditText_PH);

% Panel Pelvic Depth
gui.Panel_PD = uix.Panel('Parent', gui.Layout_P,...
    'Title', 'Pelvic Depth [mm]');
gui.EditText_PD = uicontrol('Parent', gui.Panel_PD,...
    'Style', 'edit',...
    'Callback', @onEditText_PD);

% Panel Femoral Length
gui.Panel_FL = uix.Panel('Parent', gui.Layout_P,...
    'Title', 'Femoral Length [mm]');
gui.EditText_FL = uicontrol('Parent', gui.Panel_FL,...
    'Style', 'edit',...
    'Callback', @onEditText_FL);

% Panel Femoral Width
% gui.Panel_FW = uix.Panel('Parent', gui.Layout_P,...
%     'Title', 'Femoral Width [mm]');
% gui.EditText_FW = uicontrol('Parent', gui.Panel_FW,...
%     'Style', 'edit',...
%     'Callback', @onEditText_FW);

% Scale Panels
gui.Panel_SPW = uix.Panel('Parent', gui.Layout_S,...
    'Title', 'Scale');
gui.Label_SPW = uicontrol('Parent', gui.Panel_SPW,...
    'Style', 'text');

gui.Panel_SPH = uix.Panel('Parent', gui.Layout_S,...
    'Title', 'Scale');
gui.Label_SPH = uicontrol('Parent', gui.Panel_SPH,...
    'Style', 'text');

gui.Panel_SPD = uix.Panel('Parent', gui.Layout_S,...
    'Title', 'Scale');
gui.Label_SPD = uicontrol('Parent', gui.Panel_SPD,...
    'Style', 'text');

gui.Panel_SFL = uix.Panel('Parent', gui.Layout_S,...
    'Title', 'Scale');
gui.Label_SFL = uicontrol('Parent', gui.Panel_SFL,...
    'Style', 'text');

% gui.Panel_SFW = uix.Panel('Parent', gui.Layout_S,...
%     'Title', 'Scale');
% gui.Label_SFW = uicontrol('Parent', gui.Panel_SFW,...
%     'Style', 'text');

gui.PushButton_ResetScaling = uicontrol('Parent', gui.Layout_PSP,...
    'Style', 'PushButton',...
    'String', 'Reset',...
    'Callback', @onPushButton_ResetScaling);
gui.ResetScaling = false;

set(gui.Layout_PSP, 'Height', [-1, -1, -1, -1, -1, -4, -0.5])
set(gui.Layout_SP,  'Width',  [-2.5, -1])

%% Model Panel
gui.Panel_Model = uix.BoxPanel('Parent', gui.Layout_Home_Main_V_Right,...
    'Title', 'Model',...
    'FontWeight', 'bold');

gui.Layout_Muscle = uix.HBox('Parent', gui.Panel_Model,...
    'Spacing', 3);

% Panel Posture
gui.Panel_Posture = uix.Panel('Parent', gui.Layout_Muscle,...
    'Title', 'Posture');

% Get Models
models = dir('src\models\*.m');
[~, models] = arrayfun(@(x) fileparts(x.name), models, 'uni', 0);
data.Model = models{1};
updatePosture()
gui.ListBox_Posture = uicontrol( 'Style', 'list', ...
    'BackgroundColor', 'w', ...
    'Parent', gui.Panel_Posture, ...
    'String', models,...
    'Value', 1,...
    'Callback', @onListSelection_Posture);

% Panel Muscle List
gui.Panel_Muscle = uix.Panel('Parent', gui.Layout_Muscle,...
    'Title', 'Muscle List');
gui.Panel_Muscle_V = uix.VBox('Parent', gui.Panel_Muscle, 'Spacing', 3);

gui.ListBox_MuscleList = uicontrol('Parent', gui.Panel_Muscle_V, 'Style', 'list', ...
    'BackgroundColor', 'w',...
    'String', data.MuscleList(:,1),...
    'Min', 1,...
    'Max', length(data.MuscleList),...
    'Callback', @onListSelection_Muscles);
updateMuscleList()

gui.ListBox_MuscleReset = uicontrol('Parent', gui.Panel_Muscle_V,...
    'Style', 'PushButton',...
    'String', 'Reset',...
    'Callback', @onPushButton_MuscleReset);

set(gui.Panel_Muscle_V, 'Height', [-10, -1])

%% Visualization Panel
gui.Panel_Vis = uix.BoxPanel('Parent', gui.Layout_Home_Main_V_Mid,...
    'Title', 'Visualization',...
    'FontWeight', 'bold');

gui.Layout_Vis_V = uix.VBox('Parent', gui.Panel_Vis, 'Spacing', 3);

% Panel Visualization
gui.Panel_Vis = uix.Panel('Parent', gui.Layout_Vis_V);

gui.Axis_Vis = axes('Parent', gui.Panel_Vis);

[data.LE, ~, data.SPW, data.SPH, data.SPD, data.SFL, data.SFW,...
    data.HRC, data.PW, data.PH, data.PD, data.FL, data.FW] =...
    scaleTLEM2(data.originalLE);
set(gui.EditText_HRC, 'String', data.HRC);
set(gui.EditText_PW,  'String', data.PW);
set(gui.EditText_PH,  'String', data.PH);
set(gui.EditText_PD,  'String', data.PD);
set(gui.EditText_FL,  'String', data.FL);
% set(gui.EditText_FW,  'String', data.FW);
set(gui.Label_SPW, 'String', data.SPW);
set(gui.Label_SPH, 'String', data.SPH);
set(gui.Label_SPD, 'String', data.SPD);
set(gui.Label_SFL, 'String', data.SFL);
% set(gui.Label_SFW, 'String', data.SFW);
data = globalizeTLEM2(data);
visualizeTLEM2(data.LE, data.MuscleList, gui.Axis_Vis, 'Muscles', data.activeMuscles);

gui.Axis_Vis.View = [90, 0];
gui.Axis_Vis.CameraUpVector = [0, 1, 0];

% Push Buttons
gui.Layout_Vis_G = uix.Grid('Parent', gui.Layout_Vis_V, 'Spacing', 3);

uicontrol('Parent', gui.Layout_Vis_G, 'Style', 'PushButton',...
    'String', 'Front',  'Callback', @onPushButton_Front);
uicontrol('Parent', gui.Layout_Vis_G, 'Style', 'PushButton',...
    'String', 'Back',   'Callback', @onPushButton_Back);
uicontrol('Parent', gui.Layout_Vis_G, 'Style', 'PushButton',...
    'String', 'Top',    'Callback', @onPushButton_Top);
uicontrol('Parent', gui.Layout_Vis_G, 'Style', 'PushButton',...
    'String', 'Bottom', 'Callback', @onPushButton_Bottom);
uicontrol('Parent', gui.Layout_Vis_G, 'Style', 'PushButton',...
    'String', 'Right',  'Callback', @onPushButton_Right);
uicontrol('Parent', gui.Layout_Vis_G, 'Style', 'PushButton',...
    'String', 'Left',   'Callback', @onPushButton_Left);

set(gui.Layout_Vis_V, 'Height', [-18, -1])
set(gui.Layout_Vis_G, 'Widths', [-1, -1, -1], 'Heights', [-1, -1]);

%% Results Panel
gui.Panel_Res = uix.BoxPanel('Parent', gui.Layout_Home_Main_V_Right,...
    'Title', 'Results',...
    'FontWeight', 'bold');

gui.Layout_Res_V  = uix.VBox('Parent', gui.Panel_Res,    'Spacing', 3);
gui.Layout_Res_HT = uix.HBox('Parent', gui.Layout_Res_V, 'Spacing', 3);
gui.Layout_Res_HB = uix.HBox('Parent', gui.Layout_Res_V, 'Spacing', 3);

% Panel Frontal View
gui.Panel_FV = uix.Panel('Parent', gui.Layout_Res_HT, 'Title', 'Frontal View');
gui.FV_Axis = axes(gui.Panel_FV);
visualizeTLEM2(data.LE, data.MuscleList, gui.FV_Axis,...
    'Bones', 1, 'Joints', false, 'Muscles', {});
gui.FV_Axis.View = [90, 0];
gui.FV_Axis.CameraUpVector = [0, 1, 0];

% Panel Sagittal View
gui.Panel_SV = uix.Panel('Parent', gui.Layout_Res_HT, 'Title', 'Sagittal View');
gui.SV_Axis = axes(gui.Panel_SV);
visualizeTLEM2(data.LE, data.MuscleList, gui.SV_Axis,...
    'Bones', 1, 'Joints', false, 'Muscles', {});
switch data.Side
    case 'R'
        gui.SV_Axis.View = [0, 90];
    case 'L'
        gui.SV_Axis.View = [0, -90];
end
gui.SV_Axis.CameraUpVector = [0, 1, 0];

% Panel Horizontal View
gui.Panel_HV = uix.Panel('Parent', gui.Layout_Res_HT, 'Title', 'Horizontal View');
gui.HV_Axis = axes(gui.Panel_HV);

visualizeTLEM2(data.LE, data.MuscleList, gui.HV_Axis,...
    'Bones', 1, 'Joints', false, 'Muscles', {});
gui.HV_Axis.View = [0, 0];
gui.HV_Axis.CameraUpVector = [1, 0, 0];

% Panel Magnitude of Force [N]
gui.Panel_FM = uix.Panel(...
    'Parent', gui.Layout_Res_HB,...
    'Title', 'Magnitude of Force [N]');

gui.Label_FM = uicontrol('Parent', gui.Panel_FM,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Panel Magnitude of Force [BW%]
gui.Panel_FMP = uix.Panel(...
    'Parent', gui.Layout_Res_HB,...
    'Title', 'Magnitude of Force [BW%]');

gui.Label_FMP = uicontrol('Parent', gui.Panel_FMP,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Panel Frontal Angle
gui.Panel_FA = uix.Panel(...
    'Parent', gui.Layout_Res_HB,...
    'Title', 'Frontal Angle [°]');

gui.Label_FA = uicontrol('Parent', gui.Panel_FA,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Panel Sagittal Angle
gui.Panel_SA = uix.Panel(...
    'Parent', gui.Layout_Res_HB,...
    'Title', 'Sagittal Angle [°]');

gui.Label_SA = uicontrol('Parent', gui.Panel_SA,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Panel Horizontal Angle
gui.Panel_HA = uix.Panel(...
    'Parent', gui.Layout_Res_HB,...
    'Title', 'Horizontal Angle [°]');

gui.Label_HA = uicontrol('Parent', gui.Panel_HA,...
    'Style', 'text',....
    'String', '-',...
    'FontWeight', 'bold');

% Push Button Calculation
gui.IsUpdated = false;

gui.PushButton_RC = uicontrol('Parent', gui.Layout_Res_HB,...
    'Style', 'PushButton',...
    'String', 'Run Calculation',...
    'BackgroundColor', 'y',...
    'Callback',@onPushButton_RC);

gui.Checkbox_VAL = uicontrol('Parent', gui.Layout_Res_HB,...
    'Style', 'Checkbox',...
    'String', 'and Validation');

set(gui.Layout_Res_V,  'Height', [-9, -1])
set(gui.Layout_Res_HB, 'Width',  [-2, -2, -2, -2, -2, -1.5, -1.5])

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                              VALIDATION TAB                             %
%_________________________________________________________________________%

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                                  PANELS                                 %
%_________________________________________________________________________%

gui.Panel_HJF_VAL = uix.BoxPanel('Parent', gui.Layout_Validation_Main_V_Left,...
    'Title', 'Magnitude of Force [BW%]',...
    'FontWeight', 'bold');
gui.HJF_VAL_Axis = axes(gui.Panel_HJF_VAL);

gui.Panel_FA_VAL = uix.BoxPanel('Parent', gui.Layout_Validation_Main_V_Right,...
    'Title', 'Frontal Angle',...
    'FontWeight', 'bold');
gui.FA_VAL_Axis = axes(gui.Panel_FA_VAL);

gui.Panel_SA_VAL = uix.BoxPanel('Parent', gui.Layout_Validation_Main_V_Left,...
    'Title', 'Sagittal Angle',...
    'FontWeight', 'bold');
gui.SA_VAL_Axis = axes(gui.Panel_SA_VAL);

gui.Panel_HA_VAL = uix.BoxPanel('Parent', gui.Layout_Validation_Main_V_Right,...
    'Title', 'Horizontal Angle',...
    'FontWeight', 'bold');
gui.HA_VAL_Axis = axes(gui.Panel_HA_VAL);

%% Adjust main Layout
set(gui.Layout_Home_Main_H,          'Width',    [-1, -2, -4])
set(gui.Layout_Home_Main_V_Right,    'Height',   [-1, -2])

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                           CALLBACK FUNCTIONS                            %
%_________________________________________________________________________%

%% Patient Specific Parameters Panel
    function onPelvis(~, ~)
        % User has set HJF for Pelvis
        data.View = 1;
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onFemur(~, ~)
        % User has set HJF for Femur
        data.View = 2;
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onRightSide(~, ~)
        % User has set the hip Side to Right
        data.Side = 'R';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onLeftSide(~, ~)
        % User has set the hip Side to Left
        data.Side = 'L';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_BW(scr, ~)
        % User is editing the Bodyweight
        data.BW = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PB(scr, ~)
        % User is editing the Pelvic Bend
        data.PB = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_HRC(scr, ~)
        % User is editing the distance between Hip Rotation Centers
        data.HRC = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PW(scr, ~)
        % User is editing the Pelvic Width
        data.PW = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PH(scr, ~)
        % User is editing the Pelvic Height
        data.PH = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PD(scr, ~)
        % User is editing the Pelvic Depth
        data.PD = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_FL(scr, ~)
        % User is editing Femoral Length
        data.FL = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

%     function onEditText_FW(scr, ~)
%         % User is editing the Femoral Width
%         data.FW = str2double(get(scr, 'String'));
%         gui.IsUpdated = false;
%         updateHomeTab();
%     end

    function onPushButton_ResetScaling(~, ~)
        gui.ResetScaling = true;
        gui.IsUpdated = false;
        updateHomeTab();
    end

%% Visualization Panel
    function onPushButton_Front(~, ~)
        gui.Axis_Vis.View = [90 ,0];
        gui.Axis_Vis.CameraUpVector = [0, 1, 0];
    end
    function onPushButton_Back(~, ~)
        gui.Axis_Vis.View = [-90, 0];
        gui.Axis_Vis.CameraUpVector = [0, 1, 0];
    end
    function onPushButton_Top(~, ~)
        gui.Axis_Vis.View = [0, 180];
        gui.Axis_Vis.CameraUpVector = [1, 0, 0];
    end
    function onPushButton_Left(~, ~)
        gui.Axis_Vis.View = [0, -90];
        gui.Axis_Vis.CameraUpVector = [0, 1, 0];
    end
    function onPushButton_Right(~, ~)
        gui.Axis_Vis.View = [0, 90];
        gui.Axis_Vis.CameraUpVector = [0, 1, 0];
    end
    function onPushButton_Bottom(~, ~)
        gui.Axis_Vis.View = [0, 0];
        gui.Axis_Vis.CameraUpVector = [1, 0, 0];
    end

%% Model Panel
    function onListSelection_Posture(src, ~)
        % User selected a Posture from the list
        data.Model = models{get(src, 'Value')};
        gui.IsUpdated = false;
        updatePosture()
        updateHomeTab();
    end

    function onListSelection_Muscles(src, ~)
        % User selects muscles from the list
        tempMuscleIdx = get(src, 'Value');
        tempMuscles = data.MuscleList(tempMuscleIdx,[1,4]);
        tempFascicles = {};
        for m=1:size(tempMuscles,1)
            tempFascicles = [tempFascicles;...
                cellstr(num2str((1:tempMuscles{m,2})', [tempMuscles{m,1} '%d']))];
        end
        data.activeMuscles = tempFascicles;
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onPushButton_MuscleReset(~, ~)
        [data.activeMuscles, gui.MuscleListEnable] = gui.modelHandle.Muscles();
        gui.IsUpdated = false;
        updateHomeTab();
    end

%% Results Panel
    function onPushButton_RC(~, ~)
        % User has pressed the Run Calculation button
        set(gui.PushButton_RC, 'BackgroundColor', 'r', 'Enable', 'off');
        
        % Validtion with OrthoLoad data
        if gui.Checkbox_VAL.Value == 1
            data.Results = validateTLEM2(data, gui);
            writetable(struct2table(data.Results), 'Results.xlsx')
            updateValidationTab();
        end

        % Calculation with inserted data
        [data.rMag, data.rMagP, data.rPhi, data.rTheta, data.rAlpha,...
            data.rDir, data.rX, data.rY, data.rZ] =...
            gui.modelHandle.Calculation(data);
        
        gui.IsUpdated = true;
        updateResults();
        drawnow
    end

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                             UPDATE FUNCTIONS                            %
%_________________________________________________________________________%

%% Update Home Tab
    function updateHomeTab()
        updateHJFView();
        updateSideSelection();
        updateMuscleList()
        updateVisualization();
        updateResults();
    end

%% Patient Specific Parameters Panel
    function updateHJFView()
        set(gui.RadioButton_Pelvis,  'Value', 0);
        set(gui.RadioButton_Femur, 'Value', 0);
        switch data.View
            case 1 % Pelvis
                set(gui.RadioButton_Pelvis, 'Value', 1);
            case 2 % Femur
                set(gui.RadioButton_Femur, 'Value', 1);
        end
    end

    function updateSideSelection()
        set(gui.RadioButton_Left,  'Value', 0);
        set(gui.RadioButton_Right, 'Value', 0);
        switch data.Side
            case 'L'
                set(gui.RadioButton_Left,  'Value', 1);
            case 'R'
                set(gui.RadioButton_Right, 'Value', 1);
        end
    end

%% Model Panel
    function updatePosture()
        calculateTLEM2 = str2func(data.Model);
        gui.modelHandle = calculateTLEM2();
        [data.activeMuscles, gui.MuscleListEnable] = gui.modelHandle.Muscles();
    end

    function updateMuscleList()
        % Get the indices of the muscles used in the current model
        mListValues = find(ismember(data.MuscleList(:,1), unique(cellfun(@(x) ...
            regexp(x,'\D+','match'), data.activeMuscles(:,1)))));
        gui.ListBox_MuscleList.Value = mListValues;
        gui.ListBox_MuscleList.Enable = gui.MuscleListEnable;
    end

%% Visualization Panel
    function updateVisualization()
        
        % Reset LE
        data.LE = data.originalLE;
        
        if gui.ResetScaling
            data.Side = 'R';
            updateSideSelection();
            data.BW = 45;
            set(gui.EditText_BW, 'String', data.BW);
            [data.LE, ~, data.SPW, data.SPH, data.SPD, data.SFL, data.SFW,...
                data.HRC, data.PW, data.PH, data.PD, data.FL, data.FW] =...
            scaleTLEM2(data.LE);
            gui.ResetScaling = false;
        else
            [data.LE, data.RHRC, data.SPW, data.SPH, data.SPD, data.SFL, data.SFW] =...
                scaleTLEM2(data.LE, data.HRC, data.PW, data.PH, data.PD, data.FL, data.FW);
        end
        set(gui.Label_SPW, 'String', data.SPW);
        set(gui.Label_SPH, 'String', data.SPH);
        set(gui.Label_SPD, 'String', data.SPD);
        set(gui.Label_SFL, 'String', data.SFL);
        % set(gui.Label_SFW, 'String', data.SFW);
        data = globalizeTLEM2(data);
        delete(gui.Axis_Vis.Children);
        visualizeTLEM2(data.LE, data.MuscleList, gui.Axis_Vis, 'Muscles', data.activeMuscles);
    end

%% Results Panel
    function updateResults
        % Plot HJF vector
        if gui.IsUpdated
            
            delete([gui.FV_Axis.Children, gui.SV_Axis.Children, gui.HV_Axis.Children]);

            visualizeTLEM2(data.LE, data.MuscleList, gui.FV_Axis,...
                'Bones', data.View, 'Joints', false, 'Muscles', {});
            visualizeTLEM2(data.LE, data.MuscleList, gui.SV_Axis,...
                'Bones', data.View, 'Joints', false, 'Muscles', {});
            visualizeTLEM2(data.LE, data.MuscleList, gui.HV_Axis,...
                'Bones', data.View, 'Joints', false, 'Muscles', {});
                     
            switch data.View
                case 1 % Pelvis
                    posSign = 1; 
                    magSign = -1;
                    HVAngle = 0;
                    
                case 2 % Femur
                    posSign = -1; 
                    magSign = 1;
                    HVAngle = 180;
            end
            
            gui.FV_Axis.View = [90 ,0];
            gui.FV_Axis.CameraUpVector = [0, 1, 0];
                    
            switch data.Side
                case 'R'
                    gui.SV_Axis.View = [0, 90];
                case 'L'
                    gui.SV_Axis.View = [0, -90];
            end
            gui.SV_Axis.CameraUpVector = [0, 1, 0];
            
            gui.HV_Axis.View = [0, HVAngle];
            gui.HV_Axis.CameraUpVector = [1, 0, 0];
            
            quiver3D(gui.FV_Axis, posSign*data.rDir*75, magSign*data.rDir*60, 'r')
            quiver3D(gui.SV_Axis, posSign*data.rDir*75, magSign*data.rDir*60, 'r')
            quiver3D(gui.HV_Axis, posSign*data.rDir*75, magSign*data.rDir*60, 'r')
        
            set(gui.Label_FM,  'String', data.rMag);
            set(gui.Label_FMP, 'String', data.rMagP);
            set(gui.Label_FA,  'String', abs(data.rPhi));
            set(gui.Label_SA,  'String', abs(data.rTheta));
            set(gui.Label_HA,  'String', abs(data.rAlpha));     
        
            % Disable push button
            set(gui.PushButton_RC, 'BackgroundColor', 'g', 'Enable', 'off');
        else
            set(gui.PushButton_RC, 'BackgroundColor', 'y', 'Enable', 'on');
        end
    end

%% Update Validation Tab
    function updateValidationTab
        l = length(data.Results);
        delete([gui.HJF_VAL_Axis.Children, gui.FA_VAL_Axis.Children, gui.SA_VAL_Axis.Children, gui.HA_VAL_Axis.Children]);
        [gui.HJF_VAL_Axis.XLim, gui.FA_VAL_Axis.XLim, gui.SA_VAL_Axis.XLim, gui.HA_VAL_Axis.XLim] = deal([0,length(data.Results)+1]);
        [gui.HJF_VAL_Axis.XTick, gui.FA_VAL_Axis.XTick, gui.SA_VAL_Axis.XTick, gui.HA_VAL_Axis.XTick] = deal(0:1:length(data.Results)+1);
        [gui.HJF_VAL_Axis.XTickLabel, gui.FA_VAL_Axis.XTickLabel, gui.SA_VAL_Axis.XTickLabel, gui.HA_VAL_Axis.XTickLabel] = deal({"", data.Results.Subject, ""});
        aMean = mean(horzcat(cat(1,data.Results(2:l).rMagP),cat(1,data.Results(2:l).OrrMagP),...
                             cat(1,data.Results(2:l).rPhi),cat(1,data.Results(2:l).OrPhi),...
                             cat(1,data.Results(2:l).rTheta),cat(1,data.Results(2:l).OrTheta),...
                             cat(1,data.Results(2:l).rAlpha),cat(1,data.Results(2:l).OrAlpha)));
        % Magnitude Panel
        hold (gui.HJF_VAL_Axis,'on')
        for n = 1:length(data.Results)
            drawPoint(gui.HJF_VAL_Axis, n, data.Results(n).rMagP, 'color', 'b', 'Marker', 'x', 'Markersize', 7);
            if n > 1
            drawPoint(gui.HJF_VAL_Axis, n, data.Results(n).OrrMagP, 'color', 'g', 'Marker', 'x', 'Markersize', 7);        
            end
        end
        plot(gui.HJF_VAL_Axis, [2,l], [aMean(1),aMean(1)], 'color', 'b')
        plot(gui.HJF_VAL_Axis, [2,l], [aMean(2),aMean(2)], 'color', 'g')
        % Frontal Angle Panel
        hold (gui.FA_VAL_Axis,'on')
        for n = 1:length(data.Results)
            drawPoint(gui.FA_VAL_Axis, n, data.Results(n).rPhi, 'color', 'b', 'Marker', 'x', 'Markersize', 7);
            if n > 1
            drawPoint(gui.FA_VAL_Axis, n, data.Results(n).OrPhi, 'color', 'g', 'Marker', 'x', 'Markersize', 7);        
            end
        end
        plot(gui.FA_VAL_Axis, [2,l], [aMean(3),aMean(3)], 'color', 'b')
        plot(gui.FA_VAL_Axis, [2,l], [aMean(4),aMean(4)], 'color', 'g')
        % Sagittal Angle Panel
        hold (gui.SA_VAL_Axis,'on')
        for n = 1:length(data.Results)
            drawPoint(gui.SA_VAL_Axis, n, data.Results(n).rTheta, 'color', 'b', 'Marker', 'x', 'Markersize', 7);
            if n > 1
            drawPoint(gui.SA_VAL_Axis, n, data.Results(n).OrTheta, 'color', 'g', 'Marker', 'x', 'Markersize', 7);        
            end
        end
        plot(gui.SA_VAL_Axis, [2,l], [aMean(5),aMean(5)], 'color', 'b')
        plot(gui.SA_VAL_Axis, [2,l], [aMean(6),aMean(6)], 'color', 'g')
        % Horizontal Angle Panel
        hold (gui.HA_VAL_Axis,'on')
        for n = 1:length(data.Results)
            calc(n) = drawPoint(gui.HA_VAL_Axis, n, data.Results(n).rAlpha, 'color', 'b', 'Marker', 'x', 'Markersize', 7);
            if n > 1
            orig(n) = drawPoint(gui.HA_VAL_Axis, n, data.Results(n).OrAlpha, 'color', 'g', 'Marker', 'x', 'Markersize', 7);        
            end
        end
        plot(gui.HA_VAL_Axis, [2,l], [aMean(7),aMean(7)], 'color', 'b')
        plot(gui.HA_VAL_Axis, [2,l], [aMean(8),aMean(8)], 'color', 'g')
%         hold (gui.HA_VAL_Axis,'off')
%         legend(gui.HA_VAL_Axis, [calc(2) orig(2)], 'Calculated Value', 'Measured Value')
    end
end