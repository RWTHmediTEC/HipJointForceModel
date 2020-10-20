function gui = updateParameters(data, gui)

set(gui.Home.Parameters.EditText_BodyWeight,     'String', data.S.BodyWeight);
set(gui.Home.Parameters.EditText_BodyHeight,     'String', data.S.BodyHeight);
set(gui.Home.Parameters.EditText_HipJointWidth,  'String', data.S.Scale(1).HipJointWidth);
set(gui.Home.Parameters.EditText_PelvicTilt,     'String', data.S.PelvicTilt);
set(gui.Home.Parameters.EditText_ASISWidth,      'String', data.S.Scale(1).ASISWidth);
set(gui.Home.Parameters.EditText_PelvicHeight,   'String', data.S.Scale(1).PelvicHeight);
set(gui.Home.Parameters.EditText_PelvicDepth,    'String', data.S.Scale(1).PelvicDepth);
set(gui.Home.Parameters.EditText_FemoralLength,  'String', data.S.Scale(2).FemoralLength);
set(gui.Home.Parameters.EditText_FemoralWidth,   'String', data.S.Scale(2).FemoralWidth);
set(gui.Home.Parameters.EditText_FemoralVersion, 'String', data.S.Scale(2).FemoralVersion);
set(gui.Home.Parameters.EditText_CCD,            'String', data.S.Scale(2).CCD);
set(gui.Home.Parameters.EditText_NeckLength,     'String', data.S.Scale(2).NeckLength);

end