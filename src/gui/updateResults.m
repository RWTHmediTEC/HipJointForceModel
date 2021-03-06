function gui = updateResults(data, gui)
%UPDATERESULTS updates the results after HJF calculation in the GUI
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

delete([...
    gui.Home.Results.Axis_FrontalView   .Children,...
    gui.Home.Results.Axis_SagittalView  .Children,...
    gui.Home.Results.Axis_TransverseView.Children])

side = data.S.Side;
switch side
    case 'R'
        sideSign = 1;
    case 'L'
        sideSign = -1;
end

visualizeLEM(gui.Home.Results.Axis_FrontalView, ...
    data.S.LE, side,...
    'Bones', find(strcmp({data.S.LE.Name}, data.View)));
visualizeLEM(gui.Home.Results.Axis_SagittalView, ...
    data.S.LE, side,...
    'Bones', find(strcmp({data.S.LE.Name}, data.View)));
visualizeLEM(gui.Home.Results.Axis_TransverseView, ...
    data.S.LE, side,...
    'Bones', find(strcmp({data.S.LE.Name}, data.View)));

gui.Home.Results.Axis_FrontalView.View = [90 ,0];
gui.Home.Results.Axis_FrontalView.CameraUpVector = [0, 1, 0];
gui.Home.Results.Axis_SagittalView.View = [0, sideSign*90];
gui.Home.Results.Axis_SagittalView.CameraUpVector = [0, 1, 0];

switch data.View
    case 'Pelvis'
        gui.Home.Results.Axis_TransverseView.View = [0, 0];
        gui.Home.Results.Axis_TransverseView.CameraUpVector = [1, 0, 0];
    case 'Femur'
        gui.Home.Results.Axis_TransverseView.View = [0, 180];
        gui.Home.Results.Axis_TransverseView.CameraUpVector = [-1, 0, 0];
end

% Plot hip joint force vector
if gui.IsUpdated
    switch data.View
        case 'Pelvis'
            HJF = data.HJF.(data.View).(data.PelvicCS).R .* [1 1 sideSign];
            Dist2HJC = 55;
        case 'Femur'
            HJF = data.HJF.(data.View).Wu2002.R .* [1 1 sideSign];
            Dist2HJC = 75;
    end
    rDir = normalizeVector3d(HJF);
    drawArrow3d(gui.Home.Results.Axis_FrontalView,    -rDir*Dist2HJC, rDir*55, 'r')
    drawArrow3d(gui.Home.Results.Axis_SagittalView,   -rDir*Dist2HJC, rDir*55, 'r')
    drawArrow3d(gui.Home.Results.Axis_TransverseView, -rDir*Dist2HJC, rDir*55, 'r')
    
    set(gui.Home.Results.Label_pos_antHJFpercBW, 'String', round(HJF(1)));
    set(gui.Home.Results.Label_inf_supHJFpercBW, 'String', round(HJF(2)));
    set(gui.Home.Results.Label_med_latHJFpercBW, 'String', round(HJF(3)));
    angles = calculateHJFangles(HJF);
    set(gui.Home.Results.Label_FrontalAngle,    'String', round(angles(1)));
    set(gui.Home.Results.Label_SagittalAngle,   'String', round(angles(2)));
    set(gui.Home.Results.Label_TransverseAngle, 'String', round(angles(3)));
    
    % Disable push button
    set(gui.Home.Results.PushButton_RunCalculation, 'BackgroundColor', 'g', 'Enable', 'off');
else
    set(gui.Home.Results.PushButton_RunCalculation, 'BackgroundColor', 'y', 'Enable', 'on');
end
end