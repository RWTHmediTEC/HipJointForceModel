function data = createDataTLEM2(data, TLEMversion)

if nargin == 0
    TLEMversion = 'TLEM2_0';
    % Build structure which contains default data
    data.View = 'Femur';                     % View of the HJF: Pelvis; Femur
    data.FemoralTransformation = 'Skinning'; % Femoral transformation method: Scaling; Skinning
    data.MusclePath = 'StraightLine';        % Muscle Path Model: StraightLine; ViaPoint; ObstacleSet
    data.T.Side = 'R';                       % Side of the hip joint: R:Right; L:Left
    data.T.BodyWeight = 45;                  % Patient's body weight [kg]
    data.T.PelvicBend = 0;                   % Pelvic Bend [°]
end

data.TLEMversion = TLEMversion;

switch TLEMversion
    case 'TLEM2_0'
        if ~exist('data\TLEM2_0.mat', 'file')
            importDataTLEM2_0
        end
        load('TLEM2_0', 'LE', 'muscleList')
    case 'TLEM2_1'
        if ~exist('data\TLEM2_1.mat', 'file')
            if ~exist('data\TLEM2_0.mat', 'file')
                importDataTLEM2_0
            end
            load('TLEM2_0', 'LE', 'muscleList')
            importDataTLEM2_1(LE, muscleList);
        end
        load('TLEM2_1', 'LE', 'muscleList')
    otherwise
        error('No valid TLEM version')
end

data.T.LE = LE;
data.MuscleList = muscleList;

%% Scaling and skinning parameters

% Pelvic parameters:
% HipJointWidth  = Distance between the hip joint centers
% PelvicWidth    = Distance between the two ASISs along Z-Axis
% PelvicHeight   = Distance between HRC and ASIS along Y-Axis
% PelvicDepth    = Distance between ASIS and PSIS along X-Axis
%
% Femoral parameters:
% FemoralLength  = Distance between HRC and the midpoint between medial 
%                  and lateral epicondyle along y-Axis
% FemoralVersion = Angle between neck axis and condylar line projected 
%                  on transverse plane 
% NeckLength     = Distance between hip joint center projected on neck axis
%                  and point where the neck axis and straight femur axis cross
% CCD            = Angle between neck axis and straight femur axis

% Pelvic parameters % !!! Use consistent landmarks (either TLEM or vertices) 
data.T.Scale(1).HipJointWidth = 2 * (...
    data.T.LE(1).Joints.Hip.Pos(3) -... 
    min(data.T.LE(1).Mesh.vertices(:,3)));  % No consideration of width of the pubic symphysis
data.T.Scale(1).PelvicWidth  =...
    data.T.LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(3) -...
    data.T.LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos(3);
data.T.Scale(1).PelvicHeight =...
    data.T.LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(2);
data.T.Scale(1).PelvicDepth =...
    data.T.LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(1) -...
    data.T.LE(1).Landmarks.RightPosteriorSuperiorIliacSpine.Pos(1);

% Load controls [Bergmann2016]
load(['femur' data.TLEMversion 'Controls'], 'Controls', 'LMIdx')
% Construct reference line to measure femoral version
postConds = [...
    data.T.LE(2).Mesh.vertices(LMIdx.MedialPosteriorCondyle,:);...
    data.T.LE(2).Mesh.vertices(LMIdx.LateralPosteriorCondyle,:)];
transversePlane = createPlane(Controls(3,:), Controls(2,:) - Controls(3,:));
projPostCond = projPointOnPlane(postConds, transversePlane);
projPostCondLine = createLine3d(projPostCond(1,:), projPostCond(2,:));
projNeckPoints = projPointOnPlane(Controls(1:2,:), transversePlane);
projNeckLine = createLine3d(projNeckPoints(1,:), projNeckPoints(2,:));

% Femoral parameters
data.T.Scale(2).FemoralLength = data.T.LE(2).Joints.Hip.Pos(2); % !!! Need to be changed for skinning in Bergmann CS
data.T.Scale(2).FemoralVersion = rad2deg(vectorAngle3d(projNeckLine(4:6), projPostCondLine(4:6)));
data.T.Scale(2).NeckLength = distancePoints3d(Controls(1,:), Controls(2,:));
data.T.Scale(2).CCD = rad2deg(vectorAngle3d(Controls(3,:) - Controls(2,:), Controls(1,:) - Controls(2,:)));

%% Save initally as (T)emplate and (S)ubject
              
data.S.Side       = data.T.Side;
data.S.BodyWeight = data.T.BodyWeight;
data.S.PelvicBend = data.T.PelvicBend;

data.S.LE    = data.T.LE;
data.S.Scale = data.T.Scale;

end