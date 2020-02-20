function funcHandles = Debrunner1975

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
    'GluteusMinimusMid1';
    'GluteusMinimusMid2';
    'GluteusMinimusPosterior1';
    'GluteusMinimusPosterior2';};

% Disable muscle path models which are not supported
set(gui.Home.Settings.RadioButton_ViaPoint, 'enable', 'off');
set(gui.Home.Settings.RadioButton_Wrapping, 'enable', 'off');
end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
LE                = data.S.LE;
activeMuscles     = data.activeMuscles;
BodyWeight        = data.S.BodyWeight;
PelvicTilt        = data.S.PelvicTilt;
HipJointWidth     = data.S.Scale(1).HipJointWidth;
Side              = data.S.Side;
View              = data.View;
GreaterTrochanter = data.S.LE(2).Mesh.vertices(data.S.LE(2).Landmarks.GreaterTrochanter.Node,:);
HipJointCenter    = data.S.LE(1).Joints.Hip.Pos;
AcetabularRoof    = data.S.LE(1).Mesh.vertices(data.S.LE(1).Landmarks.AcetabularRoof  .Node,:);
MostCranial       = data.S.LE(1).Mesh.vertices(data.S.LE(1).Landmarks.MostCranialIlium.Node,:);
MostMedial        = data.S.LE(1).Mesh.vertices(data.S.LE(1).Landmarks.MostMedialIlium .Node,:);
MostLateral       = data.S.LE(1).Mesh.vertices(data.S.LE(1).Landmarks.MostLateralIlium.Node,:);

%% Define Parameters

d6 = HipJointWidth/2; % Half the distance between the two hip joint centers
d5 = 1.28 * d6; % Lever arm of G5 around the hip joint center
G5 = 5/6 * BodyWeight; % Partial body weight weighing on the hip joint
Z = [0, HipJointCenter(2:3)]; % Coordinates of the hip joint center in frontal plane
T = [0, GreaterTrochanter(2:3)]; % Coordinates of the greater trochanter in frontal plane
bD = MostLateral(3) - MostMedial(3); % Width of the iliac bone along the Z-axis
hD = MostCranial(2) - AcetabularRoof(2); % Height of the iliac bone along the Y-axis
A = [0, AcetabularRoof(2) + 2/3 * hD, MostLateral(3) - 2/5 * bD]; % Coordinates of the muscle origin in frontal plane
% h = norm(cross(A-T, Z-T)) / norm(A-T); % Lever arm of the muscle force around the hip joint center

% Number of active muscles
Noam = size(activeMuscles,1);

% Get muscle origin points and muscle insertion points
[origin, insertion] = deal(zeros(Noam,3));
for m = 1:length(activeMuscles)
    for n = 1:length(LE)
        if ~isempty(LE(n).Muscle)
            muscles = fieldnames(LE(n).Muscle);
            if any(strcmp(muscles,activeMuscles(m,1)))
                for t = 1:length(LE(n).Muscle.(activeMuscles{m,1}).Type)
                    if strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Origin')
                        origin(m,:) = LE(n).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    elseif strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Via')
                        continue;
                    elseif strcmp(LE(n).Muscle.(activeMuscles{m,1}).Type(t), 'Insertion')
                        insertion(m,:) = LE(n).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    end
                end
            end
        end
    end
end

A_TLEM = [0,...
          sum(origin(:,2)) / length(activeMuscles),...
          sum(origin(:,3)) / length(activeMuscles)];
T_TLEM = [0,...
          sum(insertion(:,2)) / length(activeMuscles),...
          sum(insertion(:,3)) / length(activeMuscles)];
h_TLEM = norm(cross(A_TLEM-T_TLEM, Z-T_TLEM)) / norm(A_TLEM-T_TLEM);

disp(['Difference between A and A_TLEM: ' num2str(A-A_TLEM)])
disp(['Difference between T and T_TLEM: ' num2str(T-T_TLEM)])

M_TLEM_direction = (T_TLEM - A_TLEM)/norm(T_TLEM - A_TLEM);
syms M_TLEM_magnitude % Magnitude of the muscle force M
M = M_TLEM_direction * M_TLEM_magnitude;
G5_Force = [0, -9.81 * G5, 0];

if Side == 'L'
    momentG5 = cross([0 0 d5], G5_Force);  % Moment of bodyweight force around hip rotation center
    eq1 = momentG5 + [-h_TLEM * M_TLEM_magnitude, 0, 0]; % Moment equilibrium around hip joint center
else
    momentG5 = cross([0 0 -d5], G5_Force); % Moment of bodyweight force around hip rotation center
    eq1 = momentG5 + [ h_TLEM * M_TLEM_magnitude, 0, 0];  % Moment equilibrium around hip joint center
end

syms RxSym RySym RzSym
% Calculate the hip joint force
check = G5_Force(1) + M(1) + RxSym; % Force equilibrium in the direction of X
eq2 = G5_Force(2) + M(2) + RySym; % Force equilibrium in the direction of Y
eq3 = G5_Force(3) + M(3) + RzSym; % Force equilibrium in the direction of Z

Results = solve(check, eq1, eq2, eq3);

MuscleForce = double(Results.M_TLEM_magnitude);
rX = double(Results.RxSym);
rY = double(Results.RySym);
rZ = double(Results.RzSym);

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end