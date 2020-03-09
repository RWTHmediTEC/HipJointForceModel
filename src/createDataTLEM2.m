function data = createDataTLEM2(data, Cadaver)
% References:
% [Carbone 2015] 2015 - Carbone - TLEM 2.0 - A comprehensive  
% musculoskeletal geometry dataset for subject-specific modeling of lower 
% extremity
% [Winter 2009] 2009 - Winter - Biomechanics and Motor Control of Human 
% Movement - Fourth Edition
% [Destatis 2018] 2018 - Destatis - Mikrozensus 2017 - Fragen zur 
% Gesundheit - Körpermaße der Bevölkerung

if nargin == 0
    % Build structure which contains default data
    data.View = 'Femur';                     % View of the HJF: Pelvis; Femur
    data.ScalingLaw = 'NonuniformEggert2018';% Scaling law: NonuniformEggert2018, Skinning
    data.MusclePathModel = 'StraightLine';   % Muscle Path Model: StraightLine; ViaPoint; Wrapping
    % Cadaver
    Cadaver = 'TLEM2_0';
    % Side of the hip joint: Right 'R'; Left 'L'
    data.T.Side = 'R';
    % Pelvic Tilt [°]
    data.T.PelvicTilt = 0;
end

data.Cadaver = Cadaver;

switch Cadaver
    case 'TLEM2_0'
        if ~exist('data\TLEM2_0.mat', 'file')
            importDataTLEM2_0;
        end
        load('TLEM2_0', 'LE', 'muscleList')
        data.T.BodyWeight = 45; % Cadavers's body weight [kg] [Carbone 2015]
        % Approximated from leg length of 813 mm [Carbone 2015] and [Winter 2009, S.83, Fig.4.1]
        data.T.BodyHeight = 813/10/0.53;
    case 'TLEM2_1'
        if ~exist('data\TLEM2_1.mat', 'file')
            if ~exist('data\TLEM2_0.mat', 'file')
                importDataTLEM2_0;
            end
            load('TLEM2_0', 'LE', 'muscleList')
            importDataTLEM2_1(LE, muscleList);
        end
        load('TLEM2_1', 'LE', 'muscleList')
        data.T.BodyWeight = 45; % Cadavers's body weight [kg] [Carbone 2015]
        % Approximated from leg length of 813 mm [Carbone 2015] and [Winter 2009, S.83, Fig.4.1]
        data.T.BodyHeight = 813/10/0.53; % [cm]
    case 'Dostal1981'
        [LE, Scale] = Dostal1981;
        muscleList = Johnston1979toDostal1981(Johnston1979, Dostal1981);
        data.T.BodyWeight = 77; % Generic body weight [kg] [Destatis 2018]
        data.T.BodyHeight = 172; % Generic body height [cm] [Destatis 2018]
    otherwise
        error('No valid TLEM version')
end

data.T.LE = LE;
data.MuscleList = muscleList;

%% Bony paramters

% !!! Use consistent definitions / landmarks !!!

% Pelvic parameters:
% HipJointWidth  = Distance between the hip joint centers
switch Cadaver
    case{'TLEM2_0','TLEM2_1'}
        % !!! No consideration of the width of the pubic symphysis !!!
        data.T.Scale(1).HipJointWidth = 2 * (...
            data.T.LE(1).Joints.Hip.Pos(3) -...
            min(data.T.LE(1).Mesh.vertices(:,3)));  
    case 'Dostal1981'
        data.T.Scale(1).HipJointWidth = abs(...
            LE(1).Landmarks.RightHipJointCenter.Pos(3)-...
            LE(1).Landmarks.LeftHipJointCenter.Pos(3));
end
% PelvicWidth    = Distance between the two ASISs along Z-Axis in Wu2002
% PelvicHeight   = Distance between HRC and ASIS along Y-Axis in Wu2002
data.T.Scale(1).PelvicWidth  = abs(...
    data.T.LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(3) - ...
    data.T.LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos(3));
data.T.Scale(1).PelvicHeight = abs(...
    data.T.LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(2));
% PelvicDepth    = Distance between ASIS and PSIS along X-Axis in Wu2002
switch Cadaver
    case{'TLEM2_0','TLEM2_1'}
        data.T.Scale(1).PelvicDepth = abs(...
            data.T.LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(1) - ...
            data.T.LE(1).Landmarks.RightPosteriorSuperiorIliacSpine.Pos(1));
    case 'Dostal1981'
        data.T.Scale(1).PelvicDepth = Scale(1).PelvicDepth;
end

% Femoral parameters:
% FemoralLength  = Distance between HRC and the midpoint between medial 
%                  and lateral epicondyle
% FemoralVersion = Angle between neck axis and condylar line projected 
%                  on transverse plane 
% NeckLength     = Distance between hip joint center projected on neck axis
%                  and point where the neck axis and straight femur axis cross
% CCD            = Angle between neck axis and straight femur axis

% Load controls [Bergmann2016]
if exist(['femur' data.Cadaver 'Controls.mat'],'file')
    load(['femur' data.Cadaver 'Controls.mat'], 'Controls')
    % Construct reference line to measure femoral version
    postConds = [...
        data.T.LE(2).Landmarks.MedialPosteriorCondyle.Pos;...
        data.T.LE(2).Landmarks.LateralPosteriorCondyle.Pos];
    transversePlane = createPlane(Controls(3,:), Controls(2,:) - Controls(3,:));
    projPostCond = projPointOnPlane(postConds, transversePlane);
    projPostCondLine = createLine3d(projPostCond(1,:), projPostCond(2,:));
    projNeckPoints = projPointOnPlane(Controls(1:2,:), transversePlane);
    projNeckLine = createLine3d(projNeckPoints(1,:), projNeckPoints(2,:));
    
    data.T.Scale(2).FemoralVersion = rad2deg(vectorAngle3d(projNeckLine(4:6), projPostCondLine(4:6)));
    data.T.Scale(2).NeckLength = distancePoints3d(Controls(1,:), Controls(2,:));
    data.T.Scale(2).CCD = rad2deg(vectorAngle3d(Controls(3,:) - Controls(2,:), Controls(1,:) - Controls(2,:)));
else
    data.T.Scale(2).FemoralVersion = nan;
    data.T.Scale(2).NeckLength = nan;
    data.T.Scale(2).CCD = nan;
end

% !!! Need to be changed for skinning in Bergmann CS !!!
data.T.Scale(2).FemoralLength = distancePoints3d(midPoint3d(...
    data.T.LE(2).Landmarks.MedialEpicondyle.Pos,... 
    data.T.LE(2).Landmarks.LateralEpicondyle.Pos), ...
    data.T.LE(2).Joints.Hip.Pos);


%% Save initally as (T)emplate and (S)ubject
data.S.Side       = data.T.Side;
data.S.BodyWeight = data.T.BodyWeight;
data.S.BodyHeight = data.T.BodyHeight;
data.S.PelvicTilt = data.T.PelvicTilt;

data.S.LE    = data.T.LE;
data.S.Scale = data.T.Scale;

end