function data = convertGlobalHJF2LocalHJF(R, data)
%CONVERTGLOBALHJF2LOCALHJF converts the HJF calculated in the global
% (world) coordinate system to the local bone coordinate systems.
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

% Convert R from [N] to [%BW]
R = R / abs(data.S.BodyWeight * data.g) * 100;

% Store global HJF
data.HJF.Global.R = R;

% Pelvic bone CS
data.HJF.Pelvis.(data.PelvicCS).R = transformVector3d(R, data.S.LE(1).positionTFM');
% Sanity Check
if data.SurfaceData
    assert(all(ismembertol(data.S.LE(1).positionTFM',...
        createPelvisCS_TFM_LEM(data.S.LE, 'definition',data.PelvicCS),...
        1e-6,'ByRows',1)))
end

% Reverse (=negative) R for femoral bone CS
% [Wu 2002]
data.HJF.Femur.Wu2002.R = transformVector3d(-R, data.S.LE(2).positionTFM');
% Sanity Check
if data.SurfaceData
    assert(all(ismembertol(data.S.LE(2).positionTFM',...
        createFemurCS_TFM_LEM(data.S.LE, 'R', 'definition','Wu2002'),...
        1e-6,'ByRows',1)))
end
% [Bergmann 2016]
data.HJF.Femur.Bergmann2016.R = transformVector3d(-R, ...
    createFemurCS_TFM_LEM(data.S.LE, 'R',...
    'definition','Bergmann2016', 'verbose',data.Verbose));

end