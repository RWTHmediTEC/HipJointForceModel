function data = scaleTLEM2(data)

% Create scaling matrices
scaleTFM = repmat(eye(4), 1, 1, length(data.T.LE));

%% Scale factors
switch data.ScalingLaw
    case 'NonuniformSedghi2017'
        PD = 1;
        PH =  data.S.Scale(1).PelvicHeight / data.T.Scale(1).PelvicHeight;
        PW = (data.S.Scale(1).PelvicWidth - data.S.Scale(1).HipJointWidth) / ...
             (data.T.Scale(1).PelvicWidth - data.T.Scale(1).HipJointWidth);
        FemoralLength = (0.53-0.285)*data.S.BodyHeight*10; % [cm] to [mm] [Winter 2009, S.83, Fig.4.1]
        FL = FemoralLength / data.T.Scale(2).FemoralLength;
        % !!! Sedghi2017 used a slightly different definition than the one implemented here !!!
        FW = data.S.Scale(2).FemoralWidth / data.T.Scale(2).FemoralWidth;
    case 'NonuniformEggert2018'
        % Patient specific scaling of TLEM2 by ASISDistance, HJCASISHeight,
        % pelvic depth and femoral length
        PD = data.S.Scale(1).PelvicDepth   / data.T.Scale(1).PelvicDepth;
        PH = data.S.Scale(1).HJCASISHeight / data.T.Scale(1).HJCASISHeight;
        PW = data.S.Scale(1).ASISDistance  / data.T.Scale(1).ASISDistance;
        FL = data.S.Scale(2).FemoralLength / data.T.Scale(2).FemoralLength;
        FW = 1;
    case 'ParameterSkinningFischer2018'
        PD = data.S.Scale(1).PelvicDepth   / data.T.Scale(1).PelvicDepth;
        PH = data.S.Scale(1).HJCASISHeight / data.T.Scale(1).HJCASISHeight;
        PW = data.S.Scale(1).ASISDistance  / data.T.Scale(1).ASISDistance;
        FL = 1;
        FW = 1;
    case {'None','LandmarkSkinningFischer2018'}
        [PD, PH, PW, FL, FW] = deal(1);
    otherwise
        error('Invalid scaling law!')
end

if any(isnan([PD, PH, PW, FL, FW]))
    errMessage = ['At least one of the scaling parameters is nan. '...
        'Choose another cadaver to use this scaling law!'];
    msgbox(errMessage,mfilename,'error')
    error(errMessage)
end


% Pelvis
scaleTFM(1,1,1) = PD;
scaleTFM(2,2,1) = PH;
scaleTFM(3,3,1) = PW;

% Femur
scaleTFM(2,2,2) = FL;
scaleTFM(3,3,2) = FW;

% Scaling of patella, tibia, talus and foot by femoral length
if size(scaleTFM,3) > 2 && ~isnan(data.T.Scale(2).FemoralLength)
    scaleTFM(2,2,3:end) = data.S.Scale(2).FemoralLength / data.T.Scale(2).FemoralLength;
end

%% Scale
data.S.LE = transformTLEM2(data.T.LE, scaleTFM);

%% Skinning
switch data.ScalingLaw
    case 'ParameterSkinningFischer2018'
        data = skinFemurLEM(data,'ParameterBased');
    case 'LandmarkSkinningFischer2018'
        data = skinPelvisLEM(data,'LandmarkBased');
        data = skinFemurLEM(data,'LandmarkBased');
end

%% Correct bone coordinate systems
% Bone CSs may have changed due to scaling and have to be corrected
boneCS_TFM = repmat(eye(4), 1, 1, 6);
% Pelvis
boneCS_TFM(:,:,1) = createPelvisCS_TFM_LEM(data.S.LE, ...
    'definition',data.PelvicCS, 'verbose',data.Verbose);
% Femur. Should be always the right side 'R' before scaling.
boneCS_TFM(:,:,2) = createFemurCS_TFM_Wu2002_TLEM2(data.S.LE, 'R', 'verbose',data.Verbose);

data.S.LE = transformTLEM2(data.S.LE, boneCS_TFM);

end