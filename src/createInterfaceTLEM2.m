function gui = createInterfaceTLEM2(data)

% Create GUI
gui.Window = figure(...
    'Name', 'Hip Joint Reaction Force Model',...
    'NumberTitle', 'off',...
    'MenuBar', 'figure',...
    'Toolbar', 'figure');

monitorsPosition = get(0,'MonitorPositions');
if size(monitorsPosition,1) == 1
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

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
%                                 HOME TAB                                %
%_________________________________________________________________________%

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
%                                  PANELS                                 %
%_________________________________________________________________________%

%% Patient Specific Parameters Panel
gui.Panel_PSP = uix.BoxPanel('Parent', gui.Layout_Home_Main_V_Left,...
    'Title', 'Patient Specific Parameters',...
    'FontWeight', 'bold');

gui.Layout_PSP = uix.VBox('Parent', gui.Panel_PSP,...
    'Spacing', 3);

% Panel HJF Selection
gui.Panel_Dataset = uix.Panel('Parent', gui.Layout_PSP,...
    'Title', 'Used dataset');

gui.RadioButtonBox_Dataset = uix.VButtonBox('Parent', gui.Panel_Dataset,...
    'Spacing', 3,...
    'HorizontalAlignment', 'left',...
    'ButtonSize', [80 20]);

gui.RadioButton_TLEM2_0 = uicontrol('Parent', gui.RadioButtonBox_Dataset,...
    'Style', 'radiobutton',...
    'String', 'TLEM 2',...
    'Value', 1,...
    'Callback', @onTLEM2_0);

gui.RadioButton_TLEM2_1 = uicontrol('Parent', gui.RadioButtonBox_Dataset,...
    'Style', 'radiobutton',...
    'String', 'TLEM 2.1',...
    'Callback', @onTLEM2_1);

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
    'String', data.S.BodyWeight,...
    'Callback', @onEditText_BW);

% Panel Pelvic Bend
gui.Panel_PB = uix.Panel('Parent', gui.Layout_PSP,...
    'Title', 'Pelvic Bend [°]');

gui.EditText_PB = uicontrol('Parent', gui.Panel_PB,...
    'Style', 'edit',...
    'String', data.S.PelvicBend,...
    'Callback', @onEditText_PB);

% Panel Hip Joint Width
gui.Panel_HJW = uix.Panel('Parent', gui.Layout_PSP,...
    'Title', 'Hip Joint Width [mm]');

gui.EditText_HJW = uicontrol('Parent', gui.Panel_HJW,...
    'Style', 'edit',...
    'Callback', @onEditText_HJW);

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

gui.PushButton_ResetScaling = uicontrol('Parent', gui.Layout_PSP,...
    'Style', 'PushButton',...
    'String', 'Reset',...
    'Callback', @onPushButton_ResetScaling);
gui.ResetScaling = false;

set(gui.Layout_PSP, 'Height', [-1, -1, -1, -1, -1, -1, -4, -0.5])
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
data.Model = models{2};
updatePosture()
gui.ListBox_Posture = uicontrol( 'Style', 'list', ...
    'BackgroundColor', 'w', ...
    'Parent', gui.Panel_Posture, ...
    'String', models,...
    'Value', 2,...
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

data = scaleTLEM2(data);
set(gui.EditText_HJW, 'String', data.S.Scale(1).HipJointWidth);
set(gui.EditText_PW,  'String', data.S.Scale(1).PelvicWidth);
set(gui.EditText_PH,  'String', data.S.Scale(1).PelvicHeight);
set(gui.EditText_PD,  'String', data.S.Scale(1).PelvicDepth);
set(gui.EditText_FL,  'String', data.S.Scale(2).FemoralLength);
set(gui.Label_SPW, 'String', data.S.Scale(1).PelvicWidth   / data.T.Scale(1).PelvicWidth);
set(gui.Label_SPH, 'String', data.S.Scale(1).PelvicHeight  / data.T.Scale(1).PelvicHeight);
set(gui.Label_SPD, 'String', data.S.Scale(1).PelvicDepth   / data.T.Scale(1).PelvicDepth);
set(gui.Label_SFL, 'String', data.S.Scale(2).FemoralLength / data.T.Scale(2).FemoralLength);
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
switch data.S.Side
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

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
%                              VALIDATION TAB                             %
%_________________________________________________________________________%

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
%                                  PANELS                                 %
%_________________________________________________________________________%

gui.Panel_HJF_VAL = uix.BoxPanel('Parent', gui.Layout_Validation_Main_V_Left,...
    'Title', 'Magnitude of Force [BW%]',...
    'FontWeight', 'bold','BackgroundColor','w');
gui.HJF_VAL_Axis = axes(gui.Panel_HJF_VAL);

gui.Panel_FA_VAL = uix.BoxPanel('Parent', gui.Layout_Validation_Main_V_Right,...
    'Title', 'Frontal Angle',...
    'FontWeight', 'bold','BackgroundColor','w');
gui.FA_VAL_Axis = axes(gui.Panel_FA_VAL);

gui.Panel_SA_VAL = uix.BoxPanel('Parent', gui.Layout_Validation_Main_V_Left,...
    'Title', 'Sagittal Angle',...
    'FontWeight', 'bold','BackgroundColor','w');
gui.SA_VAL_Axis = axes(gui.Panel_SA_VAL);

gui.Panel_HA_VAL = uix.BoxPanel('Parent', gui.Layout_Validation_Main_V_Right,...
    'Title', 'Horizontal Angle',...
    'FontWeight', 'bold','BackgroundColor','w');
gui.HA_VAL_Axis = axes(gui.Panel_HA_VAL);

%% Adjust main Layout
set(gui.Layout_Home_Main_H,          'Width',    [-1, -2, -4])
set(gui.Layout_Home_Main_V_Right,    'Height',   [-1, -2])

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
%                           CALLBACK FUNCTIONS                            %
%_________________________________________________________________________%

%% Patient Specific Parameters Panel

    function onTLEM2_0(~, ~)
        % User has chosen TLEM 2.0 dataset
        data = createDataTLEM2(data, 'TLEM2_0');
        data = scaleTLEM2(data);
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onTLEM2_1(~, ~)
        % User has chosen TLEM 2.1 dataset
        data = createDataTLEM2(data, 'TLEM2_1');
        data = scaleTLEM2(data);
        gui.IsUpdated = false;
        updateHomeTab();
    end

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
        data.S.Side = 'R';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onLeftSide(~, ~)
        % User has set the hip Side to Left
        data.S.Side = 'L';
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_BW(scr, ~)
        % User is editing the Bodyweight
        data.S.BodyWeight = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PB(scr, ~)
        % User is editing the Pelvic Bend
        data.S.PelvicBend = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_HJW(scr, ~)
        % User is editing the distance between Hip Rotation Centers
        data.S.Scale(1).HipJointWidth = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PW(scr, ~)
        % User is editing the Pelvic Width
        data.S.Scale(1).PelvicWidth = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PH(scr, ~)
        % User is editing the Pelvic Height
        data.S.Scale(1).PelvicHeight = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_PD(scr, ~)
        % User is editing the Pelvic Depth
        data.S.Scale(1).PelvicDepth = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

    function onEditText_FL(scr, ~)
        % User is editing Femoral Length
        data.S.Scale(2).FemoralLength = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateHomeTab();
    end

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

%ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ%
%                             UPDATE FUNCTIONS                            %
%_________________________________________________________________________%

%% Update Home Tab
    function updateHomeTab()
        updateDataset();
        updateHJFView();
        updateSideSelection();
        updateMuscleList()
        updateVisualization();
        updateResults();
    end

%% Patient Specific Parameters Panel
    function updateDataset()
        set(gui.RadioButton_TLEM2_0,  'Value', 0);
        set(gui.RadioButton_TLEM2_1, 'Value', 0);
        switch data.Dataset
            case 'TLEM2_0'
                set(gui.RadioButton_TLEM2_0, 'Value', 1);
            case 'TLEM2_1'
                set(gui.RadioButton_TLEM2_1, 'Value', 1);
                otherwise
                    error('No valid TLEM version')
        end
    end

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
        switch data.S.Side
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
        data.LE = data.T.LE;
        
        if gui.ResetScaling
            data.S.Scale(1).PelvicWidth = data.T.Scale(1).PelvicWidth;
            data.S.Scale(1).PelvicHeight = data.T.Scale(1).PelvicHeight;
            data.S.Scale(1).PelvicDepth = data.T.Scale(1).PelvicDepth;
            data.S.Scale(2).FemoralLength = data.T.Scale(2).FemoralLength;
            data = scaleTLEM2(data);
            gui.ResetScaling = false;
        else
            data = scaleTLEM2(data);
        end
        set(gui.EditText_HJW, 'String', data.S.Scale(1).HipJointWidth);
        set(gui.EditText_PW,  'String', data.S.Scale(1).PelvicWidth);
        set(gui.EditText_PH,  'String', data.S.Scale(1).PelvicHeight);
        set(gui.EditText_PD,  'String', data.S.Scale(1).PelvicDepth);
        set(gui.EditText_FL,  'String', data.S.Scale(2).FemoralLength);
        set(gui.Label_SPW, 'String', data.S.Scale(1).PelvicWidth   / data.T.Scale(1).PelvicWidth);
        set(gui.Label_SPH, 'String', data.S.Scale(1).PelvicHeight  / data.T.Scale(1).PelvicHeight);
        set(gui.Label_SPD, 'String', data.S.Scale(1).PelvicDepth   / data.T.Scale(1).PelvicDepth);
        set(gui.Label_SFL, 'String', data.S.Scale(2).FemoralLength / data.T.Scale(2).FemoralLength);
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
                    HVAngle = 0;                    
                case 2 % Femur
                    HVAngle = 180;
            end
            
            gui.FV_Axis.View = [90 ,0];
            gui.FV_Axis.CameraUpVector = [0, 1, 0];
                    
            switch data.S.Side
                case 'R'
                    gui.SV_Axis.View = [0, 90];
                case 'L'
                    gui.SV_Axis.View = [0, -90];
            end
            gui.SV_Axis.CameraUpVector = [0, 1, 0];
            
            gui.HV_Axis.View = [0, HVAngle];
            gui.HV_Axis.CameraUpVector = [1, 0, 0];
            
            quiver3D(gui.FV_Axis, -data.rDir*75, data.rDir*55, 'r')
            quiver3D(gui.SV_Axis, -data.rDir*75, data.rDir*55, 'r')
            quiver3D(gui.HV_Axis, -data.rDir*75, data.rDir*55, 'r')
        
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
        NoS = length(data.Results);
        delete([gui.HJF_VAL_Axis.Children, gui.FA_VAL_Axis.Children, ...
            gui.SA_VAL_Axis.Children, gui.HA_VAL_Axis.Children]);
        [gui.HJF_VAL_Axis.XTick, gui.FA_VAL_Axis.XTick, ...
            gui.SA_VAL_Axis.XTick, gui.HA_VAL_Axis.XTick] = deal(1:length(data.Results));
        [gui.HJF_VAL_Axis.XTickLabel, gui.FA_VAL_Axis.XTickLabel, ...
            gui.SA_VAL_Axis.XTickLabel, gui.HA_VAL_Axis.XTickLabel] = deal({data.Results.Subject});
        [gui.HJF_VAL_Axis.XLim, gui.FA_VAL_Axis.XLim, ...
            gui.SA_VAL_Axis.XLim, gui.HA_VAL_Axis.XLim] = deal([0.5,length(data.Results)+0.5]);

        markerProps.Marker='x';
        markerProps.Markersize=7;
        % Magnitude Panel
        hold (gui.HJF_VAL_Axis,'on')
        drawPoint(gui.HJF_VAL_Axis, 1:NoS, [data.Results(:).rMagP], 'color', 'b', markerProps);
        drawPoint(gui.HJF_VAL_Axis, 1:NoS, [data.Results(:).OrrMagP], 'color', 'g', markerProps)
        S.rMagP.mean=mean([data.Results(:).rMagP]);
        O.rMagP.mean=mean([data.Results(:).OrrMagP]);
        plot(gui.HJF_VAL_Axis, [1,NoS], [S.rMagP.mean,S.rMagP.mean], 'color', 'b')
        plot(gui.HJF_VAL_Axis, [1,NoS], [O.rMagP.mean,O.rMagP.mean], 'color', 'g')
        % Frontal Angle Panel
        hold (gui.FA_VAL_Axis,'on')
        drawPoint(gui.FA_VAL_Axis, 1:NoS, [data.Results(:).rPhi], 'color', 'b', markerProps);
        drawPoint(gui.FA_VAL_Axis, 1:NoS, [data.Results(:).OrPhi], 'color', 'g', markerProps);
        S.rPhi.mean=mean([data.Results(:).rPhi]);
        O.rPhi.mean=mean([data.Results(:).OrPhi]);
        plot(gui.FA_VAL_Axis, [1,NoS], [S.rPhi.mean,S.rPhi.mean], 'color', 'b')
        plot(gui.FA_VAL_Axis, [1,NoS], [O.rPhi.mean,O.rPhi.mean], 'color', 'g')
        % Sagittal Angle Panel
        hold (gui.SA_VAL_Axis,'on')
        drawPoint(gui.SA_VAL_Axis, 1:NoS, [data.Results(:).rTheta], 'color', 'b', markerProps);
        drawPoint(gui.SA_VAL_Axis, 1:NoS, [data.Results(:).OrTheta], 'color', 'g', markerProps);
        S.rTheta.mean=mean([data.Results(:).rTheta]);
        O.rTheta.mean=mean([data.Results(:).OrTheta]);
        plot(gui.SA_VAL_Axis, [1,NoS], [S.rTheta.mean,S.rTheta.mean], 'color', 'b')
        plot(gui.SA_VAL_Axis, [1,NoS], [O.rTheta.mean,O.rTheta.mean], 'color', 'g')
        % Horizontal Angle Panel
        hold (gui.HA_VAL_Axis,'on')
        drawPoint(gui.HA_VAL_Axis, 1:NoS, [data.Results(:).rAlpha], 'color', 'b', markerProps);
        drawPoint(gui.HA_VAL_Axis, 1:NoS, [data.Results(:).OrAlpha], 'color', 'g', markerProps);
        S.rAlpha.mean=mean([data.Results(:).rAlpha]);
        O.rAlpha.mean=mean([data.Results(:).OrAlpha]);
        plot(gui.HA_VAL_Axis, [1,NoS], [S.rAlpha.mean,S.rAlpha.mean], 'color', 'b')
        plot(gui.HA_VAL_Axis, [1,NoS], [O.rAlpha.mean,O.rAlpha.mean], 'color', 'g')
        
%         legend(gui.HJF_VAL_Axis, [calc(2) orig(2)], 'Calculated Value', 'Measured Value')
        figure('Color','w')
        subplot(2,2,1)
        boxplot([[data.Results(:).OrrMagP]',[data.Results(:).rMagP]'],{'In-vivio','Simulated'})
        title('R [%BW]')
        subplot(2,2,2)
        boxplot([[data.Results(:).OrPhi]',[data.Results(:).rPhi]'],{'In-vivio','Simulated'})
        title('Frontal Angle [°]')
        subplot(2,2,3)
        boxplot([[data.Results(:).OrTheta]',[data.Results(:).rTheta]'],{'In-vivio','Simulated'})
        title('Sagittal Angle [°]')
        subplot(2,2,4)
        boxplot([[data.Results(:).OrAlpha]',[data.Results(:).rAlpha]'],{'In-vivio','Simulated'})
        title('Transverse Angle [°]')
    end
end