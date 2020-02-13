function funcHandles = IglicTLEM2
% The model of [Iglic 1990] using the TLEM2 cadaver data instead of
% Dostal's cadaver data. Some adaptions were necessary to solve the model
% that questions the validity of the [Iglic 1990] model. See below for 
% further information.

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
function jointAngles = Position(data)

% Inputs
l = data.S.Scale(1).HipJointWidth/2;
x0 = data.S.Scale(2).FemoralLength; % Femoral length
phi = 0.5; % Pelvic bend [�]: rotation around the posterior-anterior axis

% Calculate the joint angles
b = 0.48 * l;
ny = asind(b/x0); % Femoral adduction: rotation around the posterior-anterior axis [Iglic 1990, S.37, Equ.8]
jointAngles = {[phi 0 0], [ny 0 0], 0, 0, -ny, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(gui)
% User is allowed to edit the default values
enable = 'off';

% The division of the muscles in [Iglic 1990, S.37] is not compatible with
% the TLEM2. GluteusMediusMid1 is not available in TLEM2.
% The classification of the muscles into the groups fa, ft, fp was altered
% compared to [Iglic 1990, S.37, Table 1]. However, the results for fa, ft 
% and , fp are unphysiological / negative. See the warning in the command 
% window.
activeMuscles = {...
    'GluteusMediusAnterior1',   'ft';
    'GluteusMediusAnterior2',   'ft';
    'GluteusMediusAnterior3',   'fa';
    'GluteusMediusAnterior4',   'fa';
    'GluteusMediusAnterior5',   'fa';
    'GluteusMediusAnterior6',   'fa';
    'GluteusMinimusAnterior1',  'fa';
    'GluteusMinimusAnterior2',  'fa';
    'TensorFasciaeLatae1',      'fa';
    'TensorFasciaeLatae2',      'fa';
    'RectusFemoris1',           'fa';
    'RectusFemoris2',           'fa';
    
    'GluteusMinimusMid1',       'ft';
    'GluteusMinimusMid2',       'ft';
    
    'GluteusMediusPosterior1',  'fp';
    'GluteusMediusPosterior2',  'ft';
    'GluteusMediusPosterior3',  'fp';
    'GluteusMediusPosterior4',  'ft';
    'GluteusMediusPosterior5',  'fp';
    'GluteusMediusPosterior6',  'fp';
    'GluteusMinimusPosterior1', 'fp';
    'GluteusMinimusPosterior2', 'fp';
    'Piriformis1',              'fp'};

% Disable muscle path models which are not supported
set(gui.Home.Settings.RadioButton_ViaPoint, 'enable', 'on');
set(gui.Home.Settings.RadioButton_ObstacleSet, 'enable', 'off');
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
LE            = data.S.LE;
muscleList    = data.MuscleList;
BW            = data.S.BodyWeight;
hipJointWidth = data.S.Scale(1).HipJointWidth;
activeMuscles = data.activeMuscles;
musclePath    = data.MusclePath;
side          = data.S.Side;
view          = data.View;

%% Define Parameters
G = -9.81;                         % weight force

% Subject-specific values
l = hipJointWidth/2;               % Half the distance between the two hip rotation centers
WB = BW * G;                       % total body weight
% Generic values
WL = 0.161 * WB;                   % weight of the supporting limb
W = [0, WB - WL, 0];               % 'WB - WL'
b = 0.48 * l;                      % medio-lateral moment arm of the WL [Iglic 1990, S.37, Equ.7]
c = 1.01 * l;                      % medio-lateral moment arm of the ground reaction force WB  [Iglic 1990, S.37, Equ.7]
a = (WB * c - WL * b) / (WB - WL); % medio-lateral moment arm of 'WB - WL' [Iglic 1990, S.37, Equ.6]
d = 0;                             % !QUESTIONABLE! antero-posterior moment arm of 'WB - WL' [Iglic 1990, S.37]

% Create matrices for muscle origin points r, muscle insertion points r'
% and relative physiological cross-sectional areas A

% Number of active muscles
NoAM = size(activeMuscles,1);

% Get muscle origin points and muscle insertion points
via(NoAM,1) = false;
[r, r_] = deal(zeros(NoAM,3));
for m = 1:NoAM
    for n = 1:length(LE)
        if ~isempty(LE(n).Muscle)
            muscles = fieldnames(LE(n).Muscle);
            if any(strcmp(muscles,activeMuscles(m,1)))
                for t = 1:length(LE(n).Muscle.(activeMuscles{m,1}).Type)
                    if strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Origin')
                        r(m,:) = LE(n).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    elseif strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Via')
                        if strcmp(musclePath, 'ViaPoint')
                            via(m) = true;
                        else
                            continue;
                        end
                    elseif strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Insertion')
                        r_(m,:) = LE(n).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    end
                end
            end
        end
    end
end

A = zeros(NoAM,1);
% Get physiological cross-sectional areas
for m = 1:NoAM
    % Physiological cross-sectional areas of each fascicle
    A_Idx = strcmp(activeMuscles{m}(1:end-1), muscleList(:,1));
    A(m) = muscleList{A_Idx,5} / muscleList{A_Idx,4};
end

% Unit vectors s in the direction of the muscles
for m = 1:NoAM
    if via(m) == true
        % Find most distal via point of pelvis
        [~, idxPelvis] = min(LE(1).Muscle.(activeMuscles{m,1}).Pos(:,2));
        r(m,:) = LE(1).Muscle.(activeMuscles{m,1}).Pos(idxPelvis,:);
        % Find most proximal via point of femur
        [~, idxFemur] = max(LE(2).Muscle.(activeMuscles{m,1}).Pos(:,2));
        r_(m,:) = LE(2).Muscle.(activeMuscles{m,1}).Pos(idxFemur,:);
        % !!! Has to be adapted if extreme joint positions are considered
    end
end
% Unit vectors s in the direction of the muscles [Iglic 1990, S.37, Equ.3]
s = normalizeVector3d(r_ - r);

% [Iglic 1990, S.37, Equ.2]
f = cell2sym(activeMuscles(:,2));
% The assumption 'f >= 0' should be included, but then the solver will not find a solution
assume(f >= 0)
assume(f,'clear')
F = f .* A .* s;

% Moment of F around hip rotation center
momentF = cross(r, F);

if side == 'L'
    momentW = cross([d 0  a], W); % Moment of 'WB - WL' around hip rotation center
else
    momentW = cross([d 0 -a], W); % Moment of 'WB - WL' around hip rotation center
end

% Calculate hip joint reaction force R
syms RxSym RySym RzSym

eq1 =  sum(F(:,1)) + RxSym + W(1); % [Iglic 1990, S.37, Equ.4]
eq2 =  sum(F(:,2)) + RySym + W(2); % [Iglic 1990, S.37, Equ.4]
eq3 =  sum(F(:,3)) + RzSym + W(3); % [Iglic 1990, S.37, Equ.4]

eq4 = sum(momentF(:,1)) + momentW(1); % [Iglic 1990, S.37, Equ.5]
eq5 = sum(momentF(:,2)) + momentW(2); % [Iglic 1990, S.37, Equ.5]
eq6 = sum(momentF(:,3)) + momentW(3); % [Iglic 1990, S.37, Equ.5]

R = solve(eq1, eq2, eq3, eq4, eq5, eq6);

rX = double(R.RxSym);
rY = double(R.RySym);
rZ = double(R.RzSym);
fa = double(R.fa);
ft = double(R.ft);
fp = double(R.fp);
if fa < 0 || ft < 0 || fp < 0
    warning(['Unphysiolocial / negative value of fa (' num2str(fa,1) '), ' ...
        'ft (' num2str(ft,1) ') or fp (' num2str(fp,1) ')!'])
end

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end