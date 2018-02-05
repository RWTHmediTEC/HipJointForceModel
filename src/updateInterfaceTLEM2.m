function updateInterfaceTLEM2(data, gui)

updateSideSelection();
updateVisualization();
updateResults();

% Disable push button
if gui.IsUpdated == true
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
    % Adjust force arrows
    if gui.IsUpdated == true
        
        % Frontal Arrow
        delete(gui.FV_Axis.Children);
        imagesc(gui.FV_Axis,imread('front_hrc.png'));
        
        % Coordinates of the arrow
        if data.Side == 'L'
            xS = 569;
        else 
            xS = 188;
        end
        
        xStart = xS - 100 * sind(data.rPhi);
        yStart = 379 + 100 * cosd(data.rPhi);
        Start = [xStart yStart];
        xStop = xS;
        yStop = 379;
        Stop = [xStop yStop];
            
        gui.FrontalArrow = arrow(Start, Stop,...
                                    'Color', 'b',...
                                    'LineWidth', 2,...
                                    'Length',10000);
            
        set(gui.FrontalArrow, 'Parent', gui.FV_Axis);              
        set(gui.FV_Axis,...
                'PlotBoxAspectRatioMode', 'manual',...
                'PlotBoxAspectRatio', [746 593 1],...
                'XTick', [],...
                'YTick', [],...    
                'Ydir','reverse');
            
        % Sagittal Arrow
        delete(gui.SV_Axis.Children);
        imagesc(gui.SV_Axis,imread('right_hrc.png'));

        % Coordinates of the arrow
        xStart = 268 + 100 * sind(data.rTheta);
        yStart = 379 + 100 * cosd(data.rTheta);
        Start = [xStart yStart];
        xStop = 268;
        yStop = 379;
        Stop = [xStop yStop];
            
        gui.SagittalArrow = arrow(Start, Stop,...
                                    'Color', 'b',...
                                    'LineWidth', 2,...
                                    'Length',10000);
            
        set(gui.SagittalArrow, 'Parent', gui.SV_Axis);
        
        if data.Side == 'L'
            set(gui.SV_Axis, 'XDir', 'reverse');
        else
            set(gui.SV_Axis, 'XDir', 'normal');
        end
            
        set(gui.SV_Axis,...
                'PlotBoxAspectRatioMode', 'manual',...
                'PlotBoxAspectRatio', [436 593 1],...
                'XTick', [],...
                'YTick', [],...
                'Ydir','reverse');
     end
                
     if gui.IsUpdated == true
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
