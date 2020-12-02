function TFM = createFemurCS_TFM_Wu2002_TLEM2(LE, side, varargin)
% Wrapper function for createFemurCS_TFM_*.m and the LE struct

p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'definition','Wu2002',@(x) any(validatestring(x,{'Wu2002','Bergmann2016'})));
addParameter(p,'verbose',1, logParValidFunc);
parse(p,varargin{:});
definition = p.Results.definition;
verbose = p.Results.verbose;

switch definition
    case 'Wu2002'
        warningMessage = [...
            'Femoral bone landmarks are missing for the selected cadaver!' newline ...
            'Returning eye(4) for the transformation into the femoral bone coordinate system!'];
        if isfield(LE, 'Landmarks')
            MEC = LE(2).Landmarks.MedialEpicondyle.Pos;
            LEC = LE(2).Landmarks.LateralEpicondyle.Pos;
            HJC = LE(2).Joints.Hip.Pos;
            if all(~isnan([MEC, LEC, HJC]))
                TFM = createFemurCS_TFM_Wu2002(MEC, LEC, HJC, side);
            else
                TFM = eye(4);
                if verbose
                    warning(warningMessage)
                end
            end
        else
            TFM = eye(4);
            if verbose
                warning(warningMessage)
            end
        end
    case 'Bergmann2016'
        try
            MPC = LE(2).Mesh.vertices(LE(2).Landmarks.MedialPosteriorCondyle.Node,:);
            LPC = LE(2).Mesh.vertices(LE(2).Landmarks.LateralPosteriorCondyle.Node,:);
            P1 = LE(2).Landmarks.P1.Pos;
            P2 = LE(2).Mesh.vertices(LE(2).Landmarks.P2.Node,:);
            HJC = LE(2).Joints.Hip.Pos;
            TFM = createFemurCS_TFM_Bergmann2016(MPC, LPC, P1, P2, HJC, side);
        catch
            if verbose
                warning([...
            'Landmarks of the Bergmann2016 femoral bone coordinate system ' ...
            'are missing for the selected cadaver! Returning nan(4)!'])
            end
            TFM=nan(4);
        end
end

end