function data = scaleTLEM2(data)

% Create scaling matrices
scaleTFM = repmat(eye(4), 1, 1, 6);

%% Scale factors
switch data.ScalingLaw
    case 'NonuniformEggert2018'
        % Patient specific scaling of TLEM2 by pelvic width, pelvic height,
        % pelvic depth and femoral length
        PD = data.S.Scale(1).PelvicDepth   / data.T.Scale(1).PelvicDepth;
        PH = data.S.Scale(1).PelvicHeight  / data.T.Scale(1).PelvicHeight;
        PW = data.S.Scale(1).PelvicWidth   / data.T.Scale(1).PelvicWidth;
        FL = data.S.Scale(2).FemoralLength / data.T.Scale(2).FemoralLength;
        FW = 1;
    case 'NonuniformSedghi2017'
        PD = 1;
        PH = data.S.Scale(1).PelvicHeight / data.T.Scale(1).PelvicHeight;
        % !!! Sedghi2017 may have used a different definition of the PelvicWidth !!!
        PW = (data.S.Scale(1).PelvicWidth - data.S.Scale(1).HipJointWidth) / ...
             (data.T.Scale(1).PelvicWidth - data.T.Scale(1).HipJointWidth);
        FemoralLength = (0.53-0.285)*data.S.BodyHeight*10; % [cm] to [mm] [Winter 2009, S.83, Fig.4.1]
        FL = FemoralLength / data.T.Scale(2).FemoralLength;
        % !!! Sedghi2017 used a slightly different definition than the one implemented here !!!
        FW = data.S.Scale(2).FemoralWidth / data.T.Scale(2).FemoralWidth;
    case 'ParameterSkinningFischer2018'
        PD = data.S.Scale(1).PelvicDepth   / data.T.Scale(1).PelvicDepth;
        PH = data.S.Scale(1).PelvicHeight  / data.T.Scale(1).PelvicHeight;
        PW = data.S.Scale(1).PelvicWidth   / data.T.Scale(1).PelvicWidth;
        FL = 1;
        FW = 1;
    case {'None','LandmarkSkinningFischer2018'}
        [PD, PH, PW, FL, FW] = deal(1);
    otherwise
        error('Invalid scaling law!')
end

if any(isnan([PD, PH, PW, FL, FW]))
    error('At least one of the scaling parameters is nan! Choose another cadaver to use this scaling law!')
end


% Pelvis
scaleTFM(1,1,1) = PD;
scaleTFM(2,2,1) = PH;
scaleTFM(3,3,1) = PW;

% Femur
scaleTFM(2,2,2) = FL;
scaleTFM(3,3,2) = FW;

% Scaling of patella, tibia, talus and foot by femoral length
scaleTFM(2,2,3:6) = data.S.Scale(2).FemoralLength / data.T.Scale(2).FemoralLength;

%% Scale
data.S.LE = transformTLEM2(data.T.LE, scaleTFM);

%% Femoral skinning
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
boneCS_TFM(:,:,1) = createPelvisCS_TFM_Wu2002_TLEM2(data.S.LE);
% Femur. Should be always the right side 'R' before scaling.
boneCS_TFM(:,:,2) = createFemurCS_TFM_Wu2002_TLEM2(data.S.LE, 'R');

data.S.LE = transformTLEM2(data.S.LE, boneCS_TFM);

end