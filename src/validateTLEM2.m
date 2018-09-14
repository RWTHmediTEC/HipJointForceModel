function Results = validateTLEM2(data, gui)
% Calculate validation parameters for the OrthoLoad subjects and TLEM2.0 cadaver

        if exist('data\OrthoLoad.mat', 'file')
            load('OrthoLoad', 'OL')
        else
            importDataOrthoLoad
        end
        
        data.OL = OL;
        Results = repmat(struct('Subject', []), length(data.OL),1);
        
        for p = 1:length(data.OL)
            
            data.LE = data.TLEM;
            data.Side = data.OL(p).Subject(end);
            data.PB = 0;
            
            [data.LE, data.RHRC, data.SPW, data.SPH, data.SPD, data.SFL] =...
                scaleTLEM2(data.LE, data.OL(p).HRC, data.OL(p).PW, data.OL(p).PH, data.OL(p).PD, data.OL(p).FL,...
                data.OL(p).NL, data.OL(p).FV, data.OL(p).CCD);
            
            % Use the selected model to calculate the HJF
            data = globalizeTLEM2(data);
            [data.rMag, data.rMagP, data.rPhi, data.rTheta, data.rAlpha,...
                data.rDir, data.rX, data.rY, data.rZ] =...
                gui.modelHandle.Calculation(data);
            
            Results(p).Subject = data.OL(p).Subject;
            Results(p).Sex = data.OL(p).Sex;
            
            % Scaling parameters
            Results(p).BW   = data.OL(p).BW;
            Results(p).HRC  = data.OL(p).HRC;
            Results(p).RHRC = data.RHRC;
            Results(p).PW   = data.OL(p).PW;
            Results(p).SPW  = data.SPW;
            Results(p).PH   = data.OL(p).PH;
            Results(p).SPH  = data.SPH;
            Results(p).PD   = data.OL(p).PD;
            Results(p).SPD  = data.SPD;
            Results(p).FL   = data.OL(p).FL;
            Results(p).SFL  = data.SFL;
            
            % Force parameters
            Results(p).rX         = data.rX;
            Results(p).rY         = data.rY;
            Results(p).rZ         = data.rZ;
            Results(p).rMag       = data.rMag;
            Results(p).rMagP      = data.rMagP;
            Results(p).OrrMagP    = data.OL(p).rMagP;
                errP = abs((data.rMagP - data.OL(p).rMagP) / data.OL(p).rMagP * 100);
            Results(p).errP       = errP;
            Results(p).rPhi       = data.rPhi;          
            Results(p).OrPhi      = data.OL(p).rPhi;
                errPhi = abs(abs(data.rPhi) - abs(data.OL(p).rPhi));
            Results(p).errPhi     = errPhi;
            Results(p).rTheta     = data.rTheta;
            Results(p).OrTheta    = data.OL(p).rTheta;
                errTheta = abs(data.rTheta - data.OL(p).rTheta);
            Results(p).errTheta   = errTheta;
            Results(p).rAlpha     = data.rAlpha;
            Results(p).OrAlpha    = data.OL(p).rAlpha;
                errAlpha = abs(data.rAlpha - data.OL(p).rAlpha);
            Results(p).errAlpha = errAlpha;
        end
        
%         % TLEM2
%         data.LE = data.TLEM;
%         data.BW = 45;
%         data.Side = 'R';
%         data.PW = 0;
%         
%         [data.LE, ~, data.SPW, data.SPH, data.SPD, data.SFL,...
%             data.HRC,data.PW, data.PH, data.PD, data.FL] =...
%             scaleTLEM2(data.LE);
%         
%         % Use the selected model to calculate the HJF
%         data = globalizeTLEM2(data);
%         [data.rMag, data.rMagP, data.rPhi, data.rTheta, data.rAlpha,...
%             data.rDir, data.rX, data.rY, data.rZ] =...
%             gui.modelHandle.Calculation(data);       
%         
%         Results(1).Subject = 'TLEM 2.0';
%         Results(1).Sex = 'm';
%         
%         % Scaling parameters
%         Results(1).BW   = data.BW;
%         Results(1).HRC  = data.HRC;
%         Results(1).PW   = data.PW;
%         Results(1).SPW  = data.SPW;
%         Results(1).PH   = data.PH;
%         Results(1).SPH  = data.SPH;
%         Results(1).PD   = data.PD;
%         Results(1).SPD  = data.SPD;
%         Results(1).FL   = data.FL;
%         Results(1).SFL  = data.SFL;
%         
%         % Force parameters
%         Results(1).rX        = data.rX;
%         Results(1).rY        = data.rY;
%         Results(1).rZ        = data.rZ;
%         Results(1).rMag      = data.rMag;
%         Results(1).rMagP     = data.rMagP;
%         Results(1).rPhi      = data.rPhi;
%         Results(1).rTheta    = data.rTheta;
%         Results(1).rAlpha    = data.rAlpha;
end