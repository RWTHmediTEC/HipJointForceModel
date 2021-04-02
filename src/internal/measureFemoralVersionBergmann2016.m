function femoralVersion = measureFemoralVersionBergmann2016(HJC, P1, P2, MPC, LPC)
%MEASUREFEMORALVERSIONBERGMANN2016 calculates the angle between neck axis 
% and posterior condylar line projected on the transverse plane.
% 
% The neck axis, posterior condylar line and transverse plane are defined 
% by the Bergmann2016 femoral bone coordinate system. 
%
% Reference:
% [Bergmann 2016] 2016 - Bergmann - Standardized Loads Acting in Hip 
%   Implants
% https://doi.org/10.1371/journal.pone.0155612
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

% The normal of the transverse plan is the straight femur axis defined by 
% the points P1 and P2 [Bergmann2016].
transversePlane = createPlane(P2, P1 - P2);
% Posterior condyle line projected onto the transverse plane
projPostCondyles = projPointOnPlane([MPC; LPC], transversePlane);
projPostCondylarLine = normalizeLine3d(createLine3d(projPostCondyles(1,:), projPostCondyles(2,:)));
% Neck line projected onto the transverse plane
projNeckPoints = projPointOnPlane([HJC; P1], transversePlane);
projNeckLine = normalizeLine3d(createLine3d(projNeckPoints(1,:), projNeckPoints(2,:)));

% Test if lines are parallel
if isParallel3d(projPostCondylarLine(4:6), projNeckLine(4:6),1e-12)
    femoralVersion = 0;
    return
end

% Convert lines into the plane coordinate system
TFM = createBasisTransform3d('global', transversePlane);
projPostCondylarLine = transformLine3d(projPostCondylarLine, TFM);
projNeckLine = transformLine3d(projNeckLine, TFM);
% Get intersection of the lines
[D, P1, ~] = distanceLines3d(projPostCondylarLine, projNeckLine);
assert(ismembertol(0,D,'Datascale',10))
% Get angle to rotate the neck line into the posterior condyle line
[femoralVersion, theta, psi] = rotation3dToEulerAngles(...
    createRotationVectorPoint3d(projNeckLine(4:6), projPostCondylarLine(4:6),P1));
assert(ismembertol(0,theta,'Datascale',10))
assert(ismembertol(0,psi,'Datascale',10))

end