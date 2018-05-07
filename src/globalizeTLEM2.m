function data = globalizeTLEM2(data)
% Transformation of TLEM2 data into a global coordinate system
LE = data.LE;

%% Transformations from Local to Global Coordinate System
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
jointAngles = modelHandles.Position(data);

LE = positionTLEM2(LE, jointAngles);

%% Mirror TLEM2 for the left side
switch data.Side
    case 'L'
        mirrorTFM      = eye(4);
        mirrorTFM(3,3) = -1;
        mirrorTFM      = repmat(mirrorTFM, 1, 1, length(LE));
        LE = transformTLEM2(LE, mirrorTFM);
end

data.LE = LE;

end