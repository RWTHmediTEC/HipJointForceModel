function createOrthoLoadForceData(dbPath, varargin)
%CREATEORTHOLOADFORCEDATA extracts the in vivo hip joint force (HJF) of the 
% OrthoLoad subjects during the peak force phase of activities of daily
% living.
%
% The in vivo HJF is derived from the extensive Hip Joint III Data 
% Collection that contains the individual average HJF for several ADL 
% calculated from multiple trials of each patient.
% 
% Reference:
% [Bergmann 2016] 2016 - Bergmann - Standardized Loads Acting in Hip Implants
% Hip Joint III Data Collection:
% https://orthoload.com/test-loads/standardized-loads-acting-at-hip-implants/
% https://orthoload.com/wp-content/uploads/StandardLoads-Hip_CompleteData.zip
% 
% Input:
% The path of the Hip Joint III Data Collection of the publication, e.g.:
% 'C:\StandardLoads-Hip_CompleteData\Data\';
% or
% 'D:\StandardLoads-Hip_CompleteData\Data\';

% Parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'visualization',0, logParValidFunc);
parse(p,varargin{:});
visu = p.Results.visualization;

dbPath = fullfile(dbPath, '\');

% Name of the activities in OrthoLoad and this framework + abbreviation
activities = {...
    'Walking', 'Level Walking', 'LW';...
    'Stance' , 'One-Legged Stance', 'OLS';...
    'StandUp', 'StandingUp', 'SU'};

% Implant side of the the OrthoLoad subjects
sides = {'L','R','L','L','L','R','R','L','L','R'};

% Visualization settings
pointProps.Marker='o';
pointProps.MarkerSize=5;
pointProps.MarkerEdgeColor='k';
pointProps.MarkerFaceColor='k';
pointProps.Color='none';

for a=1:length(activities)
    for s=1:10
        sFile = dir([dbPath activities{a,1} '\' activities{a,1} '_H' num2str(s) '\' activities{a,1} '_H' num2str(s) '.xlsx']);
        peakIdx = [];
        if length(sFile) == 1
            OL_Data = xlsread(fullfile(sFile.folder, sFile.name),'BW'); % Read the BW sheet
            % Import body weight [N]
            avPFP.Weight_N = OL_Data(1,2);
            assert(avPFP.Weight_N >= 300 && avPFP.Weight_N <= 2000)
            % Import HJF [%BW]
            sIdx = find(OL_Data(:,1)==0 & OL_Data(:,11) ==0);
            assert(~isempty(sIdx))
            eIdx = find(ismembertol(OL_Data(:,11),100));
            assert(~isempty(eIdx))
            avHJF = OL_Data(sIdx:eIdx,[11,2:5]);
            % Find peak force phase
            switch activities{a,1}
                case 'Walking'
                    [~, peakIdx] = findpeaks(avHJF(:,5),...
                        'MinPeakHeight', 0.75*max(avHJF(:,5)),...
                        'MinPeakProminence',10,...
                        'NPeaks',2);
                    assert(numel(peakIdx) == 2)
                    % Add -+ 2.5% values
                    pfpIdx = [...
                        peakIdx(1)-round(0.025*size(avHJF,1))+1: ...
                        peakIdx(1)+round(0.025*size(avHJF,1)), ...
                        peakIdx(2)-round(0.025*size(avHJF,1))+1: ...
                        peakIdx(2)+round(0.025*size(avHJF,1))];
                case 'Stance'
                    % Identify a rough estimation of force plateau during
                    % stance phase. Keep all values above 75% of Fmax
                    pfpIdx = find(avHJF(:,5) > 0.75*max(avHJF(:,5)));
                    % Take all from first to last
                    pfpIdx = pfpIdx(1):pfpIdx(end);
                    % Take the median +- 25% of the cycle
                    pfpIdx = ...
                        round(median(pfpIdx))-round(0.25*size(avHJF,1))+1: ...
                        round(median(pfpIdx))+round(0.25*size(avHJF,1));
                case 'StandUp'
                    % Find Fmax
                    [~, peakIdx] = max(avHJF(:,5));
                    assert(numel(peakIdx) == 1)
                    % Add -+ 2.5% values
                    pfpIdx = ...
                        peakIdx-round(0.025*size(avHJF,1))+1: ...
                        peakIdx+round(0.025*size(avHJF,1));
                otherwise
                    error([activities{a,1} ' not implemented yet!'])
            end
            avPFP.HJF_pBW = mean(avHJF(pfpIdx,2:4));
            % Save in vivo HJF
            meanPFP = avPFP;
            writestruct(meanPFP,['H' num2str(s) sides{s} '_' activities{a,3} '.xml'])
            clearvars avPFP meanPFP
            if visu
                figure('Name', sFile.name, 'NumberTitle', 'off',...
                    'Color', 'w','Position', [100,400,1600,400]);
                saxH(1) = subplot(1,4,1);
                plot(avHJF(:,1),avHJF(:,2),'g'); grid on;
                xlabel('Load Cycle [%]'); ylabel('Lateral Force F_x [%BW]')
                saxH(2) = subplot(1,4,2);
                plot(avHJF(:,1),avHJF(:,3),'b'); grid on;
                xlabel('Load Cycle [%]'); ylabel('Anterior Force F_y [%BW]')
                saxH(3) = subplot(1,4,3);
                plot(avHJF(:,1),avHJF(:,4),'r'); grid on;
                xlabel('Load Cycle [%]'); ylabel('Superior Force F_z [%BW]')
                saxH(4) = subplot(1,4,4);
                plot(avHJF(:,1),avHJF(:,5),'k'); grid on;
                xlabel('Load Cycle [%]'); ylabel('Resultant Force F_{res} [%BW]')
                for h=1:4
                    hold(saxH(h),'on')
                    plot(saxH(h), avHJF(pfpIdx,1),avHJF(pfpIdx,1+h),pointProps)
                end
                if ~isempty(peakIdx)
                    plot(saxH(4), avHJF(peakIdx,1),avHJF(peakIdx,1+4),pointProps,'MarkerFaceColor','m')
                end
            end
        elseif isempty(sFile) || length(sFile) > 1
            warning([activities{a,1} '_H' num2str(s) '.xlsx' ' is missing!'])
        end
    end
end

end