function [LE, HRC, PW, PH, PD, FL, FW, varargout] = scaleTLEM2(LE, varargin)
% Implementation of the Scaling Matrices with patient specific data

% Scaling Parameters:
% HRC = Distance between the two hip rotation centers
% PW  = Pelvic width measured as the distance between the two ASISs along
%       Z-Axis
% PH  = Pelvic height measured as the distance between HRC and ASIS along
%       Y-Axis
% PD  = Pelvic depth measured as the distance between ASIS and PSIS along
%       X-Axis
% FL  = Femoral length measured as the distance between HRC and the 
%       midpoint between medial and lateral epicondyle along y-Axis
% FW  = Femoral width measured as the absolute distance between greater trochanter 
%       and HRC

%% TLEM2 Parameters (t*)
tHRC = abs(min(LE(1).Mesh.vertices(:,3)) * 2);  % No consideration of width of symphysis pubica
tPW  = LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(3) -...
        LE(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos(3);
tPH  = LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(2);
tPD  = LE(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(1) -...
        LE(1).Landmarks.RightPosteriorSuperiorIliacSpine.Pos(1);
tFL  = LE(2).Joints.Hip.Pos(2);  
tFW  = norm(LE(2).Landmarks.GreaterTrochanter.Pos - LE(2).Joints.Hip.Pos);

%% Scaling Parameters
if nargin == 1
    [PW, PH, PD, FL, FW, HRC] = deal(1);
    varargout{1} = tHRC;
    varargout{2} = tPW;
    varargout{3} = tPH;
    varargout{4} = tPD;
    varargout{5} = tFL;
    varargout{6} = tFW;
else
    HRC = varargin{1} / tHRC;
    PW  = varargin{2} / tPW;
    PH  = varargin{3} / tPH;
    PD  = varargin{4} / tPD;
    FL  = varargin{5} / tFL;
    FW  = varargin{6} / tFW;
end

%% Implementation of the Scaling Matrices
scaleTFM = eye(4);
scaleTFM(1,1,1) = PD; scaleTFM(2,2,1) = PH; scaleTFM(3,3,1) = PW;
scaleTFM(1,1,2) = 1;  scaleTFM(2,2,2) = FL; scaleTFM(3,3,2) = 1; % No scaling for femoral width and depth
scaleTFM(:,:,3:6) = repmat(scaleTFM(:,:,2), 1, 1, 4); % Scaling for tibia, patella, talus and foot equal to femur

%% Scale
LE = transformTLEM2(LE, scaleTFM);

end