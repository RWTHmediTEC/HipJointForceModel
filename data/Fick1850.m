function [HM, muscleList, Moments] = Fick1850(varargin)
% Reference:
% [Fick 1850] 1850 - Fick - Statische Betrachtung der Muskulatur des Oberschenkels

% Parsing
p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'visualization',true,logParValidFunc);
parse(p,varargin{:});
visu = p.Results.visualization;

% Segment names
HM(1).Name='Pelvis';
HM(2).Name='Femur';

% Joints
HJC = [76 40 119]; % [Fick 1850, S.105]
HM(1).Joints.Hip.Pos = HJC; 
HM(1).Joints.Hip.Parent = 0;
HM(2).Joints.Hip.Pos = HJC; 
HM(2).Joints.Hip.Parent = 1;

% Parent segment
HM(1).Parent=[];
HM(2).Parent=1;

% [Fick 1850, S.103-104]
Moments.GluteusMaximus           = [-157.612 -66.596  78.240];
% Moment.Piriformis             = [  -3.332  15.138  15.885]; % Attachment points are missing in [Fick 1850]
Moments.ObturatorEtGemelli       = [   2.821  -7.622  18.835];
Moments.QuadratusFemoris         = [   0.342 -26.209  25.157];
Moments.Semitendinosus           = [ -20.849  -8.420  -1.559];
Moments.BicepsFemorisCaputLongum = [ -32.692  -9.950   0.857];
Moments.Semimembranosus          = [ -20.462  -7.307  -1.251];
Moments.AdductorMagnusProximal   = [   3.978 -17.505   2.089];
Moments.AdductorMagnusDistal     = [ -42.721 -67.133  -1.434];
Moments.PsoasEtIliacus           = [  76.587   0.000 -12.236];
Moments.AdductorPectineus        = [  11.601 -10.569   1.939];
Moments.AdductorBrevis           = [  26.479 -42.213   2.185];
Moments.AdductorLongus           = [  33.697 -40.557  -1.880];
Moments.Gracilis                 = [   3.946 -17.631   0.032];
Moments.Sartorius                = [  11.210   4.003   0.676];
Moments.TensorFasciae            = [  12.495   7.605   0.001];
Moments.RectusFemoris            = [  46.182  14.813   2.958];
Moments.GluteusMedius            = [  -9.928 114.177 -17.612];
Moments.GluteusMinimus           = [   7.855  53.864 -15.817];
Moments.ObturatorExternus        = [  16.758 -25.138   0.126];

% [Fick 1850, S.105-106]
% Tensor Fasciae
HM(1).Muscle.TensorFasciae1.Pos = [24 -18 80]; % Origin
HM(1).Muscle.TensorFasciae2.Pos = [28  10 96]; % Origin
HM(2).Muscle.TensorFasciae1.Pos = [64 449 103]; % Insertion
HM(2).Muscle.TensorFasciae2.Pos = [55 447 110]; % Insertion

% Biceps Femoris Caput Longum (Langer Kopf)
HM(1).Muscle.BicepsFemorisCaputLongum1.Pos = [119 65 130]; % Origin
HM(1).Muscle.BicepsFemorisCaputLongum2.Pos = [119 65 130]; % Origin
HM(2).Muscle.BicepsFemorisCaputLongum1.Pos = [93 459 102]; % Insertion
HM(2).Muscle.BicepsFemorisCaputLongum2.Pos = [72 461 106]; % Insertion

% Gluteus Maximus
HM(1).Muscle.GluteusMaximus1.Pos = [142 -60 151]; % Origin
HM(1).Muscle.GluteusMaximus2.Pos = [117  12 190]; % Origin
HM(1).Muscle.GluteusMaximus3.Pos = [149  64 200]; % Origin
HM(2).Muscle.GluteusMaximus1.Pos = [111  48  82]; % Insertion
HM(2).Muscle.GluteusMaximus2.Pos = [ 81 170  87]; % Insertion
HM(2).Muscle.GluteusMaximus3.Pos = [ 81 170  87]; % Insertion

% Semitendinosus
HM(1).Muscle.Semitendinosus1.Pos = [119 65 130]; % Origin
HM(1).Muscle.Semitendinosus2.Pos = [119 65 130]; % Origin
HM(2).Muscle.Semitendinosus1.Pos = [66 467 146]; % Insertion
HM(2).Muscle.Semitendinosus2.Pos = [70 514 150]; % Insertion

% Semimembranosus
HM(1).Muscle.Semimembranosus1.Pos = [104  60 124]; % Origin
HM(1).Muscle.Semimembranosus2.Pos = [104 102 140]; % Origin
HM(2).Muscle.Semimembranosus1.Pos = [ 95 440 143]; % Insertion
HM(2).Muscle.Semimembranosus2.Pos = [ 83 440 165]; % Insertion

% Sartorius
HM(1).Muscle.Sartorius1.Pos = [16  0  90]; % Origin
HM(1).Muscle.Sartorius2.Pos = [16  0 100]; % Origin
HM(2).Muscle.Sartorius1.Pos = [66 467 146]; % Insertion
HM(2).Muscle.Sartorius2.Pos = [64 450 144]; % Insertion

% Rectus Femoris
HM(1).Muscle.RectusFemoris1.Pos = [16 12 103]; % Origin
HM(1).Muscle.RectusFemoris2.Pos = [31 33  99]; % Origin
HM(2).Muscle.RectusFemoris1.Pos = [24 396 113]; % Insertion
HM(2).Muscle.RectusFemoris2.Pos = [20 396 153]; % Insertion

% Adductor Longus
HM(1).Muscle.AdductorLongus1.Pos = [34 64 170]; % Origin
HM(1).Muscle.AdductorLongus2.Pos = [36 40 190]; % Origin
HM(2).Muscle.AdductorLongus1.Pos = [78 200 106]; % Insertion
HM(2).Muscle.AdductorLongus2.Pos = [62 276 123]; % Insertion

% Adductor Brevis
HM(1).Muscle.AdductorBrevis1.Pos = [36 40 190]; % Origin
HM(1).Muscle.AdductorBrevis2.Pos = [62 91 182]; % Origin
HM(2).Muscle.AdductorBrevis1.Pos = [78 200 106]; % Insertion
HM(2).Muscle.AdductorBrevis2.Pos = [93 115  93]; % Insertion

% Gracilis
HM(1).Muscle.Gracilis1.Pos = [40 80 198]; % Origin
HM(1).Muscle.Gracilis2.Pos = [74 98 182]; % Origin
HM(2).Muscle.Gracilis1.Pos = [66 467 146]; % Insertion
HM(2).Muscle.Gracilis2.Pos = [66 467 146]; % Insertion

% Adductor Pectineus
HM(1).Muscle.AdductorPectineus1.Pos = [36 40 190]; % Origin
HM(1).Muscle.AdductorPectineus2.Pos = [62 91 182]; % Origin
HM(2).Muscle.AdductorPectineus1.Pos = [78 200 106]; % Insertion
HM(2).Muscle.AdductorPectineus2.Pos = [93 115  93]; % Insertion

% Psoas Et Iliacus
HM(1).Muscle.PsoasEtIliacus1.Pos = [16   0 100]; % Origin
HM(1).Muscle.PsoasEtIliacus2.Pos = [49  37 140]; % Origin
HM(2).Muscle.PsoasEtIliacus1.Pos = [80 121 104]; % Insertion
HM(2).Muscle.PsoasEtIliacus2.Pos = [94 106 114]; % Insertion

% Adductor Magnus Proximal (Vordere / Obere Parthie)
HM(1).Muscle.AdductorMagnusProximal1.Pos = [ 62  91 182]; % Origin
HM(1).Muscle.AdductorMagnusProximal2.Pos = [ 86  88 160]; % Origin
HM(2).Muscle.AdductorMagnusProximal1.Pos = [ 82 169  98]; % Insertion
HM(2).Muscle.AdductorMagnusProximal2.Pos = [100  99  97]; % Insertion

% Adductor Magnus Distal (Hintere / Untere Parthie)
HM(1).Muscle.AdductorMagnusDistal1.Pos = [ 86  88 160]; % Origin
HM(1).Muscle.AdductorMagnusDistal2.Pos = [114  93 142]; % Origin
HM(2).Muscle.AdductorMagnusDistal1.Pos = [ 76 398 174]; % Insertion
HM(2).Muscle.AdductorMagnusDistal2.Pos = [ 82 169  98]; % Insertion

% Quadratus Femoris
HM(1).Muscle.QuadratusFemoris1.Pos = [100 64 130]; % Origin
HM(1).Muscle.QuadratusFemoris2.Pos = [ 96 88 150]; % Origin
HM(2).Muscle.QuadratusFemoris1.Pos = [104 67  89]; % Insertion
HM(2).Muscle.QuadratusFemoris2.Pos = [104 99  86]; % Insertion

% Obturator Et Gemelli
HM(1).Muscle.ObturatorEtGemelli1.Pos = [112 45 153]; % Origin
HM(1).Muscle.ObturatorEtGemelli2.Pos = [128 70 142]; % Origin
HM(2).Muscle.ObturatorEtGemelli1.Pos = [ 93 45  86]; % Insertion
HM(2).Muscle.ObturatorEtGemelli2.Pos = [ 93 53  86]; % Insertion

% Gluteus Medius
HM(1).Muscle.GluteusMedius1.Pos = [136 -30 140]; % Origin
HM(1).Muscle.GluteusMedius2.Pos = [136 -60 147]; % Origin
HM(1).Muscle.GluteusMedius3.Pos = [108 -84 125]; % Origin
HM(1).Muscle.GluteusMedius4.Pos = [ 28  10  96]; % Origin
HM(2).Muscle.GluteusMedius1.Pos = [107 40 84]; % Insertion
HM(2).Muscle.GluteusMedius2.Pos = [107 40 84]; % Insertion
HM(2).Muscle.GluteusMedius3.Pos = [ 72 70 60]; % Insertion
HM(2).Muscle.GluteusMedius4.Pos = [ 72 70 60]; % Insertion

% Gluteus Minimus
HM(1).Muscle.GluteusMinimus1.Pos = [100  10 135]; % Origin
HM(1).Muscle.GluteusMinimus2.Pos = [100   0 135]; % Origin
HM(1).Muscle.GluteusMinimus3.Pos = [ 78 -42 102]; % Origin
HM(1).Muscle.GluteusMinimus4.Pos = [ 28  10  96]; % Origin
HM(2).Muscle.GluteusMinimus1.Pos = [ 72 70 60]; % Insertion
HM(2).Muscle.GluteusMinimus2.Pos = [ 77 48 62]; % Insertion
HM(2).Muscle.GluteusMinimus3.Pos = [ 77 48 62]; % Insertion
HM(2).Muscle.GluteusMinimus4.Pos = [ 72 70 60]; % Insertion

% Obturator Externus
HM(1).Muscle.ObturatorExternus1.Pos = [96 38 150]; % Origin
HM(1).Muscle.ObturatorExternus2.Pos = [34 75 190]; % Origin
HM(1).Muscle.ObturatorExternus3.Pos = [76 84 155]; % Origin
HM(2).Muscle.ObturatorExternus1.Pos = [94 67  85]; % Insertion
HM(2).Muscle.ObturatorExternus2.Pos = [94 67  85]; % Insertion
HM(2).Muscle.ObturatorExternus3.Pos = [94 67  85]; % Insertion

% Add types
HM(1).Muscle=structfun(@(x) setfield(x,'Type',{'Origin'}), HM(1).Muscle, 'uni',0);
HM(2).Muscle=structfun(@(x) setfield(x,'Type',{'Insertion'}), HM(2).Muscle, 'uni',0);


%% Derivation of muscle cross sections volumes from moments
muscleList = fieldnames(Moments);
NoM = size(muscleList,1);
% A random color for each muscle
muscleList(:,2) = mat2cell(round(rand(NoM,3),4),ones(NoM,1));
% The connected bones: pelvis (1), femur (2)
muscleList(:,3) = {[1 2]};
% Number of fascicles 
muscleList(:,4) = cellfun(@(x) sum(contains(fieldnames(HM(1).Muscle), x)), muscleList(:,1),'uni',0);

transPlane = [HJC 1 0 0 0 0 1];
LinesOfAction = nan(NoM,6);
lineProps.MarkerSize = 6;
for m = 1:NoM
    % [Fick 1850, S.99]
    LinesOfAction(m,:) = reconstructLineOfActionFick1850(HM, muscleList{m,1});
    % [Fick 1850, S.102]
    LinesOfAction(m,1:3) = intersectLinePlane(LinesOfAction(m,:),transPlane);
    % [Fick 1850, S.102]
    cosP(1)=cos(vectorAngle3d(LinesOfAction(m,4:6),[1 0 0]));
    cosP(2)=cos(vectorAngle3d(LinesOfAction(m,4:6),[0 1 0]));
    cosP(3)=cos(vectorAngle3d(LinesOfAction(m,4:6),[0 0 1]));
    % [Fick 1850, S.102]
    MomentArm = abs(LinesOfAction(m,1:3)-HJC);
    % [Fick 1850, S.103]
    Flexion   = cosP(2)*MomentArm(1) + cosP(1)*MomentArm(2);
    Adduction = cosP(2)*MomentArm(3) + cosP(3)*MomentArm(2);
    Rotation  = cosP(1)*MomentArm(3) + cosP(3)*MomentArm(1);
    % Actually the three absolute values of CrossSectionVolumes should
    % be quite similiar. However, the rotational component is different 
    % compared to the flexion and adduction component in most of the cases.
    % As workaround, let's take the mean of the absolute values of the
    % flexion and adduction component:
    CrossSectionVolumes(1) = Moments.(muscleList{m,1})(1)/Flexion;
    CrossSectionVolumes(2) = Moments.(muscleList{m,1})(2)/Adduction;
    CrossSectionVolumes(3) = Moments.(muscleList{m,1})(3)/Rotation;
    if ~any(abs(CrossSectionVolumes(1:2)) < 0.01)
        muscleList{m,5} = mean(abs(CrossSectionVolumes(1:2)));
    else
        muscleList{m,5} = sum(abs(CrossSectionVolumes(1:2)));
    end
end
% Normalize cross sections by the Gluteus Maximus
muscleList(:,5) = cellfun(@(x) ...
    x/muscleList{strcmp('GluteusMaximus', muscleList(:,1)),5}, ...
    muscleList(:,5),'uni',0);
% The muscle model: Straight Line (S)
muscleList(:,6) = {'S'};

if visu
    figName = '[Fick 1850]';
    figH=figure('Name',figName, 'NumberTitle','off', 'Color','w');
    axH=axes(figH);
    hold(axH,'on')
    lineProps.Marker = 'o';
    lineProps.MarkerSize = 10;
    lineProps.Color = 'k';
    lineProps.MarkerEdgeColor = 'none';
    lineProps.MarkerFaceColor = lineProps.Color;
    
    drawPoint3d(axH,HJC,lineProps)
    
    Fascicles = fieldnames(HM(1).Muscle);
    lineProps.MarkerSize = 2;
    for m = 1:length(Fascicles)
        Origin = HM(1).Muscle.(Fascicles{m}).Pos;
        Insertion = HM(2).Muscle.(Fascicles{m}).Pos;
        lineProps.DisplayName = Fascicles{m};
        colorIdx = strcmp(Fascicles{m}(1:end-1), muscleList(:,1));
        lineProps.Color = muscleList{colorIdx,2};
        lineProps.MarkerEdgeColor = lineProps.Color;
        lineProps.MarkerFaceColor = lineProps.Color;
        drawEdge3d(axH, Origin, Insertion, lineProps);
        drawLabels3d(axH, midPoint3d(Origin, Insertion), Fascicles{m}([1,end]), lineProps);
    end
    
    lineProps.MarkerSize = 6;
    for m = 1:NoM
        drawVector3d(axH, LinesOfAction(m,1:3),LinesOfAction(m,4:6)*50, ...
            'Color', 'k', 'LineWidth', 1, 'LineStyle', '-.')
        drawPoint3d(axH,LinesOfAction(m,1:3),...
            lineProps, 'MarkerFaceColor',muscleList{m,2},'MarkerEdgeColor',muscleList{m,2})
    end
    
    drawPlane3d(axH,transPlane,'FaceAlpha',0.1)
    
    axis(axH, 'equal', 'tight'); 
    grid(axH, 'minor');
    xlabel(axH, 'X'); ylabel(axH, 'Y'); zlabel(axH, 'Z');
    title(axH,figName)
    anatomicalViewButtons(axH,'PIR')
end

end

function muscleLA = reconstructLineOfActionFick1850(HM, muscle, varargin)
% [Fick 1850, S.99]

p = inputParser;
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p,'visualization', 0, logParValidFunc);
parse(p,varargin{:});
visu = p.Results.visualization;

if visu
    figure('Name',muscle,'NumberTitle','off','Color','w')
    fpPanelHandle = uipanel(...
        'Title','Frontal Plane',...
        'BackgroundColor','w',...
        'Position',[0 0 .5 1]);
    pAxH(1) = axes(fpPanelHandle);
    hold(pAxH(1),'on')
    spPanelHandle = uipanel(...
        'Title','Sagittal Plane',...
        'BackgroundColor','w',...
        'Position',[0.5 0 .5 1]);
    pAxH(2) = axes(spPanelHandle);
    hold(pAxH(2),'on')
end

fascicles = fieldnames(HM(1).Muscle);
fascicles(~contains(fascicles,muscle))=[];

AP_pelvis = unique(cell2mat(cellfun(@(x) HM(1).Muscle.(x).Pos, fascicles, 'uni',0)), 'rows');
AP_femur  = unique(cell2mat(cellfun(@(x) HM(2).Muscle.(x).Pos, fascicles, 'uni',0)), 'rows');

if visu
    pointProps.Marker = 'o';
    pointProps.MarkerSize = 4;
    pointProps.Color = 'none';
    pointProps.MarkerEdgeColor = 'r';
    pointProps.MarkerFaceColor = 'r';
    drawPoint3d(pAxH(1),AP_pelvis,pointProps)
    drawPoint3d(pAxH(2),AP_pelvis,pointProps)
    pointProps.MarkerEdgeColor = 'g';
    pointProps.MarkerFaceColor = 'g';
    drawPoint3d(pAxH(1),AP_femur,pointProps)
    drawPoint3d(pAxH(2),AP_femur,pointProps)
end

% Projection of attachment points on frontal and sagittal plane
pIdx(1,:) = [2,3]; % Frontal plane
pIdx(2,:) = [1,2]; % Sagittal plane
midFibers3d = zeros(2,6);
for p=1:size(pIdx,2)
    [midFiber, pHull, boundFibers] = getBoundaryFibers(AP_pelvis(:,pIdx(p,:)), AP_femur(:,pIdx(p,:)));
    midFibers3d(p,pIdx(p,:)) = midFiber(:,1:2); midFibers3d(p,pIdx(p,:)+3) = midFiber(:,3:4);
    cHull3d = zeros(size(pHull,1),3); cHull3d(:,pIdx(p,:)) = pHull;
    boundFibers3d = zeros(size(boundFibers,1),6);
    boundFibers3d(:,pIdx(p,:)) = boundFibers(:,1:2); boundFibers3d(:,pIdx(p,:)+3) = boundFibers(:,3:4);
    if visu
        % drawVector3d(pAxH(1), pHull3d(1:end-1,:),diff(pHull3d),'k');
        drawLabels3d(pAxH(p),cHull3d,split(num2str(1:size(pHull,1))))
        drawEdge3d(pAxH(p), midFibers3d(p,:),'k');
        drawVector3d(pAxH(p), boundFibers3d(:,1:3), boundFibers3d(:,4:6),'-.k');
    end
end

if visu
    mouseControl3d(pAxH(1),[ 0  0  1 0;-1  0  0 0; 0 -1  0 0; 0 0 0 1])
    mouseControl3d(pAxH(2),[-1  0  0 0; 0  0 -1 0; 0 -1  0 0; 0 0 0 1])
end

% It is unclear from [Fick 1850] how to reconstruct the 3d line of action 
% from the two 2d projections of the reconstructed midline in the frontal 
% and sagittal plane.
% As workaround, let's take the mean of the y-component:
midFibers3d(1,[1,1+3])=nan;
midFibers3d(2,[3,3+3])=nan;
midFiber3d = nanmean(midFibers3d);

muscleLA = createLine3d(midFiber3d(1:3), midFiber3d(4:6));
% All lines have to point away from the pelvis
if muscleLA(5)<0
    muscleLA = createLine3d(midFiber3d(4:6), midFiber3d(1:3));
end
assert(muscleLA(5)>=0)

muscleLA(:,4:6) = normalizeVector3d(muscleLA(:,4:6));

end

function [muscleMidEdge, newhull, boundFiberLines] = getBoundaryFibers(AP_pelvis, AP_femur)

hull = unique(convexHull([AP_pelvis;AP_femur]),'rows','stable');

startIdx = find(ismember(hull,AP_femur,'rows'));
if startIdx(1)~=1
    newhull = hull([startIdx(1):end, 1:startIdx(1)-1],:);
else
    newhull = hull;
end
femurIdx = ismember(newhull,AP_femur,'rows');
pelvisIdx = ismember(newhull,AP_pelvis,'rows');

boundFibers(1,:) = [newhull(end,:) newhull(1,:)];
boundFibers(2,:) = [newhull(length(startIdx)+1,:) newhull(length(startIdx),:)];

boundFiberLines(1,:) = createLine(boundFibers(1,1:2), boundFibers(1,3:4));
boundFiberLines(2,:) = createLine(boundFibers(2,1:2), boundFibers(2,3:4));

muscleMidline = bisector(boundFiberLines(1,:),boundFiberLines(2,:));

if sum(femurIdx)==1
    muscleMidFemur = newhull(femurIdx,:);
else
    muscleMidFemur = uniquetol(intersectLinePolyline(muscleMidline, newhull(femurIdx,:)),'ByRows',1);
    assert(size(muscleMidFemur,1)==1)
end
if sum(pelvisIdx)==1
    muscleMidPelvis = newhull(pelvisIdx,:);
else
    muscleMidPelvis = uniquetol(intersectLinePolyline(muscleMidline, newhull(pelvisIdx,:)),'ByRows',1);
    assert(size(muscleMidPelvis,1)==1)
end
muscleMidEdge = [muscleMidPelvis, muscleMidFemur];

end