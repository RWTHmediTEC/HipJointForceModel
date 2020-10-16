clearvars

addpath(genpath('..\src'))
addpath(genpath('..\data'))
addpath(genpath('src'))

cadavers = {'Fick1850','Dostal1981','TLEM2_0'};
models = {'Pauwels','Debrunner1975','Iglic'};

%% Create results
results = cell(length(cadavers), length(models));
for c = 1:length(cadavers)
    for m=1:length(models)
        data = createDataTLEM2();
        data = createDataTLEM2(data, cadavers{c});
        
        data.ScalingLaw = 'None';
        data.MusclePathModel = 'StraightLine';
        
        data.Model = models{m};
        
        modelHandle = str2func(data.Model);
        gui.Home.Model.modelHandle = modelHandle();
        [postures, defaultPosture] = gui.Home.Model.modelHandle.Posture();
        for p = 1:length(postures)
            data.Posture = postures{p,2};
            
            data.activeMuscles = gui.Home.Model.modelHandle.Muscles();
            data.activeMuscles = parseActiveMuscles(data.activeMuscles, data.MuscleList);
            
            results{c,m,p} = validateTLEM2(data, gui);
        end
    end
end

%% Evaluate results
[E_Mag, E_Dir, PE_Mag] = deal(cell(length(cadavers), length(models), length(postures)));
compTab = cell(2+length(cadavers),1+2*length(models));
errorNames = {'MAE Mag.','MAE Dir.'};
NoE = length(errorNames);
for p = 1:length(postures)
    for c = 1:length(cadavers)
        compTab{2+c,1,p} = cadavers{c};
        for m=1:length(models)
            compTab{1,2+(m-1)*NoE,p} = models{m};
            compTab(2,2+(m-1)*NoE:1+m*NoE,p) = errorNames;
            if ~isempty(results{c,m})
                sHJF = reshape([results{c,m,p}.HJF_Wu2002],[3,10])';
                iHJF = reshape([results{c,m,p}.OL_HJF_Wu2002],[3,10])';
                % Error magnitude
                E_Mag{c,m,p} = vectorNorm3d(sHJF)-vectorNorm3d(iHJF);
                % Error direction
                E_Dir{c,m,p} = vectorAngle3d(sHJF, iHJF);
                % Percentage error magnitude
                PE_Mag{c,m,p} = (vectorNorm3d(sHJF)-vectorNorm3d(iHJF))./vectorNorm3d(iHJF);
                
                % Final small table
                compTab(2+c,2+(m-1)*NoE,p) = medianStats(abs(E_Mag{c,m,p}),'format','short');
                compTab(2+c,1+m*NoE,p)     = medianStats(rad2deg(E_Dir{c,m,p}),'format','short');
            end
        end
    end
    writecell(compTab(:,:,p),'compareCadavers.xlsx','Sheet',postures{p,2},'Range','B2')
end
