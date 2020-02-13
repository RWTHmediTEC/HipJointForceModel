function funcHandles = Eggert2018
% Based on the model of [Iglic 1990] but using the TLEM2 cadaver data 
% instead of Dostal's cadaver data. Grouping of the muscles was removed to
% avoid unphysiological / negative muscle forces.

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
x0 = data.S.Scale(2).FemoralLength;
phi = 0.5;

% Calculate the joint angles
b = 0.48 * l;
ny = asind(b/x0);
jointAngles = {[phi 0 data.S.PelvicTilt], [ny 0 0], 0, 0, -ny, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(gui)
% User is allowed to edit the default values
enable = 'on';

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
    'Piriformis1'};

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
pelvicTilt    = data.S.PelvicTilt;
hipJointWidth = data.S.Scale(1).HipJointWidth;
femoralLength = data.S.Scale(2).FemoralLength;
activeMuscles = data.activeMuscles;
side          = data.S.Side;
view          = data.View;

%% Define Parameters
G = -9.81;                         % weight force

% Subject-specific values
l = hipJointWidth/2;               % Half the distance between the two hip rotation centers
x0 = femoralLength;                % Femoral length
WB = BW * G;                       % total body weight
% Generic values
WL = 0.161 * WB;                   % weight of the supporting limb
W = [0, WB - WL, 0];               % 'WB - WL'
b = 0.48 * l;                      % medio-lateral moment arm of the WL [Iglic 1990, S.37, Equ.7]
c = 1.01 * l;                      % medio-lateral moment arm of the ground reaction force WB  [Iglic 1990, S.37, Equ.7]
a = (WB * c - WL * b) / (WB - WL); % medio-lateral moment arm of 'WB - WL' [Iglic 1990, S.37, Equ.6]
d = 0;                             % !QUESTIONABLE! antero-posterior moment arm of 'WB - WL' [Iglic 1990, S.37]
phi = 0.5;                         % Pelvic bend [�]: rotation around the posterior-anterior axis
ny = asind(b/x0);                  % Femoral adduction: rotation around the posterior-anterior axis [Iglic 1990, S.37, Equ.8]

% Implement matrices for muscle origin points r, muscle insertion points r'
% and relative physiological cross-sectional areas A

% Number of active muscles
Noam = size(activeMuscles,1);

% Get muscle origin points and muscle insertion points
via(Noam,1) = false;
[r, r_] = deal(zeros(Noam,3));
for m = 1:Noam
    for n = 1:length(LE)
        if ~isempty(LE(n).Muscle)
            muscles = fieldnames(LE(n).Muscle);
            if any(strcmp(muscles,activeMuscles(m,1)))
                for t = 1:length(LE(n).Muscle.(activeMuscles{m,1}).Type)
                    if strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Origin')
                        r(m,:) = LE(n).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    elseif strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Via')
                        if strcmp(data.MusclePath, 'ViaPoint')
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

A = zeros(Noam,1);
% Get physiological cross-sectional areas
for m = 1:Noam
    % Physiological cross-sectional areas of each fascicle
    A_Idx = strcmp(activeMuscles{m}(1:end-1), muscleList(:,1));
    A(m) = muscleList{A_Idx,5} / muscleList{A_Idx,4};
end

% Unit vectors s in the direction of the muscles
for m = 1:Noam
    if via(m) == true
        % Find most distal via point of pelvis
        [~, idxPelvis] = min(LE(1).Muscle.(activeMuscles{m,1}).Pos(:,2));
        r(m,:)  = LE(1).Muscle.(activeMuscles{m,1}).Pos(idxPelvis,:);
        % Find most proximal via point of femur
        [~, idxFemur] = max(LE(2).Muscle.(activeMuscles{m,1}).Pos(:,2));
        r_(m,:) = LE(2).Muscle.(activeMuscles{m,1}).Pos(idxFemur,:);
        % !!! Has to be adapted if extreme joint positions are considered
    end
end
s = normalizeVector3d(r_ - r);

% [Iglic 1990, S.37, Equ.2]
f = cell2sym(repmat({'f'}, Noam,1));
assume(f >= 0);
F = f .* A .* s;

% Moment of F around hip rotation center
momentF = cross(r, F);

if side == 'L'
    momentW = cross([d 0 a], W);  % Moment of bodyweight force around hip rotation center
else
    momentW = cross([d 0 -a], W); % Moment of bodyweight force around hip rotation center
end

% Calculate hip joint reaction force R
syms RxSym RySym RzSym

eq1 =  sum(F(:,1)) + RxSym + W(1); % [Iglic 1990, S.37, Equ.4]
eq2 =  sum(F(:,2)) + RySym + W(2); % [Iglic 1990, S.37, Equ.4]
eq3 =  sum(F(:,3)) + RzSym + W(3); % [Iglic 1990, S.37, Equ.4]

eq4 = sum(momentF(:,1)) + momentW(1); % [Iglic 1990, S.37, Equ.5]

R = solve(eq1, eq2, eq3, eq4);

rX = double(R.RxSym);
rY = double(R.RySym);
rZ = double(R.RzSym);
f = double(R.f);
if f < 0
    warning(['Unphysiolocial / negative value of f (' num2str(f,1) ')!'])
end

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end