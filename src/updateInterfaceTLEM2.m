function updateInterfaceTLEM2(data, gui)

updateSideSelection();
updateVisualization();
updateResults();

% Disable push button
if gui.IsUpdated
    set(gui.PushButton_RC, 'BackgroundColor', 'g', 'Enable', 'off');
else 
    set(gui.PushButton_RC, 'BackgroundColor', 'y', 'Enable', 'on');
end

% Functions
%-------------------------------------------------------------------------%
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
%-------------------------------------------------------------------------%
function updateVisualization()
    if gui.IsUpdated == true           
        delete(gui.Axis_Vis.Children);
        visualizeTLEM2(data.LE, data.MuscleList, gui.Axis_Vis);
    end
end
%-------------------------------------------------------------------------%
function updateResults
    % Plot HJF vector
    if gui.IsUpdated
        
        % In frontal view
        delete(gui.FV_Axis.Children);
        visualizeTLEM2(data.LE, data.MuscleList, gui.FV_Axis, ...
            'Bones', 1, 'Joints', false, 'Muscles', false);
        gui.FV_Axis.View = [90, 0];
        gui.FV_Axis.CameraUpVector = [0, 1, 0];
        
        quiver3D(gui.FV_Axis, -data.rDir*40, data.rDir*40, 'r')
            
        % In lateral view
        delete(gui.SV_Axis.Children);
        visualizeTLEM2(data.LE, data.MuscleList, gui.SV_Axis, ...
            'Bones', 1, 'Joints', false, 'Muscles', false);
        switch data.Side
            case 'L'
                gui.SV_Axis.View = [0, -90];
        end
        gui.SV_Axis.CameraUpVector = [0, 1, 0];
        
        quiver3D(gui.SV_Axis, -data.rDir*40, data.rDir*40, 'r')
        
        drawnow
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
     
end
%-------------------------------------------------------------------------%
end
