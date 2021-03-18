clearvars; warning off backtrace; warning off verbose

addpath(genpath('..\src'))
addpath(genpath('..\data'))
addpath(genpath('src'))

models = {...
    'Pauwels', 'Dostal1981', 'None', 'None', 'StraightLine'; ...
    'Debrunner', 'Dostal1981', 'NonUniformLinearA', 'None', 'StraightLine'; ...
    'Schimmelpfennig2020', 'TLEM2_0', 'LandmarkDeformableBones', 'Polynom1', 'Wrapping';...
    };

alpha = 0.01;

%% Create results
NoM = size(models,1);
results = cell(NoM,1);
for m=1:NoM
    disp(['Model: ' models{m,1} ', Cadaver: ' models{m,2} ', Scaling Law: ' models{m,3} ...
        ', Recruitm. Criterion: ' models{m,4} ', Muscle Paths: ' models{m,5}])
    data = createLEM();
    data.Verbose = 0;
    data = createLEM(data, models{m,2});
    
    data.Model = models{m,1};
    data.ScalingLaw = models{m,3};
    data.MuscleRecruitmentCriterion = models{m,4};
    data.MusclePathModel = models{m,5};
    
    modelHandle = str2func(data.Model);
    gui.Home.Model.modelHandle = modelHandle();
    [postures, defaultPosture] = gui.Home.Model.modelHandle.Posture();
    for p = 1:length(postures)
        data.Posture = postures{p,2};
        
        data.activeMuscles = gui.Home.Model.modelHandle.Muscles();
        data.activeMuscles = parseActiveMusclesLEM(data.activeMuscles, data.MuscleList);
        
        results{m,p} = validateLEM(data, gui);
    end
end

%% Evaluate results
[AE_Mag, AE_Dir, APE_Mag, E, RMSE] = deal(cell(size(results)));
compTab = cell((2+length(postures))*NoM, 10);

for m=1:NoM
    compTab(m*4-3,1:5) = models(m,1:5);
    for p = 1:length(postures)
        % Predicted and in vivo HJF
        pHJF = reshape([results{m,p}.HJF_Wu2002],[3,10])';
        iHJF = reshape([results{m,p}.OL_HJF_Wu2002],[3,10])';
        % Absolute Error in magnitude
        AE_Mag{m,p} = abs(vectorNorm3d(pHJF)-vectorNorm3d(iHJF));
        % Angular Error in direction
        AE_Dir{m,p} = rad2deg(vectorAngle3d(pHJF, iHJF));
        % Absolute percentage error in magnitude
        APE_Mag{m,p} = 100*abs((vectorNorm3d(pHJF)-vectorNorm3d(iHJF))./vectorNorm3d(iHJF));
        % Error
        E{m,p} = pHJF-iHJF;
        % RMSE in magnitude
        RMSE{m,p} = num2str(rmse(vectorNorm3d(iHJF), vectorNorm3d(pHJF)),'%.0f');
        
        % Final table
        r = m*4-2+p;
        compTab{r,1} = postures{p};
        
        compTab(m*4-2,2) = {'MAE Mag. [%BW]'};
        compTab(r,2) = medianStats(AE_Mag{m,p},'format','Q234','fSpec','%.0f');
        compTab(m*4-2,3) = {'MAPE Mag. [%]'};
        compTab(r,3) = meanStats(APE_Mag{m,p},'format','short','fSpec','%.0f');
        compTab(m*4-2,4) = {'RMSE Mag. [%BW]'};
        compTab(r,4) = RMSE(m,p);
        compTab(m*4-2,5) = {'MAE PA [%BW]'};
        compTab(r,5) = medianStats(abs(E{m,p}(:,1)),'format','Q234','fSpec','%.0f');
        compTab(m*4-2,6) = {'MAE IS [%BW]'};
        compTab(r,6) = medianStats(abs(E{m,p}(:,2)),'format','Q234','fSpec','%.0f');
        compTab(m*4-2,7) = {'MAE ML [%BW]'};
        compTab(r,7) = medianStats(abs(E{m,p}(:,3)),'format','Q234','fSpec','%.0f');
        compTab(m*4-2,8) = {'ME PA [%BW]'};
        compTab(r,8) = medianStats(E{m,p}(:,1),'format','short','fSpec','%.0f');
        compTab(m*4-2,9) = {'ME IS [%BW]'};
        compTab(r,9) = medianStats(E{m,p}(:,2),'format','short','fSpec','%.0f');
        compTab(m*4-2,10) = {'ME ML [%BW]'};
        compTab(r,10) = medianStats(E{m,p}(:,3),'format','short','fSpec','%.0f');
    end
end
writecell(compTab,'compareModelsDetailed.xlsx','Range','B2')