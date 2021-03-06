function LE = positionLEM(LE, jointAngles)
%POSITIONLEM rotates the the bones by jointAngles
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

NoB = length(LE);

if any(cellfun(@any, cellfun(@isnan, jointAngles, 'uni', 0)))
    errMessage = ['At least one of the joint angles contains nan. '...
        'Choose another cadaver to use this HJF model!'];
    msgbox(errMessage,mfilename,'error')
    error(errMessage)
end

% Convert from degree to radian
jointAngles = cellfun(@deg2rad, jointAngles, 'uni', false);

TFM=nan(4,4,NoB);
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
            if isempty(pBone) || pBone < 2 % pBone non-existant (i.e. hip) or pBone is hip
                % The root joint is a spherical joint
                TFM(:,:,b) = ...
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
                TFM(:,:,b) = TFM(:,:,pBone)*ROT;
            end
            computed(b) = true;
        end
    end
%-------------------------------------------------------------------------%
% Transform bones
LE = transformLEM(LE, TFM);

for b = 1:NoB
    LE(b).positionTFM = TFM(:,:,b);
end

end