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
% Values from: [Pauwels 1965] 1965 - Pauwels - Gesammelte Abhandlungen zur  
% funktionellenAnatomie des Bewegungsapparates - Der Schenkelhalsbruch

[S, S5, abc] = derivationFromBrauneAndFischer189X; 
G = -9.81; % Weight force
derivationFromFick1950;
BO = 40; % Lever arm of the muscle force M [Pauwels 1965, S.111]
alphaM = 21; % Angle between the muscle force M and the vertical [Pauwels 1965, S.111] 

syms M % Magnitude of the muscle force
% Calculation of the muscle force
eq1 = S5 * G * abc(1) + M * BO; % Moment equilibrium around hip joint center

syms RxSym RySym RzSym
% Calculation of the hip joint force
eq2 = RxSym;                             % Force equilibrium in the direction of X
eq3 = RySym + S5 * G - M * cosd(alphaM); % Force equilibrium in the direction of Y
switch Side
    case 'L'
        eq4 = RzSym - M * sind(alphaM); % Force equilibrium in the direction of Z
    case 'R'
        eq4 = RzSym + M * sind(alphaM); % Force equilibrium in the direction of Z
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

% Rotation matrices for local pelvic CS
TFMx = createRotationOx(0);
TFMy = createRotationOy(0);
TFMz = createRotationOz(0);

if strcmp(View, 'Femur') == 1
    rDir = -1 * rDir;
    
    % Rotation matrices for local femur CS
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

function [S, S5, s5_l] = derivationFromBrauneAndFischer189X()
[S, ~, G1, G2, g1_16, g2_L_16, hjc_R_16] = BrauneAndFischer189X();

% Derivation 
S5 = S*(G1+G2);
assert(isequal(round(S5,2), 47.76)); % [kg] Partial body weight weighing on the hip joint [Pauwels 1965, S.112]
s5 = (g1_16*G1+g2_L_16*G2)/(G1+G2); % [Pauwels 1965, S.101]
assert(isequal(round(s5,2), [129.43 -0.71 102.09])); % [cm] Position of S5 [Pauwels 1965, S.102]

% Lever arms of S5 projected into the anatomical planes
a = hjc_R_16(2)-s5(2); % Frontal plane [Pauwels 1965, S.103]
b = hjc_R_16(1)-s5(1); % Sagittal plane [Pauwels 1965, S.103]
c = sqrt(a^2+b^2); % Transverse plane [Pauwels 1965, S.103]

s5_l = [a -b c]; % -b: [Pauwels 1965, S.105, Footnote 32]
assert(isequal(round(s5_l,1), round([+10.99 -0.97 11.04],1))); % [cm] Lever arms of S5 [Pauwels 1965, S.105]
s5_l = s5_l*10; % Conversion to [mm]
end

function [PT, SC] = derivationFromFick1950
visu=0;
if visu
    [~, HM, axH] = Fick1850(visu);
else
    [~, HM] = Fick1850();
end

FrontalPlane = [0 0 0 0 1 0 0 0 1];

RectusFemoris1 = createLine3d(HM(1).Muscle.RectusFemoris1.Pos, HM(2).Muscle.RectusFemoris1.Pos);
RectusFemoris2 = createLine3d(HM(1).Muscle.RectusFemoris2.Pos, HM(2).Muscle.RectusFemoris2.Pos);
TensorFasciaeLatae1 = createLine3d(HM(1).Muscle.TensorFasciaeLatae1.Pos, HM(2).Muscle.TensorFasciaeLatae1.Pos);
TensorFasciaeLatae2 = createLine3d(HM(1).Muscle.TensorFasciaeLatae2.Pos, HM(2).Muscle.TensorFasciaeLatae2.Pos);
Sartorius1 = createLine3d(HM(1).Muscle.Sartorius1.Pos, HM(2).Muscle.Sartorius1.Pos);
Sartorius2 = createLine3d(HM(1).Muscle.Sartorius2.Pos, HM(2).Muscle.Sartorius2.Pos);

RectusFemoris_FP = bisector(RectusFemoris1([2,3,5,6]),RectusFemoris2([2,3,5,6]));

if visu
    drawLine3d(axH,[0 RectusFemoris_FP(1:2), 0 RectusFemoris_FP(3:4)]);
end

end

