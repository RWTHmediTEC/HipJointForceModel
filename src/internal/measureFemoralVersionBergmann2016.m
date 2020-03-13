function femoralVersion = measureFemoralVersionBergmann2016(HJC, P1, P2, MPC, LPC)
% Angle between neck axis and condylar line projected on transverse plane

transversePlane = createPlane(P2, P1 - P2);
projPostCond = projPointOnPlane([MPC; LPC], transversePlane);
% Posterior condyle line projected onto the transverse plane
projPostCondLine = createLine3d(projPostCond(1,:), projPostCond(2,:));
projPostCondLine(4:6)=normalizeVector3d(projPostCondLine(4:6));

projNeckPoints = projPointOnPlane([HJC; P1], transversePlane);
% Neck line projected onto the transverse plane
projNeckLine = createLine3d(projNeckPoints(1,:), projNeckPoints(2,:));
projNeckLine(4:6)=normalizeVector3d(projNeckLine(4:6));

% Test if lines are parallel
if isParallel3d(projPostCondLine(4:6), projNeckLine(4:6),1e-12)
    femoralVersion=0;
    return
end

% Convert lines into the plane coordinate system
TFM = createBasisTransform3d('global', transversePlane);
projPostCondLine=transformLine3d(projPostCondLine,TFM);
projNeckLine=transformLine3d(projNeckLine,TFM);
% Get intersection of the lines
[D, P1, ~] = distanceLines3d(projPostCondLine, projNeckLine);
assert(ismembertol(0,D,'Datascale',10))
% Get angle to rotate the neck line into the posterior condyle line
[femoralVersion, theta, psi] = rotation3dToEulerAngles(...
    createRotationVectorPoint3d(projNeckLine(4:6),projPostCondLine(4:6),P1));
assert(ismembertol(0,theta,'Datascale',10))
assert(ismembertol(0,psi,'Datascale',10))

end