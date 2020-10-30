function data = createDataTLEM2(data, Cadaver)
% References:
% [Carbone 2015] 2015 - Carbone - TLEM 2.0 - A comprehensive  
% musculoskeletal geometry dataset for subject-specific modeling of lower 
% extremity
% [Winter 2009] 2009 - Winter - Biomechanics and Motor Control of Human 
% Movement - Fourth Edition
% [Destatis 2018] 2018 - Destatis - Mikrozensus 2017 - Fragen zur 
% Gesundheit - Körpermaße der Bevölkerung

% Build structure which contains default data
if nargin == 0 || isempty(data)
    data.Verbose = 1;
    % g-Force
    data.g = 9.81;
    % Cadaver
    Cadaver = 'TLEM2_0';
    % View of the HJF: Pelvis; Femur
    data.View = 'Femur';
    % Scaling law
    data.ScalingLaw = 'None';
    % Muscle Recruitemnt Criterion: None, MinMax, Polynom2, Polynom3, Polynom5, Energy
    data.MuscleRecruitmentCriterion = 'None';
    % Muscle Path Model: StraightLine, ViaPoint, Wrapping
    data.MusclePathModel = 'StraightLine';
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
        data.SurfaceData=true;
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
        data.SurfaceData = true;
    case 'Dostal1981'
        [LE, Scale] = Dostal1981;
        muscleList = Johnston1979toDostal1981(Johnston1979, Dostal1981);
        data.T.BodyWeight = 77; % Generic body weight [kg] [Destatis 2018]
        data.T.BodyHeight = 172; % Generic body height [cm] [Destatis 2018]
        data.SurfaceData = false;
    case 'Fick1850'
        [LE, muscleList] = Fick1850;
        data.T.BodyWeight = 77; % Generic body weight [kg] [Destatis 2018]
        data.T.BodyHeight = 172; % Generic body height [cm] [Destatis 2018]
        data.SurfaceData = false;
    otherwise
        error('No valid TLEM version')
end

data.T.LE = LE;

%% Check if muscle list contains PCSA normalized by the Gluteus Maximus
GluteusMaximusIdx = find(contains(muscleList(:,1),'GluteusMaximus'), 1);
if ~isempty(GluteusMaximusIdx)
    if muscleList{GluteusMaximusIdx,5} <= 1
        % Taken from Table 3: 2009 - Ward - Are current measurements of 
        % lower extremity muscle architecture accurate?
        GTM_MEAN_PCSA = 33.4*100; % [mm²]
        muscleList(:,5) = cellfun(@(x) x*GTM_MEAN_PCSA, muscleList(:,5), 'uni',0);
    end
end
data.MuscleList = muscleList;

%% Save initally as (T)emplate (Cadaver) and (S)ubject (Patient)
data.S.Side       = data.T.Side;
data.S.BodyWeight = data.T.BodyWeight;
data.S.BodyHeight = data.T.BodyHeight;
data.S.PelvicTilt = data.T.PelvicTilt;
data.S.LE         = data.T.LE;

%% Bony landmarks
if isfield(data.T, 'Scale')
    data.T = rmfield(data.T, 'Scale');
end
if data.SurfaceData
    % Pelvic skinning landmarks
    data.T.Scale(1).Landmarks = struct(...
        'HJC',LE(1).Joints.Hip.Pos,...
        'IIT',LE(1).Mesh.vertices(LE(1).Landmarks.InferiorIschialTuberosity_R.Node,:), ...
        'PIT',LE(1).Mesh.vertices(LE(1).Landmarks.PosteriorIschialTuberosity_R.Node,:), ...
        'IS',LE(1).Mesh.vertices(LE(1).Landmarks.RightIschialSpine.Node,:), ...
        'PIIS',LE(1).Mesh.vertices(LE(1).Landmarks.PosteriorInferiorIliacSpine_R.Node,:), ...
        'PSIS',LE(1).Mesh.vertices(LE(1).Landmarks.RightPosteriorSuperiorIliacSpine.Node,:), ...
        'SIC',LE(1).Mesh.vertices(LE(1).Landmarks.SuperiorIliacCrest_R.Node,:), ...
        'IT',LE(1).Mesh.vertices(LE(1).Landmarks.IliacTubercle_R.Node,:), ...
        'ASIS',LE(1).Mesh.vertices(LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Node,:),...
        'AIIS',LE(1).Mesh.vertices(LE(1).Landmarks.RightAnteriorInferiorIliacSpine.Node,:),...
        'PT',LE(1).Mesh.vertices(LE(1).Landmarks.RightPubicTubercle.Node,:),...
        'MP',LE(1).Mesh.vertices(LE(1).Landmarks.MedialPubis_R.Node,:));
    data.T.Scale(1).boneCSLandmarks  = struct(...
        'ASIS_L',LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos, ...
        'ASIS_R',LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos, ...
        'PSIS_L',LE(1).Landmarks.LeftPosteriorSuperiorIliacSpine.Pos, ...
        'PSIS_R',LE(1).Landmarks.RightPosteriorSuperiorIliacSpine.Pos);
    % Femoral skinning landmarks
    data.T.Scale(2).Landmarks = struct(...
        'HJC',LE(2).Joints.Hip.Pos,... % Hip joint center
        'P1',LE(2).Landmarks.P1.Pos,... % Straight femur axis (proximal point: P1) [Bergmann2016]
        'P2',LE(2).Mesh.vertices(LE(2).Landmarks.P2.Node,:),... % Straight femur axis (distal point: P2) [Bergmann2016]
        'MEC',LE(2).Landmarks.MedialEpicondyle.Pos,...
        'LEC',LE(2).Landmarks.LateralEpicondyle.Pos,...
        'MPC',LE(2).Mesh.vertices(LE(2).Landmarks.MedialPosteriorCondyle.Node,:),...
        'LPC',LE(2).Mesh.vertices(LE(2).Landmarks.LateralPosteriorCondyle.Node,:),...
        'GT',LE(2).Mesh.vertices(LE(2).Landmarks.SuperiorGreaterTrochanter.Node,:),...
        'LT',LE(2).Mesh.vertices(LE(2).Landmarks.LesserTrochanter.Node,:));
end

%% Scaling parameters
% If no landmarks or parameters are available assign with nan and return
if ~isfield(data.T, 'Scale') && ~exist('Scale', 'var')
    [data.T.Scale(1).HipJointWidth,...
        data.T.Scale(1).ASISDistance,...
        data.T.Scale(1).HJCASISHeight,...
        data.T.Scale(1).PelvicWidth,...
        data.T.Scale(1).PelvicHeight,...
        data.T.Scale(1).PelvicDepth,...
        data.T.Scale(2).FemoralLength,...
        data.T.Scale(2).FemoralWidth,...
        data.T.Scale(2).FemoralVersion,...
        data.T.Scale(2).NeckLength,...
        data.T.Scale(2).CCD] = deal(nan);
    data.S.Scale = data.T.Scale;
    return
end

% Pelvic parameters:
% Transform the landmarks into the pelvic coordinate system [Wu 2002]
pTFM = createPelvisCS_TFM_Wu2002_TLEM2(data.T.LE, 'verbose',data.Verbose);

% PelvicDepth = posteroanterior distance between ASIS and PSIS
switch Cadaver
    case{'TLEM2_0','TLEM2_1'}
        PSIS2ASIS = ...
            transformPoint3d(data.T.LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos, pTFM) - ...
            transformPoint3d(data.T.LE(1).Landmarks.RightPosteriorSuperiorIliacSpine.Pos, pTFM);
        data.T.Scale(1).PelvicDepth = abs(PSIS2ASIS(1));
    case 'Dostal1981'
        data.T.Scale(1).PelvicDepth = Scale(1).PelvicDepth;
end

% PelvicHeight = Inferosuperior distance between most inferior and superior
% pelvic landmarks 
switch Cadaver
    case{'TLEM2_0','TLEM2_1'}
        IIT2SIP = ...
            transformPoint3d(data.T.LE(1).Landmarks.SuperiorIliacCrest_R.Pos, pTFM) - ...
            transformPoint3d(data.T.LE(1).Landmarks.InferiorIschialTuberosity_R.Pos, pTFM);
        data.T.Scale(1).PelvicHeight = abs(IIT2SIP(2));
    case 'Dostal1981'
        data.T.Scale(1).PelvicHeight = Scale(1).PelvicHeight;
end
% HJCASISHeight = inferosuperior distance between the HJC and ASIS
HJC2ASISDist = ...
    transformPoint3d(data.T.LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos, pTFM) - ...
    transformPoint3d(data.T.LE(1).Joints.Hip.Pos, pTFM);
data.T.Scale(1).HJCASISHeight = abs(HJC2ASISDist(2));

% HipJointWidth = mediolateral distance between the hip joint centers
switch Cadaver
    case{'TLEM2_0','TLEM2_1'}
        % !!! Assuming symmetry of the pelvis !!!
        % !!! No consideration of the width of the pubic symphysis !!!
        hipBoneVertices = transformPoint3d(data.T.LE(1).Mesh.vertices, pTFM);
        HJC = transformPoint3d(data.T.LE(1).Joints.Hip.Pos, pTFM);
        data.T.Scale(1).HipJointWidth = ...
            2 * abs(HJC(3) - min(hipBoneVertices(:,3)));
    case 'Dostal1981'
        data.T.Scale(1).HipJointWidth = abs(...
            LE(1).Landmarks.RightHipJointCenter.Pos(3)-...
            LE(1).Landmarks.LeftHipJointCenter.Pos(3));
end
% ASISDistance: mediolateral distance between the two ASIS
ASISDistance = ...
    transformPoint3d(data.T.LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos, pTFM) - ...
    transformPoint3d(data.T.LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos, pTFM);
data.T.Scale(1).ASISDistance = abs(ASISDistance(3));
% Pelvic width: mediolateral distance between the most lateral pelvic 
% landmarks located at the iliac tubercles.
switch Cadaver
    case{'TLEM2_0','TLEM2_1'}
        % !!! Assuming symmetry of the pelvis !!!
        % !!! No consideration of the width of the pubic symphysis !!!
        IT = transformPoint3d(data.T.LE(1).Landmarks.IliacTubercle_R.Pos, pTFM);
        data.T.Scale(1).PelvicWidth = 2 * abs(IT(3) - min(hipBoneVertices(:,3)));
    case 'Dostal1981'
        data.T.Scale(1).PelvicWidth = Scale(1).PelvicWidth;
end

%% Femoral parameters
% Transform the landmarks into the femoral coordinate system [Wu 2002]
% Cadaver should always be a right side: 'R'
fTFM = createFemurCS_TFM_Wu2002_TLEM2(data.T.LE, 'R', 'verbose',data.Verbose);
% FemoralLength: Distance between the midpoint between medial and lateral 
% epicondyle and the HJC.
data.T.Scale(2).FemoralLength = distancePoints3d(transformPoint3d(midPoint3d(...
    data.T.LE(2).Landmarks.MedialEpicondyle.Pos,... 
    data.T.LE(2).Landmarks.LateralEpicondyle.Pos), fTFM), ...
    transformPoint3d(data.T.LE(2).Joints.Hip.Pos, fTFM));
% FemoralWidth: Distance between the HJC and the greater trochanter along 
% the Z-Axis. Use Piriformis insertion as greater trochanter.
HJC2PiriformisInsertion = ...
    transformPoint3d(data.T.LE(2).Muscle.Piriformis1.Pos, fTFM) - ...
    transformPoint3d(data.T.LE(2).Joints.Hip.Pos, fTFM);
data.T.Scale(2).FemoralWidth = abs(HJC2PiriformisInsertion(3));

if data.SurfaceData
    data.T.Scale(2).FemoralVersion = measureFemoralVersionBergmann2016(...
        data.T.Scale(2).Landmarks.HJC, ...
        data.T.Scale(2).Landmarks.P1, ...
        data.T.Scale(2).Landmarks.P2, ...
        data.T.Scale(2).Landmarks.MPC, ...
        data.T.Scale(2).Landmarks.LPC);
    % NeckLength: Distance between the hip joint center and the point where
    %             the neck axis and the straight femur axis cross
    data.T.Scale(2).NeckLength = distancePoints3d(...
        data.T.Scale(2).Landmarks.HJC, data.T.Scale(2).Landmarks.P1);
    % CCD: Angle between the neck axis and the straight femur axis
    data.T.Scale(2).CCD = rad2deg(vectorAngle3d(...
        data.T.Scale(2).Landmarks.P2 - data.T.Scale(2).Landmarks.P1, ...
        data.T.Scale(2).Landmarks.HJC - data.T.Scale(2).Landmarks.P1));
else
    data.T.Scale(2).FemoralVersion = nan;
    data.T.Scale(2).NeckLength = nan;
    data.T.Scale(2).CCD = nan;
end

data.S.Scale = data.T.Scale;

end