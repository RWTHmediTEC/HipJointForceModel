function data = convertGlobalHJF2LocalHJF(R, data)

% Convert R from [N] to [%BW]
R = R / abs(data.S.BodyWeight*9.81) * 100;

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


switch data.View
    case 'Pelvis'
        % Joint angles of the pelvis
        jointAngles=data.jointAngles{1};
    case 'Femur'
        % Reverse HJF
        R=-R;
        % Joint angles of the femur
        jointAngles=data.jointAngles{2};
    otherwise
        error('Pelvis or Femur?')
end
% Transform back into bone CS -> use negative joint angles
switch data.S.Side
    % Rotation around x axis depends on the side
    case 'R'
        TFMx = createRotationOx(deg2rad(-jointAngles(1)));
    case 'L'
        TFMx = createRotationOx(deg2rad( jointAngles(1)));
end
TFMy = createRotationOy(deg2rad(-jointAngles(2)));
TFMz = createRotationOz(deg2rad(-jointAngles(3)));
TFM = TFMx*TFMy*TFMz;

R = transformVector3d(R, TFM);

rDir = normalizeVector3d(R); % Direction of R

rPhi   = atand(R(3)/R(2)); % Angle in frontal plane
rTheta = atand(R(1)/R(2)); % Angle in sagittal plane
rAlpha = atand(R(1)/R(3)); % Angle in transverse plane

% Save results in data
data.rX     = R(1);
data.rY     = R(2);
data.rZ     = R(3);
data.rDir   = rDir;
data.rPhi   = rPhi;
data.rTheta = rTheta;
data.rAlpha = rAlpha;