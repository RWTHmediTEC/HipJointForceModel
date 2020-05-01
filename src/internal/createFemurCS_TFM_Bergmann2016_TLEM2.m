function TFM = createFemurCS_TFM_Bergmann2016_TLEM2(LE, side)

try
    % Wrapper function for createFemurCS_TFM_Bergmann2016 and the LE struct
    MPC = LE(2).Mesh.vertices(LE(2).Landmarks.MedialPosteriorCondyle.Node,:);
    LPC = LE(2).Mesh.vertices(LE(2).Landmarks.LateralPosteriorCondyle.Node,:);
    P1 = LE(2).Landmarks.P1.Pos;
    P2 = LE(2).Mesh.vertices(LE(2).Landmarks.P2.Node,:);
    HJC = LE(2).Joints.Hip.Pos;
    TFM = createFemurCS_TFM_Bergmann2016(MPC, LPC, P1, P2, HJC, side);
catch
    warning('Missing data! Returning nan(4)!')
    TFM=nan(4);
end

end
