function [rMag, rMagP, rPhi, rTheta, rDir] = calculateTLEM2(LE, BW, HRC, Side)
% Calculate the hip joint reaction force according to Iglic 1990

%% Active Muscles
% Muscle elements required for Iglic including unknown average muscle tension f

activeMusclesIglic = {'GluteusMediusAnterior1',   'fa';
                      'GluteusMediusAnterior2',   'fa';
                      'GluteusMediusAnterior3',   'fa';
                      'GluteusMediusAnterior4',   'fa';
                      'GluteusMediusAnterior5',   'fa';
                      'GluteusMediusAnterior6',   'fa';
                      'GluteusMediusPosterior1',  'fa';
                      'GluteusMediusPosterior2',  'fa';
                      'GluteusMediusPosterior3',  'fa';
                      'GluteusMediusPosterior4',  'fa';
                      'GluteusMediusPosterior5',  'fa';
                      'GluteusMediusPosterior6',  'fa';
                      'GluteusMinimusAnterior1',  'fa';
                      'GluteusMinimusAnterior2',  'fa';
                      'TensorFasciaeLatae1',      'fa';
                      'TensorFasciaeLatae2',      'fa';
                      'RectusFemoris1',           'fa';
                      'RectusFemoris2',           'fa';
                      'GluteusMinimusMid1',       'fa';
                      'GluteusMinimusMid2',       'fa';
                      'GluteusMediusPosterior1',  'fa';
                      'GluteusMediusPosterior2',  'fa';
                      'GluteusMediusPosterior3',  'fa';
                      'GluteusMediusPosterior4',  'fa';
                      'GluteusMediusPosterior5',  'fa';
                      'GluteusMediusPosterior6',  'fa';
                      'GluteusMinimusPosterior1', 'fa';
                      'GluteusMinimusPosterior2', 'fa';};
                  
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
%                       'GluteusMaximusSuperior1',    'fa';
%                       'GluteusMaximusSuperior2',    'fa';
%                       'GluteusMaximusSuperior3',    'fa';
%                       'GluteusMaximusSuperior4',    'fa';
%                       'GluteusMaximusSuperior5',    'fa';
%                       'GluteusMaximusSuperior6',    'fa'
                                 
%% Define Parameters
G = -9.81;                              % Weight force
wb = BW * G;                            % Resultant force of total bodyweight 
wl = 0.161 * wb;                        % Resultant force of the supporting limb
w = [0, wb - wl, 0];                    % Resultant bodyweight force
HRChalf = HRC/2;                        % Half the distance between the two hip rotation centers
ba = 0.48 * HRChalf;                    % Lever arm of the force wl
ca = 1.01 * HRChalf;                    % Lever arm of the ground reaction force wb's attachment point
a = (wb * ca - wl * ba) / (wb - wl);    % Lever arm of the force w's attachment point

% Implement matrices for Muscle Origin Points (mop) and Muscle Insertion Points (mip)
% which are equal to r and r' in Iglic 1990
% and Physiological Cross-Sectional Areas (PCSA)
[mop, mip, PCSA] = deal([]);

% Get PCSAs
for m = 1:length(activeMusclesIglic)
    fascicle = activeMusclesIglic{m};
    fascicle = activeMusclesIglic{m}(:,(1:(end-1))); 
    fitEnt = count(activeMusclesIglic(:,1), fascicle);
    n = length(find(fitEnt));
    % PCSA of the single muscle cord
    cPCSA = LE(1).Muscle.(activeMusclesIglic{m}).PCSA / n;
    PCSA = [PCSA, cPCSA];
end

% Get mops and mips
for m = 1:length(activeMusclesIglic)
    for b = 1:length(LE)
        if ~isempty(LE(b).Muscle)
            muscles = fieldnames(LE(b).Muscle);
            if any(strcmp(muscles,activeMusclesIglic(m,1)))
                if strcmp(LE(b).Muscle.(activeMusclesIglic{m}).Type, 'Origin')
                    mop = [mop; LE(b).Muscle.(activeMusclesIglic{m}).Pos];                        
                else
                    mip = [mip; LE(b).Muscle.(activeMusclesIglic{m}).Pos];
                end
            end
        end
    end
end

for m = 1:length(mop)
    s(m,:) = (mip(m,:) - mop(m,:)) / norm(mip(m,:) - mop(m,:));                 % Unit vector s_n in the direction of the n-th muscle
    muscleForce(m,:) = PCSA(m) * cell2sym(activeMusclesIglic(m,2)) .* s(m,:);   % Iglic 1990 equation 2
    momentF(m,:) = cross(mop(m,:),muscleForce(m,:));                            % Moment of muscleForce around HRC
end

if Side == 'L'
    momentW = cross([0 0 a],w); % Moment of bodyweight force around HRC
else
    momentW = cross([0 0 -a],w); % Moment of bodyweight force around HRC
end

syms rX rY rZ % Hip joint forces

eq1 =  sum(muscleForce(:,1)) + rX + w(1); % Iglic 1990 equation 4 for X-component
eq2 =  sum(muscleForce(:,2)) + rY + w(2); % Iglic 1990 equation 4 for Y-component
eq3 =  sum(muscleForce(:,3)) + rZ + w(3); % Iglic 1990 equation 4 for Z-component

eq4 = sum(momentF(:,1)) + momentW(1); % Iglic 1990 equation 5 for X-component
% eq5 = sum(momentF(:,2)) + momentW(2); % Iglic 1990 equation 5 for Y-component
% eq6 = sum(momentF(:,3)) + momentW(3); % Iglic 1990 equation 5 for Z-component

hipJointForce = solve(eq1, eq2, eq3, eq4); % , eq5, eq6

rX = double(hipJointForce.rX);
rY = double(hipJointForce.rY);
rZ = double(hipJointForce.rZ);
fa = double(hipJointForce.fa);
% ft = double(hipJointForce.ft)
% fp = double(hipJointForce.fp)

rMag = norm([rX rY rZ]);        % Magnitude of hip joint reaction force in [N]
rMagP = rMag / abs(wb) * 100;   % Magnitude of hip joint reaction force in [BW%]
rPhi = -atand(rZ / rY);         % Angle in frontal plane
rTheta = -atand(rX / rY);       % Angle in sagital plane
rDir=normalizeVector3d([rX rY rZ]);

end