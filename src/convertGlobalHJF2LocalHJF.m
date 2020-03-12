function data = convertGlobalHJF2LocalHJF(R, data)

% Convert R from [N] to [%BW]
R = R / abs(data.S.BodyWeight * data.g) * 100;

data.HJF.Global.R=R;

% Pelvis bone CS
data.HJF.Pelvis.Wu2002.R = transformVector3d(R, ...
    createPelvisCS_TFM_Wu2002_TLEM2(data.S.LE));

% Reverse (=negative) R for femur bone CS
% [Wu 2002]
data.HJF.Femur.Wu2002.R = transformVector3d(-R, ...
    createFemurCS_TFM_Wu2002_TLEM2(data.S.LE, data.S.Side));
% [Bergmann 2016]
data.HJF.Femur.Bergmann2016.R = transformVector3d(-R, ...
    createFemurCS_TFM_Bergmann2016_TLEM2(data.S.LE, data.S.Side));

end