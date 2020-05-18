function TFM = createFemurCS_TFM_Wu2002_TLEM2(LE, side)
% Wrapper function for createFemurCS_TFM_Wu2002 and the LE struct

warningMessage = [...
    'Femoral bone landmarks are missing for the selected cadaver!' newline ... 
    'Returning eye(4) for the transformation into the pelvic bone coordinate system!'];

if isfield(LE, 'Landmarks')
    MEC = LE(2).Landmarks.MedialEpicondyle.Pos;
    LEC = LE(2).Landmarks.LateralEpicondyle.Pos;
    HJC = LE(2).Joints.Hip.Pos;
    if all(~isnan([MEC, LEC, HJC]))
        TFM = createFemurCS_TFM_Wu2002(MEC, LEC, HJC, side);
    else
        TFM = eye(4);
        warning(warningMessage)
    end
else
    TFM = eye(4);
    warning(warningMessage)
end

end
