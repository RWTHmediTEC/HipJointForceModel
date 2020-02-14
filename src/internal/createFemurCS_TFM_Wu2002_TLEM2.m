function TFM = createFemurCS_TFM_Wu2002_TLEM2(LE)
% Wrapper function for createFemurCS_TFM_Wu2002 and the LE struct

MEC = LE(2).Landmarks.MedialEpicondyle.Pos;
LEC = LE(2).Landmarks.LateralEpicondyle.Pos;
HJC = LE(2).Joints.Hip.Pos;

TFM = createFemurCS_TFM_Wu2002(MEC, LEC, HJC);

end
