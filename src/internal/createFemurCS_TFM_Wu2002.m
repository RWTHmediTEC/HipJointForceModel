function TFM = createFemurCS_TFM_Wu2002(MEC, LEC, HJC,side)

% 2002 - Wu et al. - ISB recommendation on definitions of joint coordinate 
% systems of various joints for the reporting of human joint motion Part 1
% Femoral coordinate system—xyz:
% o: The origin coincident with the right (or left) hip center of rotation, 
%    coincident with that of the pelvic coordinate system (o) in the 
%    neutral configuration.
% y: The line joining the midpoint between the medial and lateral femoral 
%    epicondyles (FEs) and the origin, and pointing cranially.
% z: The line perpendicular to the y-axis, lying in the plane defined by 
%    the origin and the two FEs, pointing to the right.
% x: The line perpendicular to both y- and z-axis, pointing anteriorly 
% (Cappozzo et al., 1995)

% Midpoint between the epicondyles
MEC_LEC_midPoint=midPoint3d(MEC, LEC);
% Mechanical axis is the connection of EC midpoint and hip joint center
MechanicalAxis = createLine3d(MEC_LEC_midPoint, HJC);
% Connection of the epicondyles
EpicondyleAxis = createLine3d(MEC, LEC);

Y = normalizeVector3d(MechanicalAxis(4:6));
X = normalizeVector3d(crossProduct3d(MechanicalAxis(4:6), EpicondyleAxis(4:6)));
Z = normalizeVector3d(crossProduct3d(X, Y));

TFM = [[X;Y;Z],[0 0 0]'; [0 0 0 1]]*createTranslation3d(-HJC);
switch side
    case 'L'
        TFM=createRotationOy(pi)*TFM;
    case 'R'
    otherwise
        error('Invalid side identifier!')
end

end
