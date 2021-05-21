clearvars; warning off backtrace; warning off verbose

% Script to create Table 2 & 3 in 2021 - Fischer - Effect of the underlying 
% cadaver data and patient-specific adaptation of the femur and pelvis on 
% the prediction of the hip joint force estimated using static models
% https://doi.org/10.1016/j.jbiomech.2021.110526
%
% AUTHOR: M.C.M. Fischer
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

addpath(genpath('..\src'))
addpath(genpath('..\data'))
addpath(genpath('src'))

cadaver = 'TLEM2_0'; % 'Dostal1981'

models = {'Pauwels2021','Debrunner2021','Iglic2021','mediTEC2021'};

switch cadaver
    case 'Dostal1981'
        scalingLaws = {'None', 'NonUniformLinearA', 'NonUniformLinearB'};
        musclePathModel = 'StraightLine';
    case 'TLEM2_0'
        scalingLaws = {'None', 'NonUniformLinearA', 'NonUniformLinearB', 'LandmarkDeformableBones'};
        musclePathModel = 'Wrapping';
end

alpha = 0.01;

%% Create results
results = cell(length(scalingLaws), length(models));
for s = 1:length(scalingLaws)
    for m=1:length(models)
        display([scalingLaws{s} ' - ' models{m}])
        data = createLEM();
        data.Verbose = 0;
        data = createLEM(data, cadaver);
        
        data.ScalingLaw = scalingLaws{s};
        data.MusclePathModel = musclePathModel;
        
        data.Model = models{m};
        
        switch data.Model
            case {'Pauwels2021','Debrunner2021','Iglic2021'}
                data.MuscleRecruitmentCriterion = 'None';
            case {'mediTEC2021'}
                data.MuscleRecruitmentCriterion = 'Polynom2';
        end
        
        modelHandle = str2func(data.Model);
        gui.Home.Model.modelHandle = modelHandle();
        [postures, defaultPosture] = gui.Home.Model.modelHandle.Posture();
        for p = 1:length(postures)
            data.Posture = postures{p,2};
            
            data.activeMuscles = gui.Home.Model.modelHandle.Muscles();
            data.activeMuscles = parseActiveMusclesLEM(data.activeMuscles, data.MuscleList);
            
            results{s,m,p} = validateLEM(data, gui);
        end
    end
end

%% Evaluate results
[AE_Mag, AE_Dir, APE_Mag] = deal(cell(length(scalingLaws), length(models), length(postures)));
compTab = cell(2+length(scalingLaws),1+2*length(models));
errorNames = {'MAE Mag.','MAE Dir.'};
NoE = length(errorNames);
for p = 1:length(postures)
    for s = 1:length(scalingLaws)
        compTab{2+s,1,p} = scalingLaws{s};
        for m=1:length(models)
            compTab{1,2+(m-1)*NoE,p} = models{m};
            compTab(2,2+(m-1)*NoE:1+m*NoE,p) = errorNames;
            if ~isempty(results{s,m})
                % Predicted and in vivo HJF
                pHJF = reshape([results{s,m,p}.HJF_Wu2002],[3,10])';
                iHJF = reshape([results{s,m,p}.OL_HJF_Wu2002],[3,10])';
                % Absolute Error in magnitude
                AE_Mag{s,m,p} = abs(vectorNorm3d(pHJF)-vectorNorm3d(iHJF));
                % Angular Error in direction
                AE_Dir{s,m,p} = rad2deg(vectorAngle3d(pHJF, iHJF));
                
                % Table
                compTab(2+s,2+(m-1)*NoE,p) = medianStats(AE_Mag{s,m,p},'format','short','test','none','alpha',alpha);
                compTab(2+s,1+m*NoE,p)     = medianStats(AE_Dir{s,m,p},'format','short','test','none','alpha',alpha);
            end
        end
    end
    
    % Significant differences to the unscaled cadaver
    for s = 2:length(scalingLaws)
        for m=1:length(models)
            if ~isempty(results{s,m})
                if signrank(AE_Mag{1,m,p}, AE_Mag{s,m,p}) <= alpha
                    compTab{2+s,2+(m-1)*NoE,p} = [compTab{2+s,2+(m-1)*NoE,p} '†'];
                end
                if signrank(AE_Dir{1,m,p}, AE_Dir{s,m,p}) <= alpha
                    compTab{2+s,1+m*NoE,p} = [compTab{2+s,1+m*NoE,p} '†'];
                end
            end
        end
    end
    
    writecell(compTab(:,:,p),['compareScalingLaws_' cadaver '.xlsx'],'Sheet',postures{p,2},'Range','B2')
end
