function TFM = createPelvisCS_TFM_Wu2002_TLEM2(LE)
% Wrapper function for createPelvisCS_TFM_Wu2002 and the LE struct

ASIS_R = LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos;
ASIS_L =  LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos;
PSIS_R = LE(1).Landmarks.RightPosteriorSuperiorIliacSpine.Pos;
PSIS_L =  LE(1).Landmarks.LeftPosteriorSuperiorIliacSpine.Pos;
HJC = LE(1).Joints.Hip.Pos;

if all(~isnan([ASIS_R, ASIS_L, PSIS_R, PSIS_L, HJC]))
    TFM = createPelvisCS_TFM_Wu2002(ASIS_R, ASIS_L, PSIS_R, PSIS_L, HJC);
else
    TFM = eye(4);
    warning('Landmarks missing! Returning eye(4)!')
end

end