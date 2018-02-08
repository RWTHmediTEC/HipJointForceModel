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

gui.Layout_Main_H       = uix.HBox('Parent', gui.Window, 'Spacing', 3);
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

set(gui.Layout_PSP, 'Height', [-1, -1, -1, -1, -5])
set(gui.Layout_SP, 'Width', [-2.5, -1])

%% Model Panel
gui.Panel_Model = uix.BoxPanel('Parent', gui.Layout_Main_V_Right,...
    'Title', 'Models',...
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
gui.Panel_Muscle_V=uix.VBox('Parent', gui.Panel_Muscle, 'Spacing', 3);

gui.ListBox_MuscleList = uicontrol('Parent', gui.Panel_Muscle_V, 'Style', 'list', ...
    'BackgroundColor', 'w', ...
    'String', data.MuscleList(:,1),...
    'Min', 1, ...
    'Max', length(data.MuscleList),...
    'Callback', @onListSelection_Muscles);
updateMuscleList()

gui.ListBox_MuscleReset = uicontrol('Parent', gui.Panel_Muscle_V,'Style', 'PushButton',...
    'String', 'Reset','Callback',@onPushButton_MuscleReset);

set(gui.Panel_Muscle_V, 'Height', [-15,-1])

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
visualizeTLEM2(data.LE, data.MuscleList, gui.Axis_Vis, 'Muscles', data.activeMuscles);

gui.Axis_Vis.View = [90, 0];
gui.Axis_Vis.CameraUpVector = [0, 1, 0];
gui.Axis_Vis.FontSize = 8;

% Push Buttons
gui.Layout_Vis_G = uix.Grid('Parent', gui.Layout_Vis_V, 'Spacing', 3);

uicontrol('Parent', gui.Layout_Vis_G,'Style', 'PushButton',...
    'String', 'Front',...
    'Callback',@onPushButton_Front);
uicontrol('Parent', gui.Layout_Vis_G,'Style', 'PushButton',...
    'String', 'Back','Callback',@onPushButton_Back);
uicontrol('Parent', gui.Layout_Vis_G,'Style', 'PushButton',...
    'String', 'Top','Callback',@onPushButton_Top);
uicontrol('Parent', gui.Layout_Vis_G,'Style', 'PushButton',...
    'String', 'Bottom','Callback',@onPushButton_Bottom);
uicontrol('Parent', gui.Layout_Vis_G,'Style', 'PushButton',...
    'String', 'Right','Callback',@onPushButton_Right);
uicontrol('Parent', gui.Layout_Vis_G,'Style', 'PushButton',...
    'String', 'Left','Callback',@onPushButton_Left);

set(gui.Layout_Vis_V, 'Height', [-50,-2])
set(gui.Layout_Vis_G, 'Widths', [-1 -1 -1], 'Heights', [-1 -1]);

%% Results Panel
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
    'Bones', 1, 'Joints', false, 'Muscles', {});
gui.FV_Axis.View = [90, 0];
gui.FV_Axis.CameraUpVector = [0, 1, 0];

% Panel Sagittal View
gui.Panel_SV = uix.Panel('Parent', gui.Layout_Res_HT,'Title', 'Sagittal View');
gui.SV_Axis = axes(gui.Panel_SV);
visualizeTLEM2(data.LE, data.MuscleList, gui.SV_Axis, ...
    'Bones', 1, 'Joints', false, 'Muscles', {});
switch data.Side
    case 'R'
        gui.SV_Axis.View = [0, 90];
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

set(gui.Layout_Res_V, 'Height', [-9, -1])
set(gui.Layout_Res_HT, 'Width', [-1.5,-1])

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

    function onEditText_PelvicTilt(scr, ~)
        % User is editing the Pelvic Tilt
        data.PelvicTilt = str2double(get(scr, 'String'));
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
    function onListSelection_Posture(src, ~ )
        % User selected a Posture from the list
        data.Model = models{get(src, 'Value')};
        gui.IsUpdated = false;
        updatePosture()
        updateInterfaceTLEM2();
    end

    function onListSelection_Muscles(src, ~ )
        % User selects muscles from the list
        tempMuscleIdx=get(src, 'Value');
        tempMuscles = data.MuscleList(tempMuscleIdx,[1,4]);
        tempFascicles = {};
        for m=1:size(tempMuscles,1)
            tempFascicles = [tempFascicles; ...
                cellstr(num2str((1:tempMuscles{m,2})', [tempMuscles{m,1} '%d']))];
        end
        data.activeMuscles=tempFascicles;
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

    function onPushButton_MuscleReset(~, ~ )
        [data.activeMuscles, gui.MuscleListEnable] = gui.modelHandle.Muscles();
        gui.IsUpdated = false;
        updateInterfaceTLEM2();
    end

%% Results Panel
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
        % updateInterfaceTLEM2();
        
        % Validtion with OrthoLoad data
        Subjects = {'H1L' 'H3L' 'H5L' 'H8L' 'H9L' 'H10R'}; % Orthoload patient
        sex = {'m' 'm' 'w' 'm' 'm' 'w'};
        Results=repmat(struct('patient',[],'sex',[]),length(Subjects),1);
        for p = 1:length(Subjects)
            
            load('TLEM2', 'LE', 'muscleList')
            data.LE = LE;
            data.Side = Subjects{p}(end);
            
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
            data = globalizeTLEM2(data);
            [data.rMag, data.rMagP, data.rPhi, data.rTheta, data.rDir] = gui.modelHandle.Calculation(data);
            
            Results(p).patient = Subjects{p};
            Results(p).sex = sex{p};
            
            % Scaling parameters
            Results(p).BW = data.BW;
            Results(p).HRC = data.HRC;
            Results(p).RHRC = data.RHRC;
            Results(p).PW = data.PW;
            Results(p).SPW = data.SPW;
            Results(p).PH = data.PH;
            Results(p).SPH = data.SPH;
            Results(p).PD = data.PD;
            Results(p).SPD = data.SPD;
            Results(p).FL = data.FL;
            Results(p).SFL = data.SFL;
            Results(p).FW = data.FW;
            Results(p).SFW = data.SFW;
            
            % Force parameters
            Results(p).rMag = data.rMag;
            Results(p).rMagP = data.rMagP;
            Results(p).rMagPo = data.rMagPo;
            Results(p).rPhi = data.rPhi;
            Results(p).rTheta = data.rTheta;
            
            gui.IsUpdated = true;
            updateInterfaceTLEM2();
            drawnow
        end
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
        set(gui.RadioButton_Left, 'Value', 0);
        set(gui.RadioButton_Right, 'Value', 0);
        switch data.Side
            case 'L'
                set(gui.RadioButton_Left, 'Value', 1);
            case 'R'
                set(gui.RadioButton_Right, 'Value', 1);
        end
    end

    function updatePosture()
        calculateTLEM2=str2func(data.Model);
        gui.modelHandle=calculateTLEM2();
        [data.activeMuscles, gui.MuscleListEnable] = gui.modelHandle.Muscles();
    end

    function updateMuscleList()
        % Get the indices of the muscles used in the current model
        mListValues = find(ismember(data.MuscleList(:,1), unique(cellfun(@(x) ...
            regexp(x,'\D+','match'), data.activeMuscles(:,1)))));
        gui.ListBox_MuscleList.Value=mListValues;
        gui.ListBox_MuscleList.Enable=gui.MuscleListEnable;
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
            
            % In frontal view
            delete(gui.FV_Axis.Children);
            visualizeTLEM2(data.LE, data.MuscleList, gui.FV_Axis, ...
                'Bones', 1, 'Joints', false, 'Muscles', {});
            gui.FV_Axis.View = [90, 0];
            gui.FV_Axis.CameraUpVector = [0, 1, 0];
            
            quiver3D(gui.FV_Axis, -data.rDir*40, data.rDir*40, 'r')
            
            % In lateral view
            delete(gui.SV_Axis.Children);
            visualizeTLEM2(data.LE, data.MuscleList, gui.SV_Axis, ...
                'Bones', 1, 'Joints', false, 'Muscles', {});
            switch data.Side
                case 'R'
                    gui.SV_Axis.View = [0, 90];
                case 'L'
                    gui.SV_Axis.View = [0, -90];
            end
            gui.SV_Axis.CameraUpVector = [0, 1, 0];
            
            quiver3D(gui.SV_Axis, -data.rDir*40, data.rDir*40, 'r')
        end
        
        if gui.IsUpdated
            set(gui.Label_FM, 'String', data.rMag);
            set(gui.Label_FMP, 'String', data.rMagP);
            if data.Side == 'L'
                data.rPhi = - data.rPhi;
            end
            set(gui.Label_FA, 'String', data.rPhi);
            set(gui.Label_SA, 'String', data.rTheta);
        end
        
        % Disable push button
        if gui.IsUpdated
            set(gui.PushButton_RC, 'BackgroundColor', 'g', 'Enable', 'off');
        else
            set(gui.PushButton_RC, 'BackgroundColor', 'y', 'Enable', 'on');
        end
        
    end
end
