clearvars; warning off backtrace; warning off verbose

addpath(genpath('..\src'))
addpath(genpath('..\data'))
addpath(genpath('src'))

cadavers = {'TLEM2_0'};
model = 'mediTEC2020';
MRC = {'Polynom1','Polynom2','Polynom3','Polynom5','MinMax'};

%% Create results
results = cell(length(cadavers), length(MRC));
for c = 1:length(cadavers)
    for m=1:length(MRC)
        disp([cadavers{c} ' - ' MRC{m}])
        data = createLEM();
        data.Verbose = 0;
        data = createLEM(data, cadavers{c});
        
        switch cadavers{c}
            case 'Dostal1981'
                data.ScalingLaw = 'NonUniformLinearB';
                data.MusclePathModel = 'StraightLine';
            case 'TLEM2_0'
                data.ScalingLaw = 'LandmarkDeformableBones';
                data.MusclePathModel = 'Wrapping';
        end
        
        data.Model = model;
        data.MuscleRecruitmentCriterion = MRC{m};
        
        modelHandle = str2func(data.Model);
        gui.Home.Model.modelHandle = modelHandle();
        [postures, defaultPosture] = gui.Home.Model.modelHandle.Posture();
        for p = 1:length(postures)
            data.Posture = postures{p,2};
            
            data.activeMuscles = gui.Home.Model.modelHandle.Muscles();
            data.activeMuscles = parseActiveMusclesLEM(data.activeMuscles, data.MuscleList);
            
            results{c,m,p} = validateLEM(data, gui);
        end
    end
end

%% Evaluate results
alpha = 0.01;

[AE_Mag, AE_Dir, APE_Mag] = deal(cell(length(cadavers), length(MRC), length(postures)));
compTab = cell(2+length(cadavers),1+2*length(MRC));
errorNames = {'MAE Mag.','MAE Dir.'};
NoE = length(errorNames);
for p = 1:length(postures)
    for c = 1:length(cadavers)
        compTab{2+c,1,p} = cadavers{c};
        for m=1:length(MRC)
            compTab{1,2+(m-1)*NoE,p} = MRC{m};
            compTab(2,2+(m-1)*NoE:1+m*NoE,p) = errorNames;
            if ~isempty(results{c,m})
                % Predicted and in vivo HJF
                pHJF = reshape([results{c,m,p}.HJF_Bergmann2016],[3,10])';
                iHJF = reshape([results{c,m,p}.OL_HJF_Bergmann2016],[3,10])';
                % Absolute Error in magnitude
                AE_Mag{c,m,p} = abs(vectorNorm3d(pHJF)-vectorNorm3d(iHJF));
                % Angular Error in direction
                AE_Dir{c,m,p} = rad2deg(vectorAngle3d(pHJF, iHJF));
                
                % Table
                compTab(2+c,2+(m-1)*NoE,p) = medianStats(AE_Mag{c,m,p},'format','short','test','none','alpha',alpha);
                compTab(2+c,1+m*NoE,p)     = medianStats(AE_Dir{c,m,p},'format','short','test','none','alpha',alpha);
            end
        end
    end
    writecell(compTab(:,:,p),'compareRecruitment.xlsx','Sheet',postures{p,2},'Range','B2')
end

% [p,tbl,stats] = friedman(cell2mat(AE_Mag(1,:,1)));
% multcompare(stats,'alpha',0.01)