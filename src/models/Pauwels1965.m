function funcHandles = Pauwels1965

funcHandles.Posture     = @Posture;
funcHandles.Position    = @Position;
funcHandles.Muscles     = @Muscles;
funcHandles.Calculation = @Calculation;

end

%% Postures for validation
function [postures, default] = Posture()

default = 1;
postures = {'OneLeggedStance' 'OLS';
            'LevelWalking' 'LW'};

end

%% Calculate the joint angles for positioning of the TLEM2
function jointAngles = Position(~)

% Inputs

% Calculate the joint angles
jointAngles = {[0 0 0], [0 0 0], 0, 0, 0, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(gui)
% User is allowed to edit the default values
enable = 'off';

% Default fascicles of the model
activeMuscles = {...
    'GluteusMediusAnterior1';
    'GluteusMediusAnterior2';
    'GluteusMediusAnterior3';
    'GluteusMediusAnterior4';
    'GluteusMediusAnterior5';
    'GluteusMediusAnterior6';
    'GluteusMediusPosterior1';
    'GluteusMediusPosterior2';
    'GluteusMediusPosterior3';
    'GluteusMediusPosterior4';
    'GluteusMediusPosterior5';
    'GluteusMediusPosterior6';
    'GluteusMinimusAnterior1';
    'GluteusMinimusAnterior2';
    'TensorFasciaeLatae1';
    'TensorFasciaeLatae2';
    'RectusFemoris1';
    'RectusFemoris2';
    'GluteusMinimusMid1';
    'GluteusMinimusMid2';
    'GluteusMinimusPosterior1';
    'GluteusMinimusPosterior2';
    'Piriformis1'
    'Sartorius1'};

% Disable muscle path models which are not supported
set(gui.Home.Settings.RadioButton_ViaPoint, 'enable', 'off');
set(gui.Home.Settings.RadioButton_ObstacleSet, 'enable', 'off');
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
Side              = data.S.Side;
View              = data.View;

%% Define parameters

S = 58.7; % Total body weight
S5 = 47.76; % % Partial body weight weighing on the hip joint
G = -9.81; % Weight force
xS5 = 109.9; % Lever arm of body weight force around the hip joint center
BO = 40; % Lever arm of the muscle force M
alphaM = 21; % Angle between the muscle force M and the Y-axis

syms M % Magnitude of the muscle force
% Calculation of the muscle force
eq1 = S5 * G * xS5 + M * BO; % Moment equilibrium around hip joint center

syms RxSym RySym RzSym
% Calculation of the hip joint force
eq2 = RxSym;                             % Force equilibrium in the direction of X
eq3 = RySym + S5 * G - M * cosd(alphaM); % Force equilibrium in the direction of Y
if Side == 'L'
eq4 = RzSym - M * sind(alphaM);          % Force equilibrium in the direction of Z
else
eq4 = RzSym + M * sind(alphaM);          % Force equilibrium in the direction of Z
end

Results = solve(eq1, eq2, eq3, eq4);

rX = double(Results.RxSym);
rY = double(Results.RySym);
rZ = double(Results.RzSym);

rMag = norm([rX rY rZ]);              % Magnitude of R
rMagP = rMag / abs(S*G) * 100;        % Magnitude of R in percentage body weight
rDir = normalizeVector3d([rX rY rZ]); % Direction of R

if Side == 'L'
    rZ = -1 * rZ;
end

% Rotation matrices for local pelvic COS
TFMx = createRotationOx(0);
TFMy = createRotationOy(0);
TFMz = createRotationOz(0);

if strcmp(View, 'Femur') == 1
    rDir = -1 * rDir;
    
    % Rotation matrices for local femur COS
    TFMx = createRotationOx();
    TFMy = createRotationOy();
    TFMz = createRotationOz();
end

[rX, rY, rZ] = transformPoint3d(rX, rY, rZ, TFMx*TFMy*TFMz);

rPhi   = atand(rZ / rY); % Angle in frontal plane
rTheta = atand(rX / rY); % Angle in sagittal plane
rAlpha = atand(rX / rZ); % Angle in horizontal plane

% Save results in data
data.rX     = rX;
data.rY     = rY;
data.rZ     = rZ;
data.rDir   = rDir;
data.rMag   = rMag;
data.rMagP  = rMagP;
data.rPhi   = rPhi;
data.rTheta = rTheta;
data.rAlpha = rAlpha;

end