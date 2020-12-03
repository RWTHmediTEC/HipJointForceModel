function data = globalizeTLEM2(data)
% Transformation of TLEM2 data into a global coordinate system
LE = data.S.LE;

%% Transformations from local to global coordinate system
NoB = length(LE);
transTFM = repmat(eye(4), 1, 1, NoB);
for b = 2:NoB
    % Parent bone index
    pBoneIdx = LE(b).Parent;
    % Get joints of the bone
    joints = fieldnames(LE(b).Joints);
    % Get parent joint (the joint connecting the bone with its parent bone)
    pJoint = joints{structfun(@(x) x.Parent==1, LE(b).Joints)};
    
    pTRANS = createTranslation3d( 1 * LE(pBoneIdx).Joints.(pJoint).Pos);
    TRANS  = createTranslation3d(-1 * LE(   b    ).Joints.(pJoint).Pos);
    % Implement translation matrix for transformation from local to global
    transTFM(:,:,b) = transTFM(:,:,pBoneIdx) * pTRANS * TRANS;
end

LE = transformTLEM2(LE, transTFM);

%% Position TLEM2 according to the model
calculateTLEM2 = str2func(data.Model);
modelHandles = calculateTLEM2();
data.jointAngles = modelHandles.Position(data);

LE = positionTLEM2(LE, data.jointAngles);

data.S.LE = LE;

%% Create muscle paths
data = musclePathsLEM(data);

end