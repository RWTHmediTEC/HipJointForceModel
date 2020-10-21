function force = muscleRecruitment(a, w, r, s, PCSA, data)
% a = lever arm of the bodyweight force;
% w = bodyweight force;  
% r = origin of the muscle's line of action;
% s = direction of the muscle's line of action;
% PCSA = physiological cross sectional area of fascicles [mm²]

tStart = tic;
%% Inputs
side          = data.S.Side;
muscleList    = data.MuscleList;
musclePaths   = data.S.MusclePaths;
MRC           = data.MuscleRecruitmentCriteria;
z             = data.S.LE(1).Joints.Hip.Pos;

%% Parameters
DP = 3;                                             % Default value of power of polynomial criteria
SIGMA = 0.9;                                        % Muscle Tension [N/mm²] [Anybody]; .5 in [CusToM]
C1 = .5;                                            % Weighting factor in Energy criteria [~]
fMax = SIGMA*PCSA;                                  % Maximal fasicle strength [N]
n = 'Fmax';                                         % Weighting factor in Minmax and Polynomial criteria (fMax oder PCSA)
switch n
    case 'Fmax'
    N = fMax;
    case 'PCSA'
    N = PCSA;
end

NoAM = length(musclePaths);                         % Number of active muscles
F_0 = zeros(NoAM,1);                                % Initial value of optimization 
F_MIN = zeros(size(F_0));                           % Minimum fasicle strength [N]
aeq = zeros(3,NoAM);
opts = optimoptions(@fmincon,...
    'Algorithm','sqp',...
    'Display','off',...
    'GradObj','off',...
    'GradConstr','off',...
    'TolFun',1e-9,...
    'MaxFunctionEvaluations',1000000,...
    'TolX',1e-9,...
    'StepTolerance',1e-15,...
    'FunctionTolerance',1e-10,...
    'MaxIterations',5000);
[nbFas,fMaxM] = deal(zeros(NoAM,1));
muscleNames = '';

%% Calculation of Resultant Muscle Force
% Get Fmax of each muscle
for m = 1:NoAM
    tempIdx = strcmp(musclePaths(m).Name(1:end-1),muscleList(:,1));     % Find Index of active fascicle
    muscleNames{m} = cellstr(muscleList(tempIdx,1));    
    nbFas(m) = muscleList{tempIdx,4};                                  
    fMaxM(m) = muscleList{tempIdx,5}*SIGMA;                                              
end
[~,idx] = unique(fMaxM,'first');                    % Delete values of all fascicles ecxept one per muscle
nbFas = nbFas(sort(idx),:);                         % Number of fascicles of each muscle
muscleNames = string(muscleNames(:,sort(idx)));     % Names of active muscles
fMaxM = fMaxM(sort(idx),:);                         % Fmax of each muscle [N]

leverArm = leverOfMuscles(NoAM,r,s,z);              % Lever arms of muscles around hip joint center [mm]

switch side
    case 'R'
        momentW = cross([0 0 -a], w);               % Moment of bodyweight force around hip joint center [Nmm]
    case 'L'
        momentW = cross([0 0  a], w);               % Moment of bodyweight force around hip joint center [Nmm]      
end
aeq(1,:) = leverArm;                                % Lever arms of all active muscles around hip joint center
beq = -momentW';                                    % Negative moment of external forces around hip joint center

% Optimization of muscle forces
switch MRC    
    case 'MinMax'                                   % MinMax muscle recruitment criteria
        fascicleForce = muscleRecruitmentMinMax(F_0,F_MIN,fMax,aeq,beq,N,opts);
    case 'Polynom2'                                 % Polynomial muscle recruitment criteria with power = 2
        DP = 2;
        fascicleForce = muscleRecruitmentPoly(DP,F_0,F_MIN,fMax,aeq,beq,N,opts);
    case 'Polynom3'                                 % Polynomial muscle recruitment criteria with power = 3
        fascicleForce = muscleRecruitmentPoly(DP,F_0,F_MIN,fMax,aeq,beq,N,opts);
    case 'Polynom5'                                 % Polynomial muscle recruitment criteria with power = 5
        DP = 5;
        fascicleForce = muscleRecruitmentPoly(DP,F_0,F_MIN,fMax,aeq,beq,N,opts);
    case 'Energy'                                   % Energy muscle recruitment criteria
        if size(muscleList,2) >= 7
            % Get physiological cross-sectional masses
            fascicleMass = zeros(NoAM,1);
            for m = 1:NoAM
                % Mass of each fascicle
                PCSA_Idx = strcmp(musclePaths(m).Name(1:end-1), muscleList(:,1));
                fascicleMass(m) = muscleList{PCSA_Idx,7} / muscleList{PCSA_Idx,4};
            end
        else
            errMessage = ['No muscle mass available for the selected cadaver. '...
                'Choose another cadaver to use this muscle recruitment criterion!'];
            msgbox(errMessage,mfilename,'error')
            error(errMessage)
        end
        fascicleForce = muscleRecruitmentEnergy(C1,F_0,F_MIN,fMax,aeq,beq,PCSA,opts,fascicleMass);
end

force = s'*diag(fascicleForce);                     % Get force matrix by multiplying force diagonal matrix with matrix of unit force orientation vector

% Check if optimization was succesful
momF = leverArm*fascicleForce;
sm = sum(momF);
check = isequal(round(sm,4),round(-momentW(1),4));  % Check whether moments are equal
if check == 0
uiwait(msgbox({'Unphysiolocial!';'Imbalance of moments!';...
    [num2str(round(sm,4)),' = ',num2str(round(-momentW(1),4))]},'Warning','warn','modal'));
end

disp(['Muscle recruitment took ' num2str(toc(tStart),'%.1f') ' seconds.'])

%% Activation
% Get force of active muscles
muscleForce = zeros(length(fMaxM),1);
for i = 1:length(fMaxM)                             % Calculation of the sum of all fascicle forces of each muscle 
    if i == 1
        muscleForce(i) = sum(fascicleForce(1:nbFas(i)));
    else
        j = 1+sum(nbFas(1:(i-1)));
        k = sum(nbFas(1:i));      
        muscleForce(i) = sum(fascicleForce(j:k));
    end
end

fascicleActivation = fascicleForce./fMax;           % Activation of each fascicle
muscleActivation = muscleForce./fMaxM;              % Activation of each muscle
plotActivation(NoAM,MRC,fascicleActivation,{musclePaths.Name},muscleActivation,muscleNames);

end