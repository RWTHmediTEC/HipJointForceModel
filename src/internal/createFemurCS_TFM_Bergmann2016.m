function TFM = createFemurCS_TFM_Bergmann2016(MPC, LPC, P1, P2, HJC, side)

StraightFemurAxis=createLine3d(P2, P1);

%% inital transformation
% Connection of the most posterior points of the condyles
PosteriorCondyleAxis = createLine3d(MPC, LPC);

Z = normalizeVector3d(StraightFemurAxis(4:6));
Y = normalizeVector3d(crossProduct3d(StraightFemurAxis(4:6), PosteriorCondyleAxis(4:6)));
X = normalizeVector3d(crossProduct3d(Y, Z));
TFM = inv([[inv([X; Y; Z]), HJC']; [0 0 0 1]]);

switch side
    case 'L'
        TFM=createRotationOz(pi)*TFM; %#ok<MINV>
    case 'R'
    otherwise
        error('Invalid side identifier!')
end

end
