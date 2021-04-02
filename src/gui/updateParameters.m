function gui = updateParameters(data, gui)
%UPDATEPARAMETERS updates the patient-specific parameters in the GUI
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

set(gui.Home.Parameters.EditText.BodyWeight,     'String', data.S.BodyWeight);
set(gui.Home.Parameters.EditText.BodyHeight,     'String', data.S.BodyHeight);
set(gui.Home.Parameters.EditText.HipJointWidth,  'String', data.S.Scale(1).HipJointWidth);
set(gui.Home.Parameters.EditText.PelvicTilt,     'String', data.S.PelvicTilt);
set(gui.Home.Parameters.EditText.ASISDistance,   'String', data.S.Scale(1).ASISDistance);
set(gui.Home.Parameters.EditText.HJCASISHeight,  'String', data.S.Scale(1).HJCASISHeight);
set(gui.Home.Parameters.EditText.PelvicWidth,    'String', data.S.Scale(1).PelvicWidth);
set(gui.Home.Parameters.EditText.PelvicHeight,   'String', data.S.Scale(1).PelvicHeight);
set(gui.Home.Parameters.EditText.PelvicDepth,    'String', data.S.Scale(1).PelvicDepth);
set(gui.Home.Parameters.EditText.FemoralLength,  'String', data.S.Scale(2).FemoralLength);
set(gui.Home.Parameters.EditText.FemoralWidth,   'String', data.S.Scale(2).FemoralWidth);
set(gui.Home.Parameters.EditText.FemoralVersion, 'String', data.S.Scale(2).FemoralVersion);
set(gui.Home.Parameters.EditText.CCD,            'String', data.S.Scale(2).CCD);
set(gui.Home.Parameters.EditText.NeckLength,     'String', data.S.Scale(2).NeckLength);

end