function gui = createInterfaceTLEM2(data)
% Creation of the GUI

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

gui.Layout_Main_H       = uix.HBox('Parent', gui.Window,        'Spacing', 3);
gui.Layout_Main_V_Left  = uix.VBox('Parent', gui.Layout_Main_H, 'Spacing', 3);
gui.Layout_Main_V_Mid   = uix.VBox('Parent', gui.Layout_Main_H, 'Spacing', 3);
gui.Layout_Main_V_Right = uix.VBox('Parent', gui.Layout_Main_H, 'Spacing', 3);

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                                  PANELS                                 %
%_________________________________________________________________________%

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
% gui.Panel_PB = uix.Panel('Parent', gui.Layout_PSP,...
%     'Title', 'Pelvic Bend [°]');
% 
% gui.EditText_PB = uicontrol('Parent', gui.Panel_PB,...
%     'Style', 'edit',...
%     'String', data.PB,...
%     'Callback', @onEditText_PB);

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

set(gui.Layout_PSP, 'Height', [-1, -1, -1, -4])
set(gui.Layout_SP,  'Width',  [-2.5, -1])

%% Model Panel
gui.Panel_Model = uix.BoxPanel('Parent', gui.Layout_Main_V_Right,...
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
gui.Panel_Res = uix.BoxPanel('Parent', gui.Layout_Main_V_Right,...
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

set(gui.Layout_Res_V, 'Height', [-9, -1])

%% Adjust main Layout
set(gui.Layout_Main_H,          'Width',    [-1, -2, -4])
set(gui.Layout_Main_V_Right,    'Height',   [-1, -2])

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                           CALLBACK FUNCTIONS                            %
%_________________________________________________________________________%

%% Patient Specific Parameters Panel
    function onRightSide(~, ~)
        % User has set the hip Side to Right
        data.Side = 'R';
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onLeftSide(~, ~)
        % User has set the hip Side to Left
        data.Side = 'L';
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onEditText_BW(scr, ~)
        % User is editing the Bodyweight
        data.BW = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onEditText_PB(scr, ~)
        % User is editing the Pelvic Bend
        data.PB = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onEditText_HRC(scr, ~)
        % User is editing the distance between Hip Rotation Centers
        data.HRC = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onEditText_PW(scr, ~)
        % User is editing the Pelvic Width
        data.PW = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onEditText_PH(scr, ~)
        % User is editing the Pelvic Height
        data.PH = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onEditText_PD(scr, ~)
        % User is editing the Pelvic Depth
        data.PD = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onEditText_FL(scr, ~)
        % User is editing Femoral Length
        data.FL = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onEditText_FW(scr, ~)
        % User is editing the Femoral Width
        data.FW = str2double(get(scr, 'String'));
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
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
        updateInterfaceTLEM2();
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
        data.activeMuscles=tempFascicles;
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onPushButton_MuscleReset(~, ~)
        [data.activeMuscles, gui.MuscleListEnable] = gui.modelHandle.Muscles();
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

%% Results Panel
    function onPushButton_RC(~, ~)
        % User has pressed the Run Calculation button
        set(gui.PushButton_RC, 'BackgroundColor', 'r', 'Enable', 'off');
        
        % Validtion with OrthoLoad data
        Subjects = {'H1L' 'H8L' 'H9L' 'H10R'}; % Orthoload patient
        Sex = {'m' 'm' 'm' 'w'};
        Results = repmat(struct('Patient', [], 'Sex', []), length(Subjects),1);
        for p = 1:length(Subjects)
            
            load('TLEM2', 'LE', 'muscleList')
            data.LE = LE;
            data.Side = Subjects{p}(end);
            
            [data.HRC, data.PW, data.PH, data.PD, data.FL, data.FW, data.BW,...
                data.OrMagP, data.OrPhi, data.OrTheta, data.OrAlpha] =...
                validateTLEM2(Subjects{p});
%             set(gui.EditText_BW,  'String', data.BW);
%             set(gui.EditText_HRC, 'String', data.HRC);
%             set(gui.EditText_PW,  'String', data.PW);
%             set(gui.EditText_PH,  'String', data.PH);
%             set(gui.EditText_PD,  'String', data.PD);
%             set(gui.EditText_FL,  'String', data.FL);
%             set(gui.EditText_FW,  'String', data.FW);
            
            [data.LE, data.RHRC, data.SPW, data.SPH, data.SPD, data.SFL, data.SFW] =...
                scaleTLEM2(data.LE, data.HRC, data.PW, data.PH, data.PD, data.FL, data.FW);
%             set(gui.Label_SPW, 'String', data.SPW);
%             set(gui.Label_SPH, 'String', data.SPH);
%             set(gui.Label_SPD, 'String', data.SPD);
%             set(gui.Label_SFL, 'String', data.SFL);
%             set(gui.Label_SFW, 'String', data.SFW);
            
            % Use the selected model to calculate the HJF
            data = globalizeTLEM2(data);
            [data.rMag, data.rMagP, data.rPhi, data.rTheta, data.rAlpha,...
                data.rDir, data.rX, data.rY, data.rZ] =...
                gui.modelHandle.Calculation(data);
            
            Results(p).Patient = Subjects{p};
            Results(p).Sex = Sex{p};
            
            % Scaling parameters
%             Results(p).BW   = data.BW;
%             Results(p).HRC  = data.HRC;
%             Results(p).RHRC = data.RHRC;
%             Results(p).PW   = data.PW;
%             Results(p).SPW  = data.SPW;
%             Results(p).PH   = data.PH;
%             Results(p).SPH  = data.SPH;
%             Results(p).PD   = data.PD;
%             Results(p).SPD  = data.SPD;
%             Results(p).FL   = data.FL;
%             Results(p).SFL  = data.SFL;
%             Results(p).FW   = data.FW;
%             Results(p).SFW  = data.SFW;
            
            % Force parameters
            Results(p).rX         = data.rX;
            Results(p).rY         = data.rY;
            Results(p).rZ         = data.rZ;
            Results(p).rMag       = data.rMag;
            Results(p).rMagP      = data.rMagP;
            Results(p).OrMagP     = data.OrMagP;
                errP = abs((data.rMagP - data.OrMagP) / data.OrMagP * 100);
            Results(p).errP       = errP;
            Results(p).rPhi       = data.rPhi;          
            Results(p).OrPhi      = data.OrPhi;
                errPhi = abs(abs(data.rPhi) - abs(data.OrPhi));
            Results(p).errPhi     = errPhi;
            Results(p).rTheta     = data.rTheta;
            Results(p).OrTheta    = data.OrTheta;
                errTheta = abs(data.rTheta - data.OrTheta);
            Results(p).errTheta   = errTheta;
            Results(p).rAlpha     = data.rAlpha;
            Results(p).OrAlpha    = data.OrAlpha;
                errAlpha = abs(data.rAlpha - data.OrAlpha);
            Results(p).errAlpha = errAlpha;
        end
        
        % TLEM2
        dataTLEM = createDataTLEM2();
        data.LE = dataTLEM.LE;
        data.BW = dataTLEM.BW;
        data.Side = dataTLEM.Side;
        
        [data.LE, ~, data.SPW, data.SPH, data.SPD, data.SFL, data.SFW,...
            data.HRC,data.PW, data.PH, data.PD, data.FL, data.FW] =...
            scaleTLEM2(data.LE);
%         set(gui.Label_SPW, 'String', data.SPW);
%         set(gui.Label_SPH, 'String', data.SPH);
%         set(gui.Label_SPD, 'String', data.SPD);
%         set(gui.Label_SFL, 'String', data.SFL);
%         set(gui.Label_SFW, 'String', data.SFW);
        
        % Use the selected model to calculate the HJF
        data = globalizeTLEM2(data);
        [data.rMag, data.rMagP, data.rPhi, data.rTheta, data.rAlpha,...
            data.rDir, data.rX, data.rY, data.rZ] =...
            gui.modelHandle.Calculation(data);       
        
        Results(7).Patient = 'TLEM 2.0';
        Results(7).Sex = 'm';
%         Results(7).BW   = data.BW;
%         Results(7).HRC  = data.HRC;
%         Results(7).PW   = data.PW;
%         Results(7).SPW  = data.SPW;
%         Results(7).PH   = data.PH;
%         Results(7).SPH  = data.SPH;
%         Results(7).PD   = data.PD;
%         Results(7).SPD  = data.SPD;
%         Results(7).FL   = data.FL;
%         Results(7).SFL  = data.SFL;
%         Results(7).FW   = data.FW;
%         Results(7).SFW  = data.SFW;
        Results(7).rX        = data.rX;
        Results(7).rY        = data.rY;
        Results(7).rZ        = data.rZ;
        Results(7).rMag      = data.rMag;
        Results(7).rMagP     = data.rMagP;
        Results(7).rPhi      = data.rPhi;
        Results(7).rTheta    = data.rTheta;
        Results(7).rAlpha    = data.rAlpha;
             
        gui.IsUpdated = true;
        updateInterfaceTLEM2();
        drawnow

        writetable(struct2table(Results), 'Results.xlsx')
    end

%¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯%
%                             UPDATE FUNCTIONS                            %
%_________________________________________________________________________%

%% Update whole GUI
    function updateInterfaceTLEM2()
        updateSideSelection();
        updateMuscleList()
        updateVisualization();
        updateResults();
    end

%% Patient Specific Parameters Panel
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
        delete(gui.Axis_Vis.Children);
        visualizeTLEM2(data.LE, data.MuscleList, gui.Axis_Vis, 'Muscles', data.activeMuscles);
    end

%% Results Panel
    function updateResults
        % Plot HJF vector
        if gui.IsUpdated
            
% Visualize HJF on femur
% data.vis.LE = load('TLEM2', 'LE');
% data.vis.patchProps.EdgeColor    = 'none';
% data.vis.patchProps.FaceColor    = [0.95 0.91 0.8];
% data.vis.patchProps.FaceAlpha    = 1;
% data.vis.patchProps.EdgeLighting = 'gouraud';
% data.vis.patchProps.FaceLighting = 'gouraud';
% figure('color', 'white')
% patch(data.vis.LE.LE(2).Mesh,data.vis.patchProps)
% data.H_Light(1) = light(gca); light(gca, 'Position', -1*(get(data.H_Light(1),'Position')));
% axis(gca, 'equal','tight');
% xlabel(gca, 'x'); ylabel(gca, 'y'); zlabel(gca, 'z');
% 
% quiver3D( ([0 359.1 0] -data.rDir*80), data.rDir*65, 'r')
% gui.Ax = gca;
% gui.Ax.Visible = 'off';
%         gui.Ax.View = [90 ,0];
%         gui.Ax.CameraUpVector = [0, 1, 0];
% 
%         gui.Ax.View = [0, 180];
%         gui.Ax.CameraUpVector = [1, 0, 0];
% 
%         gui.Ax.View = [0, 90];
%         gui.Ax.CameraUpVector = [0, 1, 0];

            % In frontal view
            delete(gui.FV_Axis.Children);
            visualizeTLEM2(data.LE, data.MuscleList, gui.FV_Axis,...
                'Bones', 1, 'Joints', false, 'Muscles', {});
            gui.FV_Axis.View = [90, 0];
            gui.FV_Axis.CameraUpVector = [0, 1, 0];
            
            quiver3D(gui.FV_Axis, -data.rDir*40, data.rDir*40, 'r')
            
            % In sagittal view
            delete(gui.SV_Axis.Children);
            visualizeTLEM2(data.LE, data.MuscleList, gui.SV_Axis,...
                'Bones', 1, 'Joints', false, 'Muscles', {});
            switch data.Side
                case 'R'
                    gui.SV_Axis.View = [0, 90];
                case 'L'
                    gui.SV_Axis.View = [0, -90];
            end
            gui.SV_Axis.CameraUpVector = [0, 1, 0];
            
            quiver3D(gui.SV_Axis, -data.rDir*40, data.rDir*40, 'r')
            
            % In horizontal view
            delete(gui.HV_Axis.Children);
            visualizeTLEM2(data.LE, data.MuscleList, gui.HV_Axis,...
                'Bones', 1, 'Joints', false, 'Muscles', {});
            gui.HV_Axis.View = [0, 0];
            gui.HV_Axis.CameraUpVector = [1, 0, 0];
            
            quiver3D(gui.HV_Axis, -data.rDir*40, data.rDir*40, 'r')
        end
        
        if gui.IsUpdated
            set(gui.Label_FM,  'String', data.rMag);
            set(gui.Label_FMP, 'String', data.rMagP);
            set(gui.Label_FA,  'String', abs(data.rPhi));
            set(gui.Label_SA,  'String', abs(data.rTheta));
            set(gui.Label_HA,  'String', abs(data.rAlpha));     
        end
        
        % Disable push button
        if gui.IsUpdated
            set(gui.PushButton_RC, 'BackgroundColor', 'g', 'Enable', 'off');
        else
            set(gui.PushButton_RC, 'BackgroundColor', 'y', 'Enable', 'on');
        end
    end

end