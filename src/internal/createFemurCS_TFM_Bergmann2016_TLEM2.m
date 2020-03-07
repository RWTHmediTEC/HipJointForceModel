function TFM = createFemurCS_TFM_Bergmann2016_TLEM2(LE, side)

try
    % Wrapper function for createFemurCS_TFM_Bergmann2016 and the LE struct
    MPC = LE(2).Mesh.vertices(LE(2).Landmarks.MedialPosteriorCondyle.Node,:);
    LPC = LE(2).Mesh.vertices(LE(2).Landmarks.LateralPosteriorCondyle.Node,:);
    ICN = LE(2).Mesh.vertices(LE(2).Landmarks.IntercondylarNotch.Node,:);
    NeckAxis = LE(2).Mesh.vertices(LE(2).Landmarks.NeckAxis.Node,:);
    NeckAxis = createLine3d(NeckAxis(1,:),NeckAxis(2,:));
    ShaftAxis = LE(2).Mesh.vertices(LE(2).Landmarks.ShaftAxis.Node,:);
    ShaftAxis = createLine3d(ShaftAxis(1,:),ShaftAxis(2,:));
    HJC=LE(2).Joints.Hip.Pos;
    TFM = createFemurCS_TFM_Bergmann2016(MPC, LPC, ICN, NeckAxis, ShaftAxis, HJC, side);
catch
    warning('Missing data! Returning eye(4)!')
    TFM = eye(4);
end

end
