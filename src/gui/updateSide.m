function gui = updateSide(data, gui)
%UPDATESIDE updates the side radio buttons
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

set(gui.Home.Parameters.RadioButton_L, 'Value', 0);
set(gui.Home.Parameters.RadioButton_R, 'Value', 0);
switch data.S.Side
    case 'L'
        set(gui.Home.Parameters.RadioButton_L, 'Value', 1);
    case 'R'
        set(gui.Home.Parameters.RadioButton_R, 'Value', 1);
end

end