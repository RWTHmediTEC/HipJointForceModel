function data = convertGlobalHJF2LocalHJF(R, data)

if data.S.Side == 'L'
    R(3) = -R(3);
end

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
TFMx = createRotationOx(deg2rad(jointAngles(1)));
TFMy = createRotationOy(deg2rad(jointAngles(2)));
TFMz = createRotationOz(deg2rad(jointAngles(3)));
R = transformVector3d(R, TFMx*TFMy*TFMz);

rMag = norm(R); % Magnitude of R
rMagP = rMag / abs(data.S.BodyWeight) * 100; % Magnitude of R in % body weight
rDir = normalizeVector3d(R); % Direction of R

rPhi   = atand(R(3)/R(2)); % Angle in frontal plane
rTheta = atand(R(1)/R(2)); % Angle in sagittal plane
rAlpha = atand(R(1)/R(3)); % Angle in transverse plane

% Save results in data
data.rX     = R(1);
data.rY     = R(2);
data.rZ     = R(3);
data.rDir   = rDir;
data.rMag   = rMag;
data.rMagP  = rMagP;
data.rPhi   = rPhi;
data.rTheta = rTheta;
data.rAlpha = rAlpha;