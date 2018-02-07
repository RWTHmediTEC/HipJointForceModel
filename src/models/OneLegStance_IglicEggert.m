function funcHandles = OneLegStance_IglicEggert

funcHandles.Position = @Position;
funcHandles.Muscles = @Muscles;
funcHandles.Calculation = @Calculation;

end


%% Calculate the joint angles for positioning of the TLEM2
function jointAngles = Position(data)

% Inputs
HRC=data.HRC;
FL=data.FL;
PelvicTilt=data.PelvicTilt;

% Calculate the joint angles
b = 0.48 * HRC/2;
ny = asind(b/FL);
jointAngles = {[0.5 0 -PelvicTilt], [ny 0 0], 0, 0, -ny, 0};
end

function activeMuscles = Muscles()
%% Active Muscles
% Muscle elements required for Iglic including unknown average muscle tension f
activeMuscles =  {'GluteusMediusAnterior1';
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
                  'GluteusMinimusPosterior2';};
                  
%                       'GluteusMinimusAnterior1',  'fa';
%                       'GluteusMinimusAnterior2',  'fa';
%                       'TensorFasciaeLatae1',      'fa';
%                       'TensorFasciaeLatae2',      'fa';
%                       'RectusFemoris1',           'fa';
%                       'RectusFemoris2',           'fa';
%                       'GluteusMinimusMid1',       'fa';
%                       'GluteusMinimusMid2',       'fa';
%                       'GluteusMediusPosterior1',  'fa';
%                       'GluteusMediusPosterior2',  'fa';
%                       'GluteusMediusPosterior3',  'fa';
%                       'GluteusMediusPosterior4',  'fa';
%                       'GluteusMediusPosterior5',  'fa';
%                       'GluteusMediusPosterior6',  'fa';
%                       'GluteusMinimusPosterior1', 'fa';
%                       'GluteusMinimusPosterior2', 'fa';
%                       'Piriformis1',              'fa';
%                       'GluteusMaximusSuperior1',  'fa';
%                       'GluteusMaximusSuperior2',  'fa';
%                       'GluteusMaximusSuperior3',  'fa';
%                       'GluteusMaximusSuperior4',  'fa';
%                       'GluteusMaximusSuperior5',  'fa';
%                       'GluteusMaximusSuperior6',  'fa';
end

%% Calculation of the HJF
function [rMag, rMagP, rPhi, rTheta, rDir] = Calculation(data)

% Inputs
LE=data.LE;
muscleList=data.MuscleList;
BW=data.BW;
HRC=data.HRC;
activeMuscles=data.activeMuscles;
Side=data.Side;
                                 
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
MOP=zeros(NoaM,3);
MIP=zeros(NoaM,3);
for m = 1:NoaM
    for b = 1:length(LE)
        if ~isempty(LE(b).Muscle)
            muscles = fieldnames(LE(b).Muscle);
            if any(strcmp(muscles,activeMuscles(m,1)))
                if strcmp(LE(b).Muscle.(activeMuscles{m,1}).Type, 'Origin')
                    MOP(m,:) = LE(b).Muscle.(activeMuscles{m,1}).Pos;                        
                else
                    MIP(m,:) = LE(b).Muscle.(activeMuscles{m,1}).Pos;
                end
            end
        end
    end
end

PCSA=zeros(NoaM,1);
% Get PCSAs
for m = 1:NoaM
    % PCSA of each fascicle
    PCSA_Idx = strcmp(activeMuscles{m}(1:end-1), muscleList(:,1));
    PCSA(m)=muscleList{PCSA_Idx,5}/muscleList{PCSA_Idx,4};
end

% Unit vectors s in the direction of the muscles
s=normalizeVector3d(MIP - MOP);
% Iglic 1990 equation 2
muscleForce = PCSA .* cell2sym(repmat({'fa'}, NoaM,1)) .* s; 
% Moment of muscleForce around HRC
momentF = cross(MOP,muscleForce);
% for m = 1:length(MOP)
    % Unit vector s_m in the direction of the m-th muscle
%     s(m,:) = (MIP(m,:) - MOP(m,:)) / norm(MIP(m,:) - MOP(m,:));
    % Iglic 1990 equation 2
%     muscleForce(m,:) = PCSA(m) * cell2sym(activeMuscles(m,2)) .* s(m,:);
    % Moment of muscleForce around HRC
%     momentF(m,:) = cross(MOP(m,:),muscleForce(m,:));
% end

if Side == 'L'
    momentW = cross([0 0 a],w); % Moment of bodyweight force around HRC
else
    momentW = cross([0 0 -a],w); % Moment of bodyweight force around HRC
end

syms rXsym rYsym rZsym % Hip joint forces

eq1 =  sum(muscleForce(:,1)) + rXsym + w(1); % Iglic 1990 equation 4 for X-component
eq2 =  sum(muscleForce(:,2)) + rYsym + w(2); % Iglic 1990 equation 4 for Y-component
eq3 =  sum(muscleForce(:,3)) + rZsym + w(3); % Iglic 1990 equation 4 for Z-component

eq4 = sum(momentF(:,1)) + momentW(1); % Iglic 1990 equation 5 for X-component
% eq5 = sum(momentF(:,2)) + momentW(2); % Iglic 1990 equation 5 for Y-component
% eq6 = sum(momentF(:,3)) + momentW(3); % Iglic 1990 equation 5 for Z-component

hipJointForce = solve(eq1, eq2, eq3, eq4); % , eq5, eq6

rX = double(hipJointForce.rXsym);
rY = double(hipJointForce.rYsym);
rZ = double(hipJointForce.rZsym);
% fa = double(hipJointForce.fa);
% ft = double(hipJointForce.ft)
% fp = double(hipJointForce.fp)

rMag = norm([rX rY rZ]);        % Magnitude of hip joint reaction force in [N]
rMagP = rMag / abs(wb) * 100;   % Magnitude of hip joint reaction force in [BW%]
rPhi = -atand(rZ / rY);         % Angle in frontal plane
rTheta = -atand(rX / rY);       % Angle in sagital plane
rDir=normalizeVector3d([rX rY rZ]);

end