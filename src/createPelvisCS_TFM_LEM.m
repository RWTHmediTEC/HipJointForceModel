function TFM = createPelvisCS_TFM_LEM(LE, varargin)
% Wrapper function for createPelvisCS_TFM_*.m and the LE struct

p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'definition','Wu2002',@(x) any(validatestring(x,{'Wu2002','SISP','APP'})));
addParameter(p,'verbose',1, logParValidFunc);
parse(p,varargin{:});
definition = p.Results.definition;
verbose = p.Results.verbose;

TFM = nan;
if isfield(LE, 'Landmarks')
    switch definition
        case {'Wu2002', 'SISP'}
            ASIS_R = LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos;
            ASIS_L = LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos;
            PSIS_R = LE(1).Landmarks.RightPosteriorSuperiorIliacSpine.Pos;
            PSIS_L = LE(1).Landmarks.LeftPosteriorSuperiorIliacSpine.Pos;
            HJC = LE(1).Joints.Hip.Pos;
            if all(~isnan([ASIS_R, ASIS_L, PSIS_R, PSIS_L, HJC]))
                TFM = createPelvisCS_TFM_Wu2002(ASIS_R, ASIS_L, PSIS_R, PSIS_L, HJC);
            end
        case 'APP'
            ASIS_R = LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos;
            ASIS_L = LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos;
            PS = LE(1).Landmarks.PubicSymphysis.Pos;
            HJC = LE(1).Joints.Hip.Pos;
            if all(~isnan([ASIS_R, ASIS_L, PS, HJC]))
                TFM = createPelvisCS_TFM_APP(ASIS_R, ASIS_L, PS, HJC);
            end
    end
end

if isnan(TFM)
    TFM = eye(4);
    if verbose
        warning(['Pelvic bone landmarks are missing for the selected cadaver!' newline ...
            'Returning eye(4) for the transformation into the pelvic bone coordinate system!'])
    end
end

end