function varargout = Fick1850(varargin)

% Parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'visualization',true,logParValidFunc);
parse(p,varargin{:});
visu = p.Results.visualization;

% Values from:
% [Fick 1850] 1850 - Fick - Statische Betrachtung der Muskulatur des Oberschenkels

% [Fick 1850, S.103-104]
Moment.TensorFasciae=[12.495  7.605 0.001];
Moment.Sartorius=[11.210 4.003 0.676];
Moment.RectusFemoris=[46.182 14.813 2.958];
Moment.GluteusMedius=[-9.928 114.177 -17.612];
Moment.GluteusMinimus=[7.855 53.864 -15.817];

% [Fick 1850, S.105]
HJC = [76 40 119];

% [Fick 1850, S.105-106]
% Tensor Fasciae
% Origin
HM(1).Muscle.TensorFasciae1.Type={'Origin'};
HM(1).Muscle.TensorFasciae1.Pos = [24 -18 80];
HM(1).Muscle.TensorFasciae2.Type={'Origin'};
HM(1).Muscle.TensorFasciae2.Pos = [28  10 96];
% Insertion
HM(2).Muscle.TensorFasciae1.Type={'Insertion'};
HM(2).Muscle.TensorFasciae1.Pos = [64 449 103];
HM(2).Muscle.TensorFasciae2.Type={'Insertion'};
HM(2).Muscle.TensorFasciae2.Pos = [55 447 110];

% Sartorius
% Origin
HM(1).Muscle.Sartorius1.Type={'Origin'};
HM(1).Muscle.Sartorius1.Pos = [16  0  90];
HM(1).Muscle.Sartorius2.Type={'Origin'};
HM(1).Muscle.Sartorius2.Pos = [16  0 100];
% Insertion
HM(2).Muscle.Sartorius1.Type={'Insertion'};
HM(2).Muscle.Sartorius1.Pos = [66 467 146];
HM(2).Muscle.Sartorius2.Type={'Insertion'};
HM(2).Muscle.Sartorius2.Pos = [64 450 144];

% % Adductor Longus
% % Origin
% LE(1).Muscle.AdductorLongus1.Type={'Origin'};
% LE(1).Muscle.AdductorLongus1.Pos = [34 64 170];
% LE(1).Muscle.AdductorLongus2.Type={'Origin'};
% LE(1).Muscle.AdductorLongus2.Pos = [36 40 190];
% % Insertion
% LE(2).Muscle.AdductorLongus1.Type={'Insertion'};
% LE(2).Muscle.AdductorLongus1.Pos = [78 200 106];
% LE(2).Muscle.AdductorLongus2.Type={'Insertion'};
% LE(2).Muscle.AdductorLongus2.Pos = [62 276 123];
% 
% % Adductor Brevis
% % Origin
% LE(1).Muscle.AdductorBrevis1.Type={'Origin'};
% LE(1).Muscle.AdductorBrevis1.Pos = [36 40 190];
% LE(1).Muscle.AdductorBrevis2.Type={'Origin'};
% LE(1).Muscle.AdductorBrevis2.Pos = [62 91 182];
% % Insertion
% LE(2).Muscle.AdductorBrevis1.Type={'Insertion'};
% LE(2).Muscle.AdductorBrevis1.Pos = [78 200 106];
% LE(2).Muscle.AdductorBrevis2.Type={'Insertion'};
% LE(2).Muscle.AdductorBrevis2.Pos = [93 115  93];
% 
% % Adductor Pectineus
% % Origin
% LE(1).Muscle.AdductorPectineus1.Type={'Origin'};
% LE(1).Muscle.AdductorPectineus1.Pos = [36 40 190];
% LE(1).Muscle.AdductorPectineus2.Type={'Origin'};
% LE(1).Muscle.AdductorPectineus2.Pos = [62 91 182];
% % Insertion
% LE(2).Muscle.AdductorPectineus1.Type={'Insertion'};
% LE(2).Muscle.AdductorPectineus1.Pos = [78 200 106];
% LE(2).Muscle.AdductorPectineus2.Type={'Insertion'};
% LE(2).Muscle.AdductorPectineus2.Pos = [93 115  93];

% Rectus Femoris
% Origin
HM(1).Muscle.RectusFemoris1.Type={'Origin'};
HM(1).Muscle.RectusFemoris1.Pos = [16 12 103];
HM(1).Muscle.RectusFemoris2.Type={'Origin'};
HM(1).Muscle.RectusFemoris2.Pos = [31 33 99];
% Insertion
HM(2).Muscle.RectusFemoris1.Type={'Insertion'};
HM(2).Muscle.RectusFemoris1.Pos = [24 396 113];
HM(2).Muscle.RectusFemoris2.Type={'Insertion'};
HM(2).Muscle.RectusFemoris2.Pos = [20 396 153];

% Gluteus Medius
% Origin
HM(1).Muscle.GluteusMedius1.Type={'Origin'};
HM(1).Muscle.GluteusMedius1.Pos = [136 -30 140];
HM(1).Muscle.GluteusMedius2.Type={'Origin'};
HM(1).Muscle.GluteusMedius2.Pos = [136 -60 147];
HM(1).Muscle.GluteusMedius3.Type={'Origin'};
HM(1).Muscle.GluteusMedius3.Pos = [108 -84 125];
HM(1).Muscle.GluteusMedius4.Type={'Origin'};
HM(1).Muscle.GluteusMedius4.Pos = [ 28  10  96];
% Insertion
HM(2).Muscle.GluteusMedius1.Type={'Insertion'};
HM(2).Muscle.GluteusMedius1.Pos = [107 40 84];
HM(2).Muscle.GluteusMedius2.Type={'Insertion'};
HM(2).Muscle.GluteusMedius2.Pos = [107 40 84];
HM(2).Muscle.GluteusMedius3.Type={'Insertion'};
HM(2).Muscle.GluteusMedius3.Pos = [ 72 70 60];
HM(2).Muscle.GluteusMedius4.Type={'Insertion'};
HM(2).Muscle.GluteusMedius4.Pos = [ 72 70 60];

% Gluteus Minimus
% Origin
HM(1).Muscle.GluteusMinimus1.Type={'Origin'};
HM(1).Muscle.GluteusMinimus1.Pos = [100 10 135];
HM(1).Muscle.GluteusMinimus2.Type={'Origin'};
HM(1).Muscle.GluteusMinimus2.Pos = [100  0 135];
HM(1).Muscle.GluteusMinimus3.Type={'Origin'};
HM(1).Muscle.GluteusMinimus3.Pos = [ 78 -42 102];
HM(1).Muscle.GluteusMinimus4.Type={'Origin'};
HM(1).Muscle.GluteusMinimus4.Pos = [ 28  10  96];
% Insertion
HM(2).Muscle.GluteusMinimus1.Type={'Insertion'};
HM(2).Muscle.GluteusMinimus1.Pos = [ 72 70 60];
HM(2).Muscle.GluteusMinimus2.Type={'Insertion'};
HM(2).Muscle.GluteusMinimus2.Pos = [ 77 48 62];
HM(2).Muscle.GluteusMinimus3.Type={'Insertion'};
HM(2).Muscle.GluteusMinimus3.Pos = [ 77 48 62];
HM(2).Muscle.GluteusMinimus4.Type={'Insertion'};
HM(2).Muscle.GluteusMinimus4.Pos = [ 72 70 60];

varargout{1}=Moment;
varargout{2}=HJC;
varargout{3}=HM;

if visu
    % ColorMap
    muscleList = fieldnames(Moment);
    cmap = hsv(length(fieldnames(Moment)));
    
    TFM=[[1 0 0; 0 1 0; 0 0 1] -[0 0 0]'; 0 0 0 1];
    
    figH=figure('Color','w');
    axH=axes(figH);
    hold(axH,'on')
    lineProps.Marker = 'o';
    lineProps.MarkerSize = 5;
    lineProps.Color = 'k';
    lineProps.MarkerEdgeColor = lineProps.Color;
    lineProps.MarkerFaceColor = lineProps.Color;
    drawPoint3d(axH,transformPoint3d(HJC,TFM),lineProps)
    lineProps.MarkerSize = 2;

    % Loop over bones with muscles
    BwM = find(~arrayfun(@(x) isempty(x.Muscle), HM));
    for b = BwM
        Muscles = fieldnames(HM(b).Muscle);
        % Loop over the muscles of the bone
        for m = 1:length(Muscles)
            % Check if the muscle originates from this bone
            oIdx = strcmp(HM(b).Muscle.(Muscles{m}).Type, 'Origin');
                Origin = HM(b).Muscle.(Muscles{m}).Pos(oIdx,:);
                % Loop over the other bones exept the bone of Origin
                for bb = BwM(BwM~=b)
                    matchingMuscle = fieldnames(HM(bb).Muscle);
                    if any(strcmp(Muscles(m), matchingMuscle))
                        % Check if it is the bone of insertion
                        iIdx = strcmp(HM(bb).Muscle.(Muscles{m}).Type, 'Insertion');
                        if any(iIdx)
                            Insertion = HM(bb).Muscle.(Muscles{m}).Pos(iIdx,:);
                        end
                    end
                end
                
                % Combine Origin, Via points & Insertion
                mPoints = transformPoint3d([Origin; Insertion],TFM);
                lineProps.DisplayName = Muscles{m};
                colorIdx = strcmp(Muscles{m}(1:end-1), muscleList(:,1));
                lineProps.Color = cmap(colorIdx,:);
                lineProps.MarkerEdgeColor = lineProps.Color;
                lineProps.MarkerFaceColor = lineProps.Color;
                drawPoint3d(axH, mPoints, lineProps);
                drawLabels3d(axH, mPoints, [Muscles{m}([1,end]);Muscles{m}([1,end])], lineProps);
        end
    end
    axis(axH, 'equal', 'tight'); 
    grid(axH, 'minor');
    xlabel(axH, 'X'); ylabel(axH, 'Y'); zlabel(axH, 'Z');
    medicalViewButtons(axH,'PIR')
    varargout{4}=axH;
end

end