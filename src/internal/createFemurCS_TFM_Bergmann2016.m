function TFM = createFemurCS_TFM_Bergmann2016(MPC, LPC, P1, P2, HJC, side)

% 2016 - Bergmann et al. - Standardized Loads Acting in Hip Implants:
%   "The origin of this coordinate system is located at the centre of the 
%   femoral head. The +z axis points upward and is defined by the line 
%   connecting the two points where the curved femoral mid-line intersected 
%   with the neck axis (P1) and where it passes the intercondylar notch 
%   (P2). The +x axis points laterally and is oriented parallel to the 
%   proximal contour of the condyles. The +y axis points in the anterior 
%   direction."

StraightFemurAxis = createLine3d(P2, P1);

% Connection of the most posterior points of the condyles
PosteriorCondyleAxis = createLine3d(MPC, LPC);

Z = normalizeVector3d(StraightFemurAxis(4:6));
Y = normalizeVector3d(crossProduct3d(StraightFemurAxis(4:6), PosteriorCondyleAxis(4:6)));
X = normalizeVector3d(crossProduct3d(Y, Z));

TFM = [[X;Y;Z],[0 0 0]'; [0 0 0 1]]*createTranslation3d(-HJC);
switch side
    case 'L'
        TFM=createRotationOz(pi)*TFM;
    case 'R'
    otherwise
        error('Invalid side identifier!')
end

end
