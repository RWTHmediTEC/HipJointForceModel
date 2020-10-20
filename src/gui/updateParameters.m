function gui = updateParameters(data, gui)

set(gui.Home.Parameters.EditText.BodyWeight,     'String', data.S.BodyWeight);
set(gui.Home.Parameters.EditText.BodyHeight,     'String', data.S.BodyHeight);
set(gui.Home.Parameters.EditText.HipJointWidth,  'String', data.S.Scale(1).HipJointWidth);
set(gui.Home.Parameters.EditText.PelvicTilt,     'String', data.S.PelvicTilt);
set(gui.Home.Parameters.EditText.ASISWidth,      'String', data.S.Scale(1).ASISWidth);
set(gui.Home.Parameters.EditText.PelvicHeight,   'String', data.S.Scale(1).PelvicHeight);
set(gui.Home.Parameters.EditText.PelvicDepth,    'String', data.S.Scale(1).PelvicDepth);
set(gui.Home.Parameters.EditText.FemoralLength,  'String', data.S.Scale(2).FemoralLength);
set(gui.Home.Parameters.EditText.FemoralWidth,   'String', data.S.Scale(2).FemoralWidth);
set(gui.Home.Parameters.EditText.FemoralVersion, 'String', data.S.Scale(2).FemoralVersion);
set(gui.Home.Parameters.EditText.CCD,            'String', data.S.Scale(2).CCD);
set(gui.Home.Parameters.EditText.NeckLength,     'String', data.S.Scale(2).NeckLength);

end