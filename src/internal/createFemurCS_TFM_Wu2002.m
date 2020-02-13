function TFM = createFemurCS_TFM_Wu2002(MEC, LEC, HJC)
% Midpoint between the epicondyles
MEC_LEC_midPoint=midPoint3d(MEC, LEC);
% Mechanical axis is the connection of EC midpoint and hip joint center
MechanicalAxis = createLine3d(MEC_LEC_midPoint, HJC);
% Connection of the epicondyles
EpicondyleAxis = createLine3d(MEC, LEC);

Y = normalizeVector3d(MechanicalAxis(4:6));
X = normalizeVector3d(crossProduct3d(MechanicalAxis(4:6), EpicondyleAxis(4:6)));
Z = normalizeVector3d(crossProduct3d(X, Y));

TFM = inv([[inv([X; Y; Z]), HJC']; [0 0 0 1]]);

end
