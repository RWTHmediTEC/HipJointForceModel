function force = muscleRecruitment(a, w, r, s, PCSA, data)
% a = lever arm of the body weight force;
% w = body weight force;
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
% Muscle Tension [N/mm²] 0.9 in Anybody, 0.5 in CusToM
SIGMA = 0.9;
% Maximal fascicle strength [N]
fMax = SIGMA*PCSA;
% Weighting factor in Minmax and Polynomial criteria (fMax or PCSA)
n = 'Fmax';
switch n
    case 'Fmax'
        N = fMax;
    case 'PCSA'
        N = PCSA;
end

% Number of active fascicles
NoAF = length(musclePaths);

%% Calculation of Resultant Muscle Force
% Lever arms of muscles around hip joint center [mm]
leverArm = leverOfMuscles(NoAF,r,s,z);
% Moment of bodyweight force around hip joint center [Nmm]
switch side
    case 'R'
        momentW = cross([0 0 -a], w);
    case 'L'
        momentW = cross([0 0  a], w);
end

% Lever arms of all active muscles around hip joint center
aeq = zeros(3,NoAF);
aeq(1,:) = leverArm;
% Negative moment of external forces around hip joint center
beq = -momentW';


%% Optimization of muscle forces
% Initial value of optimization
F_0 = zeros(NoAF,1);
% Minimum fasicle strength [N]
F_MIN = zeros(size(F_0));
% Optimization options
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
switch MRC
    case 'MinMax'
        % MinMax muscle recruitment criteria
        fascicleForce = muscleRecruitmentMinMax(F_0,F_MIN,fMax,aeq,beq,N,opts);
    case {'Polynom2', 'Polynom3', 'Polynom5'}
        % Polynomial muscle recruitment criteria with power = 2, 3 or 5
        DP = str2double(MRC(end));
        fascicleForce = muscleRecruitmentPoly(DP,F_0,F_MIN,fMax,aeq,beq,N,opts);
    case 'Energy'
        % Energy muscle recruitment criteria
        if size(muscleList,2) >= 7
            % Get mass of each fascicle
            fascicleMass = zeros(NoAF,1);
            for m = 1:NoAF
                PCSA_Idx = strcmp(musclePaths(m).Name(1:end-1), muscleList(:,1));
                fascicleMass(m) = muscleList{PCSA_Idx,7} / muscleList{PCSA_Idx,4};
            end
        else
            errMessage = ['No muscle mass available for the selected cadaver. '...
                'Choose another cadaver to use this muscle recruitment criterion!'];
            msgbox(errMessage,mfilename,'error')
            error(errMessage)
        end
        % Weighting factor in Energy criteria [~]
        C1 = .5;
        fascicleForce = muscleRecruitmentEnergy(C1,F_0,F_MIN,fMax,aeq,beq,PCSA,opts,fascicleMass);
end

% Get force matrix by multiplying the force diagonal matrix with the matrix
% of the unit force direction vector
force = s'*diag(fascicleForce);

% Check if optimization was succesful
momF = leverArm*fascicleForce;
sm = sum(momF);
% Check whether moments are equal
if ~isequal(round(sm,4),round(-momentW(1),4))
    uiwait(msgbox({'Unphysiolocial!';'Imbalance of moments!';...
        [num2str(round(sm,4)),' = ',num2str(round(-momentW(1),4))]},'Warning','warn','modal'));
end

disp(['Muscle recruitment took ' num2str(toc(tStart),'%.0f') ' seconds.'])


%% Activation
% Get Fmax of each muscle
[nbFas,fMaxM] = deal(zeros(NoAF,1));
activeMuscles = '';
for m = 1:NoAF
    % Find Index of active fascicle
    tempIdx = strcmp(musclePaths(m).Name(1:end-1),muscleList(:,1));
    activeMuscles{m} = cellstr(muscleList(tempIdx,1));
    nbFas(m) = muscleList{tempIdx,4};
    fMaxM(m) = muscleList{tempIdx,5}*SIGMA;
end
% Delete values of all fascicles except one per muscle
[~,idx] = unique(fMaxM,'first');
% Number of fascicles of each muscle
nbFas = nbFas(sort(idx),:);
% Names of active muscles
activeMuscles = string(activeMuscles(:,sort(idx)));
% Fmax of each muscle [N]
fMaxM = fMaxM(sort(idx),:);

% Get force of active muscles
muscleForce = zeros(length(fMaxM),1);
% Calculation of the sum of all fascicle forces of each muscle
for i = 1:length(fMaxM)
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
plotActivation(NoAF,MRC,fascicleActivation,{musclePaths.Name},muscleActivation,activeMuscles);

end