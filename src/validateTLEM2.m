function Results = validateTLEM2(data, gui)
% Calculate validation parameters for the OrthoLoad subjects

OL = importDataOrthoLoad;

Results = repmat(struct('Subject', []), length(OL),1);

for s = 1:length(OL)
    % Save results in structure Results
    Results(s).Subject = OL(s).Subject;
    Results(s).Sex     = OL(s).Sex;
    try
        % Load body weight and HJF of OrthoLoad subjects
        load([OL(s).Subject '_' data.Posture '.mat'],'meanPFP')
        OL(s).BodyWeight = meanPFP.Weight_N / data.g; % [N] to [kg]
        
        % The HJF of the OrthoLoad subjects is given in the OrthLoad CS 
        % [Bergmann 2016]. Use the orientation 'ASR' instead of 'RAS'.
        OL(s).HJF_Bergmann2016 = transformVector3d(meanPFP.HJF_pBW,...
            anatomicalOrientationTFM('RAS','ASR'));
        % Transform OrthoLoad HJF into the Wu2002 CS
        % The OrthoLoad HJF is presented for the right side for all
        % subjects. Left sides were mirrored.
        OL(s).HJF_Wu2002 = transformVector3d(meanPFP.HJF_pBW, OL(s).Wu2002TFM);
        
        % Biometric
        data.S.Side       = OL(s).Subject(end); % 'R' or 'L'
        data.S.BodyWeight = OL(s).BodyWeight; % [kg]
        data.S.BodyHeight = OL(s).BodyHeight; % [cm]
        
        % Functional pelvic parameters
        data.S.PelvicTilt = 0; % Not available for OrthoLoad subjects
        
        %% Skinning landmarks
        if isfield(data.T.Scale, 'Landmarks')
            % Pelvis skinning landmarks
            pelvisLM = fieldnames(data.T.Scale(1).Landmarks);
            for lm=1:length(pelvisLM)
                data.S.Scale(1).Landmarks.(pelvisLM{lm}) = ...
                    OL(s).Landmarks.Pelvis.([pelvisLM{lm} '_' OL(s).Subject(end)]);
            end
            pelvicBoneCSLM = fieldnames(data.T.Scale(1).boneCSLandmarks);
            for lm=1:length(pelvicBoneCSLM)
                data.S.Scale(1).boneCSLandmarks.(pelvicBoneCSLM{lm}) = ...
                    OL(s).Landmarks.Pelvis.(pelvicBoneCSLM{lm});
            end
            % Femur skinning landmarks
            femurLM = fieldnames(data.T.Scale(2).Landmarks);
            for lm=1:length(femurLM)
                data.S.Scale(2).Landmarks.(femurLM{lm}) = ...
                    OL(s).Landmarks.Femur.([femurLM{lm} '_' OL(s).Subject(end)]);
            end
            % For scaling landmarks have to be mirrored to the right side as
            % the cadavers are right sided.
            switch OL(s).Subject(end)
                case 'L'
                    mirrorZTFM = eye(4); mirrorZTFM(3,3) = -1;
                    data.S.Scale(1).Landmarks = structfun(@(x) ...
                        transformPoint3d(x, mirrorZTFM), data.S.Scale(1).Landmarks,'uni',0);
                    data.S.Scale(1).boneCSLandmarks = structfun(@(x) ...
                        transformPoint3d(x, mirrorZTFM), data.S.Scale(1).boneCSLandmarks,'uni',0);
                    data.S.Scale(2).Landmarks = structfun(@(x) ...
                        transformPoint3d(x, mirrorZTFM), data.S.Scale(2).Landmarks,'uni',0);
            end
        end
        
        %% Scaling parameters
        % Pelvis scaling parameters
        data.S.Scale(1).HipJointWidth  = OL(s).HipJointWidth;
        data.S.Scale(1).ASISDistance   = OL(s).ASISDistance;
        data.S.Scale(1).HJCASISHeight  = OL(s).HJCASISHeight;
        data.S.Scale(1).PelvicWidth    = OL(s).PelvicWidth;
        data.S.Scale(1).PelvicHeight   = OL(s).PelvicHeight;
        data.S.Scale(1).PelvicDepth    = OL(s).PelvicDepth;
        
        % Femur scaling parameters 
        data.S.Scale(2).FemoralLength  = OL(s).FemoralLength;
        data.S.Scale(2).FemoralWidth   = OL(s).FemoralWidth;
        data.S.Scale(2).FemoralVersion = OL(s).FemoralVersion;
        data.S.Scale(2).NeckLength     = OL(s).NeckLength;
        data.S.Scale(2).CCD            = OL(s).CCD;
        
        %% Calculate HJF
        data = scaleTLEM2(data);
        data = globalizeTLEM2(data);
        data = gui.Home.Model.modelHandle.Calculation(data);
        if isfield(gui.Home, 'Visualization')
            delete(gui.Home.Visualization.Axis_Visualization.Children);
            visualizeTLEM2(gui.Home.Visualization.Axis_Visualization, ...
                data.S.LE, data.S.Side,...
                'Muscles', data.S.MusclePaths,...
                'MuscleList', data.MuscleList,...
                'MusclePathModel',data.MusclePathModel,...
                'Surfaces',gui.Home.Settings.Checkbox_ShowWrappingSurfaces.Value);
            gui.IsUpdated = true;
            gui = updateSide(data, gui);
            gui = updateParameters(data, gui);
            gui = updateResults(data, gui);
            drawnow
        end
        
        % % Save subject-specific pelvis
        % pelvis = data.S.LE(1).Mesh;
        % switch OL(s).Subject(end)
        %         case 'L'
        %             pelvis = transformPoint3d(pelvis, mirrorZTFM);
        % end
        % stlWrite([OL(s).Subject '_' strrep(data.Cadaver, '_', '') '_Pelvis.stl'], pelvis)
        % % Save subject-specific femur
        % femur = data.S.LE(2).Mesh;
        % switch OL(s).Subject(end)
        %         case 'L'
        %             femur = transformPoint3d(femur, mirrorZTFM);
        % end
        % stlWrite([OL(s).Subject '_' strrep(data.Cadaver, '_', '') '_Femur.stl'], femur)
        
        HJF_Wu2002 = data.HJF.Femur.Wu2002.R; % In 'ASR'
        % Use the simulated HJF in the OrthoLoad CS [Bergmann 2016] for the 
        % comparison. Use the orientation 'ASR' instead of 'RAS'.
        HJF_Bergmann2016 = transformVector3d(data.HJF.Femur.Bergmann2016.R, ...
            anatomicalOrientationTFM('RAS','ASR'));
        
        Results(s).HJF_Wu2002          = HJF_Wu2002;
        Results(s).HJF_Pelvis_Wu2002   = data.HJF.Pelvis.Wu2002.R;
        Results(s).OL_HJF_Wu2002       = OL(s).HJF_Wu2002;
        Results(s).HJF_Bergmann2016    = HJF_Bergmann2016;
        Results(s).OL_HJF_Bergmann2016 = OL(s).HJF_Bergmann2016;
        Results(s).BodyWeight          = OL(s).BodyWeight;
    catch err
        fprintf(1,'The identifier was: %s\n',err.identifier);
        fprintf(1,'There was an error! The message was: %s\n',err.message);
        % Otherwise fill up with nan
        Results(s).HJF_Wu2002          = nan(1,3);
        Results(s).OL_HJF_Wu2002       = nan(1,3);
        Results(s).HJF_Bergmann2016    = nan(1,3);
        Results(s).OL_HJF_Bergmann2016 = nan(1,3);
        warning(['Validation with subject ' Results(s).Subject ' failed!'])
    end
    
end