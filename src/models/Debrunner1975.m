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
g              = data.g;
LE             = data.S.LE;
activeMuscles  = data.activeMuscles;
KG             = data.S.BodyWeight;
HJW            = data.S.Scale(1).HipJointWidth;
HipJointCenter = data.S.LE(1).Joints.Hip.Pos;
Verbose        = data.Verbose;

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

d6 = HJW/2; % Half distance between the hip joint centers [Debrunner 1975, Abb.5]
d5 = 1.28 * d6; % Moment arm of G5 about the hip joint center [Debrunner 1975, Eq.4]
G5 = g * 5/6 * KG; % Magnitude of the partial body weight [Debrunner 1975, Eq.3]
Z = [0, HipJointCenter(2:3)]; % Hip joint center in frontal plane
if Verbose
    T_org = [0, GreaterTrochanter(2:3)]; % Coordinates of the greater trochanter in frontal plane
    bD = MostLateral(3) - MostMedial(3); % Width of the iliac bone along the Z-axis
    hD = MostCranial(2) - AcetabularRoof(2); % Height of the iliac bone along the Y-axis
    A_org = [0, AcetabularRoof(2) + 2/3 * hD, MostLateral(3) - 2/5 * bD]; % Coordinates of the muscle origin in frontal plane
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

% In contrast to Debrunner, the mean of the origin points as well as the 
% insertion points of the abductor muscles are taken as A and T.
A = [0 mean(origin(:,2:3))];
T = [0 mean(insertion(:,2:3))];

% The moment arm of the abductors h is defined as the projection of the hip
% joint center Z on the vector connecting A and T. [Debrunner 1975, Abb.10]
h = distancePoints3d(Z, projPointOnLine3d(Z, createLine3d(A, T)));

if Verbose
    disp(['Difference between the origin of the pelvic muscle attachment point A [Debrunner1975] ' ...
        'and A calculated using the selected cadaver: ' num2str(A_org-A)])
    disp(['Difference between the origin of the femoral muscle attachment point T [Debrunner1975] ' ...
        'and T calculated using the selected cadaver: ' num2str(T_org-T)])
end

% Unit vector of the muscle force of the abductors
M_Dir = - normalizeVector3d(T - A);
% Symbolic magnitude of the muscle force of the abductors
syms M_Mag
% Muscle force of the abductors
M = M_Dir * M_Mag;

% Moment equilibrium about the hip joint center [Debrunner 1975, Eq.1]
eqMoment = [h * M_Mag, 0, 0] - crossProduct3d([0 0 -d5], [0, G5, 0]) ;

% Symbolic resulting hip joint force
syms Rx Ry Rz
% Force equilibrium  [Debrunner 1975, Eq.2]
eqForce = [0, G5, 0] + M + [Rx Ry Rz];

% Solve the system of equations
Results = solve([eqMoment(:); eqForce(:)]);

% Magnitude of the muscle force of the abductors
M_mag = double(Results.M_Mag);
if M_mag < 0 && data.Verbose
    warning(['Unphysiological / negative value of the muscle force M (' num2str(M_mag,1) ')!'])
end

% Resulting hip joint force pointing to the pelvis
R = - [double(Results.Rx) double(Results.Ry) double(Results.Rz)];

data = convertGlobalHJF2LocalHJF(R, data);

end