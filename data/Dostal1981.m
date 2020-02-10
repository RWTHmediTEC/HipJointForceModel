function varargout = Dostal1981(varargin)
% Reference:
% [Dostal 1981] 1981 - Dostal A three-dimensional biomechanical model of hip musculature
% All values in [cm]!

% Parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'visualization',false,logParValidFunc);
parse(p,varargin{:});
visu = p.Results.visualization;

% Segment names
HM(1).Name='Pelvis';
HM(2).Name='Femur';

% Joints
HM(1).Joints.Hip.Pos = [0 0 0];
HM(1).Joints.Hip.Parent = 0;
HM(2).Joints.Hip.Pos = [0 0 0];
HM(2).Joints.Hip.Parent = 1;

% Parent segment
HM(1).Parent=[];
HM(2).Parent=1;

%% Muscles
% Gluteus Medius Anterior
HM(1).Muscle.GluteusMediusAnterior1.Pos = [2.7 10.2 6.2]; % Origin
HM(2).Muscle.GluteusMediusAnterior1.Pos = [-1.8 -2.6 7.3]; % Insertion

% Gluteus Minimus Anterior
HM(1).Muscle.GluteusMinimusAnterior1.Pos = [2.9 7.3 4.1]; % Origin
HM(2).Muscle.GluteusMinimusAnterior1.Pos = [0.4 -2.7 6.9]; % Insertion

% Tensor Fasciae Latae
HM(1).Muscle.TensorFasciaeLatae1.Pos = [4.5 7.8 5.6]; % Origin
HM(2).Muscle.TensorFasciaeLatae1.Pos = [2.2 -43.6 3.3]; % Insertion

% Rectus Femoris
HM(1).Muscle.RectusFemoris1.Pos = [4.3 3.7 2.6]; % Origin
HM(2).Muscle.RectusFemoris1.Pos = [4.3 -41.5 0.2]; % Insertion

% Gluteus Medius Mid
% Origin
HM(1).Muscle.GluteusMediusMid1.Pos = [-0.2 13.2 1.8]; % Origin
HM(2).Muscle.GluteusMediusMid1.Pos = [-1.8 -2.6 7.3]; % Insertion

% Gluteus Minimus Mid
HM(1).Muscle.GluteusMinimusMid1.Pos = [-0.4 8.8 2.0]; % Origin
HM(2).Muscle.GluteusMinimusMid1.Pos = [0.4 -2.7 6.9]; % Insertion

% Gluteus Medius Posterior
HM(1).Muscle.GluteusMediusPosterior1.Pos = [-4.8 9.7 -1.5]; % Origin
HM(2).Muscle.GluteusMediusPosterior1.Pos = [-1.8 -2.6 7.3]; % Insertion

% Gluteus Minimus Posterior
HM(1).Muscle.GluteusMinimusPosterior1.Pos = [-2.6 7.1 0.0]; % Origin
HM(2).Muscle.GluteusMinimusPosterior1.Pos = [0.4 -2.7 6.9]; % Insertion

% Piriformis
HM(1).Muscle.Piriformis1.Pos = [-7.8 5.5 -4.7]; % Origin
HM(2).Muscle.Piriformis1.Pos = [-0.1 -0.1 5.5]; % Insertion

% Add types
HM(1).Muscle=structfun(@(x) setfield(x,'Type',{'Origin'}), HM(1).Muscle, 'uni',0);
HM(2).Muscle=structfun(@(x) setfield(x,'Type',{'Insertion'}), HM(2).Muscle, 'uni',0);

%% Landmarks
% Pelvis
HM(1).Landmarks.RightHipJointCenter.Pos=[0.0 0.0 0.0];
HM(1).Landmarks.LeftHipJointCenter.Pos=[0.3 -0.4 -16.9];
HM(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos=[5.9 8.3 5.1];
HM(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos=[5.9 8.3 -20.9];
HM(1).Landmarks.RightPubicTubercle.Pos=[5.9 -1.8 -4.9];
HM(1).Landmarks.LeftPubicTubercle.Pos=[5.7 -1.9 -10.6];
% Femur
HM(2).Landmarks.MedialEpicondyle.Pos=[0.1 -42.3 -4.4];
HM(2).Landmarks.LateralEpicondyle.Pos=[-0.2 -42.3 4.4];
HM(2).Landmarks.PosteriorMedialCondyle.Pos=[-2.8 -43.4 -2.8];
HM(2).Landmarks.PosteriorLateralCondyle.Pos=[-2.8 -43.4 2.9];

%% Transform from [cm] to [mm]
scaleTFM = repmat(10*eye(4), 1, 1, 2);
HM = transformTLEM2(HM, scaleTFM);

%% Scaling parameters
Scale(1).HipJointWidth = abs(...
    HM(1).Landmarks.RightHipJointCenter.Pos(3)-...
    HM(1).Landmarks.LeftHipJointCenter.Pos(3));
Scale(1).PelvicWidth  = abs(... % 28.6;
    HM(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(3)-...
    HM(1).Landmarks.LeftAnteriorSuperiorIliacSpine.Pos(3));
Scale(1).PelvicHeight = abs(... % mean([23.0 23.4]);
    HM(1).Landmarks.RightHipJointCenter.Pos(2)-...
    HM(1).Landmarks.RightAnteriorSuperiorIliacSpine.Pos(2));
Scale(2).FemoralLength = abs(HM(2).Landmarks.MedialEpicondyle.Pos(2));

varargout{1}=HM;
varargout{2}=Scale;
varargout{3}=NaN;

if visu
    % ColorMap
    cmap = hsv(length(fieldnames(HM(1).Muscle)));
    
    figH=figure('Color','w');
    axH=axes(figH);
    hold(axH,'on')
    lineProps.Marker = 'o';
    lineProps.MarkerSize = 5;
    lineProps.Color = 'k';
    lineProps.MarkerEdgeColor = lineProps.Color;
    lineProps.MarkerFaceColor = lineProps.Color;
    drawPoint3d(axH,HM(1).Landmarks.RightHipJointCenter.Pos,lineProps)
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
                mPoints = [Origin; Insertion];
                lineProps.DisplayName = Muscles{m};
                lineProps.Color = cmap(m,:);
                lineProps.MarkerEdgeColor = lineProps.Color;
                lineProps.MarkerFaceColor = lineProps.Color;
                drawPoint3d(axH, mPoints, lineProps);
                drawLabels3d(axH, mPoints, [Muscles{m}([1,end]);Muscles{m}([1,end])], lineProps);
        end
    end
    axis(axH, 'equal', 'tight'); 
    grid(axH, 'minor');
    xlabel(axH, 'X'); ylabel(axH, 'Y'); zlabel(axH, 'Z');
    title('Data from [Dostal 1981] as presented in [Iglic 1990, S.37, Table 2]')
    medicalViewButtons(axH,'ASR')
    varargout{4}=axH;
end

end