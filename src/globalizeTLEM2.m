function LE = globalizeTLEM2(LE, Stance, Side, PelvicTilt, HRC, FL)
% Transformation of TLEM 2.0 data into a global coordinate system considering
% selected stance:
% Two-legged stance:    phi = hip rotation around x-axis
% One-legged stance:    phi = hip rotation around x-axis 
%                       ny  = femoral rotation around x-axis
% further stances can be added

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
    
    pTRANS = createTranslation3d( 1*LE(pBoneIdx).Joints.(pJoint).Pos);
    TRANS  = createTranslation3d(-1*LE(   b    ).Joints.(pJoint).Pos);
    % Implement translation matrix for transformation from local to global
    transTFM(:,:,b) = transTFM(:,:,pBoneIdx) * pTRANS * TRANS;
end

LE = transformTLEM2(LE, transTFM);

%% Add Rotation
switch Stance
    case 1 % Two-legged Stance
        jointAngles = {[-PelvicTilt 0 0], [0 0 0], 0, 0, 0, 0}; % in degree
        
    case 2 % One-legged Stance
        b = 0.48 * HRC/2;
        ny = asind(b/FL);
        jointAngles = {[(-PelvicTilt+0.5) 0 0], [ny 0 0], 0, 0, -ny, 0}; % in degree
        
    case 3 % Sitting stance just as an example for further additions
        jointAngles = {[-PelvicTilt 0 0], [0 0 75], 75, 75, 0, 0}; % in degree
end

LE = positionTLEM2(LE, jointAngles);

%% Side Selection
if Side == 'L'
mirrorTFM      = eye(4); 
mirrorTFM(3,3) = -1;
mirrorTFM      = repmat(mirrorTFM, 1, 1, length(LE));
LE = transformTLEM2(LE, mirrorTFM);
end

end