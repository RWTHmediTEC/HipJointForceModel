function data = createDataTLEM2(data, TLEMversion)

if nargin == 0
    TLEMversion='TLEM2_0';
    % Build structure which contains default data
    data.View=1;               % View of the HJF, 1:Pelvis, 2:Femur
    data.T.Side='R';           % Side of the hip joint, R:Right, L:Left
    data.T.BodyWeight=45;      % Patient's body weight [kg]
    data.T.PelvicBend=0;       % Pelvic Bend [°] ??? Is this Bend or Tilt ???
end

data.Dataset=TLEMversion;

switch TLEMversion
    case 'TLEM2_0'
        if ~exist('data\TLEM2.mat', 'file')
            importDataTLEM2
        end
        load('TLEM2', 'LE', 'muscleList')
    case 'TLEM2_1'
        if ~exist('data\TLEM2_1.mat', 'file')
            if ~exist('data\TLEM2.mat', 'file')
                importDataTLEM2
            end
            load('TLEM2', 'LE', 'muscleList')
            importDataTLEM2_1(LE, muscleList);
        end
        load('TLEM2_1', 'LE', 'muscleList')
    otherwise
        error('No valid TLEM version')
end

data.T.LE = LE;

%% Scaling parameters
% Pelvis
data.T.Scale(1).HipJointWidth = 2* (...
    LE(1).Joints.Hip.Pos(3)-... 
    min(LE(1).Mesh.vertices(:,3)));  % No consideration of width of the pubic symphysis
data.T.Scale(1).PelvicWidth  = ...
    LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(3) -...
    LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos(3);
data.T.Scale(1).PelvicHeight = ...
    LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(2);
data.T.Scale(1).PelvicDepth  = ...
    LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(1) -...
    LE(1).Landmarks.RightPosteriorSuperiorIliacSpine.Pos(1);
% Femur
% ??? What's the definition of this value by landmarks: Wu2002 ???
%       Should be the same as in OrthoLoad
data.T.Scale(2).FemoralLength  = LE(2).Joints.Hip.Pos(2);
% Load Controls [Bergmann2016]
load('femurTLEM2Controls', 'Controls','LMIdx')
% Construct reference line to measure antetorsion
postConds=[...
    LE(2).Mesh.vertices(LMIdx.MedialPosteriorCondyle,:); ...
    LE(2).Mesh.vertices(LMIdx.LateralPosteriorCondyle,:)];
transversePlane=createPlane(Controls(3,:), Controls(2,:)-Controls(3,:));
projPostCond=projPointOnPlane(postConds,transversePlane);
projPostCondLine=createLine3d(projPostCond(1,:),projPostCond(2,:));
% femoral version of the TLEM2 femur
projNeckPoints = projPointOnPlane(Controls(1:2,:),transversePlane);
projNeckLine = createLine3d(projNeckPoints(1,:),projNeckPoints(2,:));
data.T.Scale(2).FemoralVersion = rad2deg(vectorAngle3d(projNeckLine(4:6),projPostCondLine(4:6)));
% CCD of the TLEM2 femur
data.T.Scale(2).CCD = rad2deg(vectorAngle3d(Controls(3,:)-Controls(2,:), Controls(1,:)-Controls(2,:)));
% Neck length of the TLEM2 femur
data.T.Scale(2).NeckLength = distancePoints3d(Controls(1,:),Controls(2,:));

data.T.LE = LE;

%% Save initally as (T)emplate and (S)ubject
              
data.S.Side=data.T.Side;
data.S.BodyWeight=data.T.BodyWeight;
data.S.PelvicBend=data.T.PelvicBend;

data.LE = data.T.LE; % !!! Change to data.S.LE !!!
data.S.Scale = data.T.Scale;

data.MuscleList = muscleList;

end