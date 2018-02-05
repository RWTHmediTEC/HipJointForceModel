function LE = positionTLEM2(LE, jointAngles)
% Rotation of the bones by jointAngles 

NoB = length(LE);

% Convert from degree to radian
jointAngles = cellfun(@deg2rad, jointAngles, 'uni', false);

computed = false(NoB,1);
for b = 1:NoB
    fk_helper(b);
end
%-------------------------------------------------------------------------%
    function fk_helper(b)
        if ~computed(b)
            pBone = LE(b).Parent;
            % Get joints of the bone
            jts = fieldnames(LE(b).Joints);
            if isempty(pBone) || pBone < 2
                % The root joint is a spherical joint
                LE(b).TFM = ...
                    createRotationOx(jointAngles{b}(1)) * ...
                    createRotationOy(jointAngles{b}(2)) * ...
                    createRotationOz(jointAngles{b}(3));
            else
                % Otherwise compute parents first
                fk_helper(pBone);
                % Get parent joint (the joint connecting the bone with its parent bone)
                pJoint = jts{structfun(@(x) x.Parent==1, LE(b).Joints)};
                % Joint center
                jCenter = LE(b).Joints.(pJoint).Pos;
                % Joint axis
                jAxis = LE(b).Joints.(pJoint).Axis;
                % The other joints are revolute/hinge joints
                ROT = createRotation3dLineAngle([jCenter, jAxis], jointAngles{b});
                LE(b).TFM = LE(pBone).TFM*ROT;
            end
            computed(b) = true;
        end
    end
%-------------------------------------------------------------------------%
% Transform bones
LE = transformTLEM2(LE, reshape([LE.TFM], [4,4,NoB]));

end