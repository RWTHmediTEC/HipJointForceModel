clearvars; warning off backtrace; warning off verbose

addpath(genpath('..\src'))
addpath(genpath('..\data'))
addpath(genpath('src'))

scalingLaws = {'None', 'NonuniformSedghi2017', 'NonuniformEggert2018', 'LandmarkSkinningFischer2018'};
models = {'Pauwels','Debrunner1975','Iglic'};

%% Create results
results = cell(length(scalingLaws), length(models));
for s = 1:length(scalingLaws)
    for m=1:length(models)
        data = createDataTLEM2();
        data = createDataTLEM2(data, 'TLEM2_0');
        
        data.ScalingLaw = scalingLaws{s};
        data.MusclePathModel = 'Wrapping';
        
        data.Model = models{m};
        
        modelHandle = str2func(data.Model);
        gui.Home.Model.modelHandle = modelHandle();
        [postures, defaultPosture] = gui.Home.Model.modelHandle.Posture();
        for p = 1:length(postures)
            data.Posture = postures{p,2};
            
            data.activeMuscles = gui.Home.Model.modelHandle.Muscles();
            data.activeMuscles = parseActiveMuscles(data.activeMuscles, data.MuscleList);
            
            results{s,m,p} = validateTLEM2(data, gui);
        end
    end
end

%% Evaluate results
[E_Mag, E_Dir, PE_Mag] = deal(cell(length(scalingLaws), length(models), length(postures)));
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
                % Simulated and invivo HJF
                sHJF = reshape([results{s,m,p}.HJF_Wu2002],[3,10])';
                iHJF = reshape([results{s,m,p}.OL_HJF_Wu2002],[3,10])';
                % Error magnitude
                E_Mag{s,m,p} = vectorNorm3d(sHJF)-vectorNorm3d(iHJF);
                % Error direction
                E_Dir{s,m,p} = vectorAngle3d(sHJF, iHJF);
                % Percentage error magnitude
                PE_Mag{s,m,p} = (vectorNorm3d(sHJF)-vectorNorm3d(iHJF))./vectorNorm3d(iHJF);
                
                % Final small table
                compTab(2+s,2+(m-1)*NoE,p) = medianStats(abs(E_Mag{s,m,p}),'format','short');
                compTab(2+s,1+m*NoE,p)     = medianStats(rad2deg(E_Dir{s,m,p}),'format','short');
            end
        end
    end
    writecell(compTab(:,:,p),'compareScalingLaws.xlsx','Sheet',postures{p,2},'Range','B2')
end
