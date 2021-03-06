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
function jointAngles = Position(data)

% Inputs

% Calculate the joint angles
jointAngles = {[0 0 data.S.PelvicTilt], [0 0 0], 0, 0, 0, 0};

end

%% Active muscles
function [activeMuscles, enable] = Muscles(~)
% User is allowed to edit the default values
enable = 'off';

% Default fascicles of the model
activeMuscles = {...
    'GluteusMedius';
    'GluteusMinimus';
    };

end

%% Calculation of the hip joint force
function data = Calculation(data)

% Inputs
g                 = data.g;
LE                = data.S.LE;
activeMuscles     = data.activeMuscles;
BodyWeight        = data.S.BodyWeight;
HipJointWidth     = data.S.Scale(1).HipJointWidth;
HipJointCenter    = data.S.LE(1).Joints.Hip.Pos;
Verbose           = data.Verbose;

if ~isfield(data.S.LE(2), 'Mesh')
    Verbose = 0;
end
if Verbose
    GreaterTrochanter = data.S.LE(2).Mesh.vertices(data.S.LE(2).Landmarks.GreaterTrochanter.Node,:);
    AcetabularRoof    = data.S.LE(1).Mesh.vertices(data.S.LE(1).Landmarks.AcetabularRoof_R.Node,:);
    MostCranial       = data.S.LE(1).Mesh.vertices(data.S.LE(1).Landmarks.SuperiorIliacCrest_R.Node,:);
    MostMedial        = data.S.LE(1).Mesh.vertices(data.S.LE(1).Landmarks.MedialIlium_R.Node,:);
    MostLateral       = data.S.LE(1).Mesh.vertices(data.S.LE(1).Landmarks.IliacTubercle_R.Node,:);
end

%% Define Parameters

d6 = HipJointWidth/2; % Half the distance between the two hip joint centers
d5 = 1.28 * d6; % Lever arm of G5 around the hip joint center
G5 = 5/6 * BodyWeight; % Partial body weight weighing on the hip joint
Z = [0, HipJointCenter(2:3)]; % Coordinates of the hip joint center in frontal plane
if Verbose
    T = [0, GreaterTrochanter(2:3)]; % Coordinates of the greater trochanter in frontal plane
    bD = MostLateral(3) - MostMedial(3); % Width of the iliac bone along the Z-axis
    hD = MostCranial(2) - AcetabularRoof(2); % Height of the iliac bone along the Y-axis
    A = [0, AcetabularRoof(2) + 2/3 * hD, MostLateral(3) - 2/5 * bD]; % Coordinates of the muscle origin in frontal plane
    h = norm(cross(A-T, Z-T)) / norm(A-T); %#ok<NASGU> % Lever arm of the muscle force around the hip joint center
end

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

A_cadaver = [0,...
          sum(origin(:,2)) / length(activeMuscles),...
          sum(origin(:,3)) / length(activeMuscles)];
T_cadaver = [0,...
          sum(insertion(:,2)) / length(activeMuscles),...
          sum(insertion(:,3)) / length(activeMuscles)];
h_cadaver = norm(cross(A_cadaver-T_cadaver, Z-T_cadaver)) / norm(A_cadaver-T_cadaver);

if Verbose
    disp(['Difference between the origin of the pelvic muscle attachment point A [Debrunner1975] ' ...
        'and A calculated using the selected cadaver: ' num2str(A-A_cadaver)])
    disp(['Difference between the origin of the femoral muscle attachment point T [Debrunner1975] ' ...
        'and T calculated using the selected cadaver: ' num2str(T-T_cadaver)])
end

M_TLEM_direction = (T_cadaver - A_cadaver)/norm(T_cadaver - A_cadaver);
syms M_TLEM_magnitude % Magnitude of the muscle force M
M = M_TLEM_direction * M_TLEM_magnitude;
G5_Force = [0, G5 * -g, 0];

momentG5 = cross([0 0 -d5], G5_Force); % Moment of bodyweight force around hip rotation center
eq1 = momentG5 + [ h_cadaver * M_TLEM_magnitude, 0, 0];  % Moment equilibrium around hip joint center

syms RxSym RySym RzSym
% Calculate the hip joint force
check   = G5_Force(1) + M(1) + RxSym; % Force equilibrium in the direction of X
eq2     = G5_Force(2) + M(2) + RySym; % Force equilibrium in the direction of Y
eq3     = G5_Force(3) + M(3) + RzSym; % Force equilibrium in the direction of Z

Results = solve(check, eq1, eq2, eq3);

MuscleForce = double(Results.M_TLEM_magnitude);
if MuscleForce < 0 && data.Verbose
    warning(['Unphysiological / negative value of the muscle force M (' num2str(MuscleForce,1) ')!'])
end
rX = double(Results.RxSym);
rY = double(Results.RySym);
rZ = double(Results.RzSym);

data = convertGlobalHJF2LocalHJF([rX rY rZ], data);

end