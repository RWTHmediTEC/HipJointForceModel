function funcHandles = OneLeggedStance_Iglic1990

funcHandles.Position = @Position;
funcHandles.Muscles = @Muscles;
funcHandles.Calculation = @Calculation;

end

%% Calculate the joint angles for positioning of the TLEM2
function jointAngles = Position(data)

% Inputs
HRC = data.HRC;
FL  = data.FL;
PB  = data.PB;

% Calculate the joint angles
b = 0.48 * HRC/2;
ny = asind(b/FL);
jointAngles = {[0.5 0 PB], [ny 0 0], 0, 0, -ny, 0};
end

%% Active Muscles
function [activeMuscles, enable] = Muscles()
% Is the user allowed to edit the default values
enable = 'off';

% Default fascicles of the model
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
end

%% Calculation of the HJF
function [rMag, rMagP, rPhi, rPhiFemur, rTheta, rAlpha, rDir, rX, rY, rZ] = Calculation(data)

% Inputs
LE            = data.LE;
muscleList    = data.MuscleList;
BW            = data.BW;
HRC           = data.HRC;
activeMuscles = data.activeMuscles;
Side          = data.Side;
                                 
%% Define Parameters
G = -9.81;                              % Weight force
wb = BW * G;                            % Resultant force of total bodyweight 
wl = 0.161 * wb;                        % Resultant force of the supporting limb
w = [0, wb - wl, 0];                    % Resultant bodyweight force
HRChalf = HRC/2;                        % Half the distance between the two hip rotation centers
ba = 0.48 * HRChalf;                    % Lever arm of the force wl
ca = 1.01 * HRChalf;                    % Lever arm of the ground reaction force wb's attachment point
a = (wb * ca - wl * ba) / (wb - wl);    % Lever arm of the force w's attachment point

% Implement matrices for Muscle Origin Points (MOP) and Muscle Insertion 
% Points (MIP) which are equal to r and r' in Iglic 1990
% and Physiological Cross-Sectional Areas (PCSA)

% Number of active Muscles
NoaM = size(activeMuscles,1);

% Get MOPs and MIPs
[MOP, MIP] = deal(zeros(NoaM,3));
for m = 1:NoaM
    for b = 1:length(LE)
        if ~isempty(LE(b).Muscle)
            muscles = fieldnames(LE(b).Muscle);
            if any(strcmp(muscles,activeMuscles(m,1)))
                for t = 1:length(LE(b).Muscle.(activeMuscles{m,1}).Type)
                    if strcmp(LE(b).Muscle.(activeMuscles{m,1}).Type(t), 'Origin')
                        MOP(m,:) = LE(b).Muscle.(activeMuscles{m,1}).Pos(t,:);                        
                    elseif strcmp(LE(b).Muscle.(activeMuscles{m,1}).Type(t), 'Via')
                        continue
                    elseif strcmp(LE(b).Muscle.(activeMuscles{m,1}).Type(t), 'Insertion')
                        MIP(m,:) = LE(b).Muscle.(activeMuscles{m,1}).Pos(t,:);
                    end
                end
            end
        end
    end
end

PCSA = zeros(NoaM,1);
% Get PCSAs
for m = 1:NoaM
    % PCSA of each fascicle
    PCSA_Idx = strcmp(activeMuscles{m}(1:end-1), muscleList(:,1));
    PCSA(m) = muscleList{PCSA_Idx,5} / muscleList{PCSA_Idx,4};
end

% Unit vectors s in the direction of the muscles
s = normalizeVector3d(MIP - MOP);
% Iglic 1990 equation 2
for m = 1:NoaM % loop not needed for latest Matlab version
muscleForce(m,:) = PCSA(m) * cell2sym(activeMuscles(m,2)) * s(m,:);
end
% Moment of muscleForce around HRC
momentF = cross(MOP, muscleForce);

if Side == 'L'
    momentW = cross([0 0 a], w);  % Moment of bodyweight force around HRC
else
    momentW = cross([0 0 -a], w); % Moment of bodyweight force around HRC
end

syms rXsym rYsym rZsym % Hip joint forces

eq1 =  sum(muscleForce(:,1)) + rXsym + w(1); % Iglic 1990 equation 4 for X-component
eq2 =  sum(muscleForce(:,2)) + rYsym + w(2); % Iglic 1990 equation 4 for Y-component
eq3 =  sum(muscleForce(:,3)) + rZsym + w(3); % Iglic 1990 equation 4 for Z-component

eq4 = sum(momentF(:,1)) + momentW(1); % Iglic 1990 equation 5 for X-component
eq5 = sum(momentF(:,2)) + momentW(2); % Iglic 1990 equation 5 for Y-component
eq6 = sum(momentF(:,3)) + momentW(3); % Iglic 1990 equation 5 for Z-component

hipJointForce = solve(eq1, eq2, eq3, eq4, eq5, eq6);

rX = double(hipJointForce.rXsym);
rY = double(hipJointForce.rYsym);
rZ = double(hipJointForce.rZsym);
fa = double(hipJointForce.fa);
ft = double(hipJointForce.ft);
fp = double(hipJointForce.fp);

rMag = norm([rX rY rZ]);                                    % Magnitude of hip joint reaction force in [N]
rMagP = rMag / abs(wb) * 100;                               % Magnitude of hip joint reaction force in [BW%]
ny = asind(ba/data.FL);
rPhi = sign(atand(rZ / rY)) * 0.5 + (atand(rZ / rY));       % Angle in frontal plane
rPhiFemur = sign(atand(rZ / rY)) * ny + (atand(rZ / rY));   % Angle in frontal plane
rTheta = atand(rX / rY) + data.PB;                          % Angle in sagittal plane
rAlpha = atand(rX / rZ);                                    % Angle in horizontal plane
rDir = normalizeVector3d([rX rY rZ]);

end