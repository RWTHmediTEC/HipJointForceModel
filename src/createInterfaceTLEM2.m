function gui = createInterfaceTLEM2(data)

% Creation of the GUI
gui.Window = figure(...
    'Name', 'Hip Joint Reaction Force Model',...
    'NumberTitle', 'off',...
    'MenuBar', 'none',...
    'Toolbar', 'figure',...
    'units','normalized',...
    'outerposition', [0 0 1 1]);

gui.Layout_Main_H       = uix.HBox('Parent', gui.Window, 'Spacing', 3);
gui.Layout_Main_V_Left  = uix.VBox('Parent', gui.Layout_Main_H, 'Spacing', 3);
gui.Layout_Main_V_Mid   = uix.VBox('Parent', gui.Layout_Main_H, 'Spacing', 3);
gui.Layout_Main_V_Right = uix.VBox('Parent', gui.Layout_Main_H, 'Spacing', 3);

%% Patient Specific Parameters Panel

gui.Panel_PSP = uix.BoxPanel('Parent', gui.Layout_Main_V_Left,...
    'Title', 'Patient Specific Parameters',...
    'FontWeight', 'bold');

gui.Layout_PSP = uix.VBox('Parent', gui.Panel_PSP,...
    'Spacing', 3);

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
    'Callback', @onRightSide);

% Panel Bodyweight
gui.Panel_BW = uix.Panel('Parent', gui.Layout_PSP,...
    'Title', 'Bodyweight [kg]');

gui.EditText_BW = uicontrol('Parent', gui.Panel_BW,...
    'Style', 'edit',...
    'String', data.BW,...
    'Callback', @onEditText_BW);

% Panel Pelvic Tilt
gui.Panel_PT = uix.Panel('Parent', gui.Layout_PSP,...
    'Title', 'Lateral Pelvic Tilt around Z axis [°]');

gui.EditText_PT = uicontrol('Parent', gui.Panel_PT,...
    'Style', 'edit',...
    'String', data.PelvicTilt,...
    'Callback', @onEditText_PelvicTilt);

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
gui.Panel_FW = uix.Panel('Parent', gui.Layout_P,...
    'Title', 'Femoral Width [mm]');

gui.EditText_FW = uicontrol('Parent', gui.Panel_FW,...
    'Style', 'edit',...
    'Callback', @onEditText_FW);

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

gui.Panel_SFW = uix.Panel('Parent', gui.Layout_S,...
    'Title', 'Scale');
gui.Label_SFW = uicontrol('Parent', gui.Panel_SFW,...
    'Style', 'text');

%% Model Panel
gui.Panel_Model = uix.BoxPanel('Parent', gui.Layout_Main_V_Right,...
    'Title', 'Considered Muscles',...
    'FontWeight', 'bold');

gui.Layout_Muscle = uix.HBox('Parent', gui.Panel_Model,...
    'Spacing', 3);

% Panel Posture
gui.Panel_Posture = uix.Panel('Parent', gui.Layout_Muscle,...
    'Title', 'Posture');

% Get models
models=dir('src\models\*.m');
[~, models]=arrayfun(@(x) fileparts(x.name), models, 'uni', 0);
data.Model=models{1};
gui.ListBox_Posture = uicontrol( 'Style', 'list', ...
    'BackgroundColor', 'w', ...
    'Parent', gui.Panel_Posture, ...
    'String', models,...
    'Value', 1,...
    'Callback', @onListSelection_Posture);

% Panel Muscle List
gui.Panel_MuscleList = uix.Panel('Parent', gui.Layout_Muscle,...
    'Title', 'Muscle List');

gui.ListBox_MuscleList = uicontrol( 'Style', 'list', ...
    'BackgroundColor', 'w', ...
    'Parent', gui.Panel_MuscleList, ...
    'String', data.MuscleList(:,1),...
    'Value', 1);

%% Visualization Panel
gui.Panel_Vis = uix.BoxPanel('Parent', gui.Layout_Main_V_Mid,...
    'Title', 'Visualization',...
    'FontWeight', 'bold');

gui.Layout_Vis_V = uix.VBox('Parent', gui.Panel_Vis, 'Spacing', 3);

% Panel Visualization
gui.Panel_Vis = uix.Panel('Parent', gui.Layout_Vis_V);

gui.Axis_Vis = axes('Parent', gui.Panel_Vis);

[data.LE, ~, data.SPW, data.SPH, data.SPD, data.SFL, data.SFW,...
    data.HRC, data.PW, data.PH, data.PD, data.FL, data.FW] =...
    scaleTLEM2(data.LE);
set(gui.EditText_HRC, 'String', data.HRC);
set(gui.EditText_PW, 'String', data.PW);
set(gui.EditText_PH, 'String', data.PH);
set(gui.EditText_PD, 'String', data.PD);
set(gui.EditText_FL, 'String', data.FL);
set(gui.EditText_FW, 'String', data.FW);
set(gui.Label_SPW, 'String', data.SPW);
set(gui.Label_SPH, 'String', data.SPH);
set(gui.Label_SPD, 'String', data.SPD);
set(gui.Label_SFL, 'String', data.SFL);
set(gui.Label_SFW, 'String', data.SFW);
data = globalizeTLEM2(data);
visualizeTLEM2(data.LE, data.MuscleList, gui.Axis_Vis);

gui.Axis_Vis.View = [90, 0];
gui.Axis_Vis.CameraUpVector = [0, 1, 0];
gui.Axis_Vis.FontSize = 8;

% Push Buttons
gui.Layout_Vis_HT = uix.HBox('Parent', gui.Layout_Vis_V, 'Spacing', 3);
gui.Layout_Vis_HB = uix.HBox('Parent', gui.Layout_Vis_V, 'Spacing', 3);

gui.PushButton_Front = uicontrol('Parent', gui.Layout_Vis_HT,...
    'Style', 'PushButton',...
    'String', 'Front',...
    'Callback',@onPushButton_Front);

gui.PushButton_Back = uicontrol('Parent', gui.Layout_Vis_HT,...
    'Style', 'PushButton',...
    'String', 'Back',...
    'Callback',@onPushButton_Back);

gui.PushButton_Top = uicontrol('Parent', gui.Layout_Vis_HT,...
    'Style', 'PushButton',...
    'String', 'Top',...
    'Callback',@onPushButton_Top);

gui.PushButton_Left = uicontrol('Parent', gui.Layout_Vis_HB,...
    'Style', 'PushButton',...
    'String', 'Left',...
    'Callback',@onPushButton_Left);

gui.PushButton_Right = uicontrol('Parent', gui.Layout_Vis_HB,...
    'Style', 'PushButton',...
    'String', 'Right',...
    'Callback',@onPushButton_Right);

gui.PushButton_Bottom = uicontrol('Parent', gui.Layout_Vis_HB,...
    'Style', 'PushButton',...
    'String', 'Bottom',...
    'Callback',@onPushButton_Bottom);

%% Results
gui.Panel_Res = uix.BoxPanel('Parent', gui.Layout_Main_V_Right,...
    'Title', 'Results',...
    'FontWeight', 'bold');

gui.Layout_Res_V = uix.VBox('Parent', gui.Panel_Res, 'Spacing', 3);
gui.Layout_Res_HT = uix.HBox('Parent', gui.Layout_Res_V, 'Spacing', 3);
gui.Layout_Res_HB = uix.HBox('Parent', gui.Layout_Res_V, 'Spacing', 3);

% Panel Frontal View
gui.Panel_FV = uix.Panel('Parent', gui.Layout_Res_HT,'Title', 'Frontal View');
gui.FV_Axis = axes(gui.Panel_FV);
visualizeTLEM2(data.LE, data.MuscleList, gui.FV_Axis, ...
    'Bones', 1, 'Joints', false, 'Muscles', false);
gui.FV_Axis.View = [90, 0];
gui.FV_Axis.CameraUpVector = [0, 1, 0];

% Panel Sagittal View
gui.Panel_SV = uix.Panel('Parent', gui.Layout_Res_HT,'Title', 'Sagittal View');
gui.SV_Axis = axes(gui.Panel_SV);
visualizeTLEM2(data.LE, data.MuscleList, gui.SV_Axis, ...
    'Bones', 1, 'Joints', false, 'Muscles', false);
switch data.Side
    case 'L'
        gui.SV_Axis.View = [0, -90];
end
gui.SV_Axis.CameraUpVector = [0, 1, 0];

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

% Push Button Calculation
gui.IsUpdated = false;

gui.PushButton_RC = uicontrol('Parent', gui.Layout_Res_HB,...
    'Style', 'PushButton',...
    'String', 'Run Calculation',...
    'Callback',@onPushButton_RC);

%% Adjust Layout
set(gui.Layout_Main_H,          'Width',    [-1, -2, -4])
set(gui.Layout_PSP,             'Height',   [-1, -1, -1, -1, -5])
set(gui.Layout_SP,              'Width',    [-2.5, -1])
set(gui.Layout_Vis_V,           'Height',   [-28,-1,-1])
set(gui.Layout_Main_V_Right,    'Height',   [-1, -2])
set(gui.Layout_Res_V,           'Height',   [-9, -1])
set(gui.Layout_Res_HT,          'Width',    [-746,-436])

% Functions
%-------------------------------------------------------------------------%
    function onRightSide(~, ~)
        % User has set the hip Side to Right
        data.Side = 'R';
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onLeftSide(~, ~)
        % User has set the hip Side to Left
        data.Side = 'L';
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onEditText_BW(scr, ~)
        % User is editing the Bodyweight
        data.BW = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onEditText_PelvicTilt(scr, ~)
        % User is editing the Pelvic Tilt
        data.PelvicTilt = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onEditText_HRC(scr, ~)
        % User is editing the distance between Hip Rotation Centers
        data.HRC = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onEditText_PW(scr, ~)
        % User is editing the Pelvic Width
        data.PW = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onEditText_PH(scr, ~)
        % User is editing the Pelvic Height
        data.PH = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onEditText_PD(scr, ~)
        % User is editing the Pelvic Depth
        data.PD = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onEditText_FL(scr, ~)
        % User is editing Femoral Length
        data.FL = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onEditText_FW(scr, ~)
        % User is editing the Femoral Width
        data.FW = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onPushButton_Front(~, ~)
        % User has pressed the Front button
        gui.Axis_Vis.View = [90 ,0];
        gui.Axis_Vis.CameraUpVector = [0, 1, 0];
    end
%-------------------------------------------------------------------------%
    function onPushButton_Back(~, ~)
        % User has pressed the Back button
        gui.Axis_Vis.View = [-90, 0];
        gui.Axis_Vis.CameraUpVector = [0, 1, 0];
    end
%-------------------------------------------------------------------------%
    function onPushButton_Top(~, ~)
        % User has pressed the Top button
        gui.Axis_Vis.View = [0, 180];
        gui.Axis_Vis.CameraUpVector = [1, 0, 0];
    end
%-------------------------------------------------------------------------%
    function onPushButton_Left(~, ~)
        % User has pressed the Left button
        gui.Axis_Vis.View = [0, -90];
        gui.Axis_Vis.CameraUpVector = [0, 1, 0];
    end
%-------------------------------------------------------------------------%
    function onPushButton_Right(~, ~)
        % User has pressed the Right button
        gui.Axis_Vis.View = [0, 90];
        gui.Axis_Vis.CameraUpVector = [0, 1, 0];
    end
%-------------------------------------------------------------------------%
    function onPushButton_Bottom(~, ~)
        % User has pressed the Bottom button
        gui.Axis_Vis.View = [0, 0];
        gui.Axis_Vis.CameraUpVector = [1, 0, 0];
    end
%-------------------------------------------------------------------------%
    function onListSelection_Posture(src, ~ )
        % User selected a Posture from the list
        data.Model = models{get(src, 'Value')};
        gui.IsUpdated = false;
        updateInterfaceTLEM2(data, gui);
    end
%-------------------------------------------------------------------------%
    function onPushButton_RC(~, ~)
        % User has pressed the Run Calculation button
        set(gui.PushButton_RC, 'BackgroundColor', 'r', 'Enable', 'off');
        
        % % TLEM2
        % load('TLEM2', 'LE', 'muscleList')
        % data.LE = LE;
        %
        % [data.LE, ~, data.SPW, data.SPH, data.SPD, data.SFL, data.SFW] =...
        %     scaleTLEM2(data.LE, data.HRC, data.PW, data.PH, data.PD, data.FL, data.FW);
        % set(gui.Label_SPW, 'String', data.SPW);
        % set(gui.Label_SPH, 'String', data.SPH);
        % set(gui.Label_SPD, 'String', data.SPD);
        % set(gui.Label_SFL, 'String', data.SFL);
        % set(gui.Label_SFW, 'String', data.SFW);
        % data.LE = globalizeTLEM2...
        %     (data.LE, data.Stance, data.Side, data.PelvicTilt, data.HRC, data.FL);
        % [data.rMag, data.rMagP, data.rPhi, data.rTheta, data.rDir] =...
        %     calculateTLEM2(data.LE, data.BW, data.HRC, data.Side);
        %
        % gui.IsUpdated = true;
        % updateInterfaceTLEM2(data, gui);
        
        % Validtion with Orthoload data
        Subjects = {'H1L' 'H3L' 'H5L' 'H8L' 'H9L' 'H10R'}; % Orthoload patient
        sex = {'m' 'm' 'w' 'm' 'm' 'w'};
        for p = 1:length(Subjects)
            
            load('TLEM2', 'LE', 'muscleList')
            data.LE = LE;
            
            [data.HRC, data.PW, data.PH, data.PD, data.FL, data.FW, data.BW, data.rMagPo] =...
                validateTLEM2(Subjects{p});
            set(gui.EditText_BW,  'String', data.BW);
            set(gui.EditText_HRC, 'String', data.HRC);
            set(gui.EditText_PW,  'String', data.PW);
            set(gui.EditText_PH,  'String', data.PH);
            set(gui.EditText_PD,  'String', data.PD);
            set(gui.EditText_FL,  'String', data.FL);
            set(gui.EditText_FW,  'String', data.FW);
            
            [data.LE, data.RHRC, data.SPW, data.SPH, data.SPD, data.SFL, data.SFW] =...
                scaleTLEM2(data.LE, data.HRC, data.PW, data.PH, data.PD, data.FL, data.FW);
            set(gui.Label_SPW, 'String', data.SPW);
            set(gui.Label_SPH, 'String', data.SPH);
            set(gui.Label_SPD, 'String', data.SPD);
            set(gui.Label_SFL, 'String', data.SFL);
            set(gui.Label_SFW, 'String', data.SFW);
            
            % Use the selected model to calculate the
            calculateTLEM2=str2func(data.Model);
            modelHandles=calculateTLEM2();
            data = globalizeTLEM2(data);
            [data.rMag, data.rMagP, data.rPhi, data.rTheta, data.rDir] = modelHandles.Calculation(data);
            
            VAL(p).patient = Subjects{p};
            VAL(p).sex = sex{p};
            
            % Scaling parameters
            VAL(p).BW = data.BW;
            VAL(p).HRC = data.HRC;
            VAL(p).RHRC = data.RHRC;
            VAL(p).PW = data.PW;
            VAL(p).SPW = data.SPW;
            VAL(p).PH = data.PH;
            VAL(p).SPH = data.SPH;
            VAL(p).PD = data.PD;
            VAL(p).SPD = data.SPD;
            VAL(p).FL = data.FL;
            VAL(p).SFL = data.SFL;
            VAL(p).FW = data.FW;
            VAL(p).SFW = data.SFW;
            
            % Force parameters
            VAL(p).rMag = data.rMag;
            VAL(p).rMagP = data.rMagP;
            VAL(p).rMagPo = data.rMagPo;
            VAL(p).rPhi = data.rPhi;
            VAL(p).rTheta = data.rTheta;
            
            assignin('base', 'VAL', VAL);
            
            gui.IsUpdated = true;
            updateInterfaceTLEM2(data, gui);
        end
    end
end