function visualizeLEM(axH, LE, side, varargin)

%% Input parsing
p = inputParser;
valFctBones = @(x) validateattributes(x, {'numeric'}, {'>=',1, '<=',length(LE)});
logParValidFunc=@(x) (islogical(x) || isequal(x,1) || isequal(x,0));
addParameter(p, 'Bones', length(LE), valFctBones);
addParameter(p, 'Joints', false, @islogical);
addParameter(p, 'Muscles', {}, @(x) isstruct(x) || isempty(x));
addParameter(p, 'MuscleList', {}, @iscell);
addParameter(p, 'MusclePathModel', false);
addParameter(p, 'Surfaces', false, logParValidFunc);
addParameter(p, 'Landmarks', false, logParValidFunc);
parse(p, varargin{:});

NoB = p.Results.Bones;
visJoints       = p.Results.Joints;
Muscles         = p.Results.Muscles;
MuscleList      = p.Results.MuscleList;
MusclePathModel = p.Results.MusclePathModel;
visSurfaces     = p.Results.Surfaces;
visLandmarks    = p.Results.Landmarks;

%% Visualization of the model
hold(axH,'on')
patchProps.EdgeColor    = 'none';
patchProps.FaceColor    = [0.95 0.91 0.8];
patchProps.FaceAlpha    = 1;
patchProps.EdgeLighting = 'gouraud';
patchProps.FaceLighting = 'gouraud';

%% Visualize bones
% NoB == 1 || NoB == 2 draws bone only pelvis (1) or femur (2). Transform 
% bone back into its local bone CS (-> neutral postion). Used for Frontal, 
% Sagittal and Transversal View in the Results panel.
if isfield(LE,'Mesh')
    if NoB == 1 || NoB == 2
        localBone = transformPoint3d(LE(NoB).Mesh, LE(NoB).positionTFM');
    end
end

%% TFM for right or left side
TFM2GUI = eye(4);
switch side
    case 'R'
    case 'L'
        TFM2GUI(3,3) = -1;
    otherwise
        error('Invalid side variable!')
end
LE = transformLEM(LE, repmat(TFM2GUI, 1, 1, length(LE)));

%% Visualize bones
if isfield(LE,'Mesh')
    if NoB == 1 || NoB == 2
        patch(axH, transformPoint3d(localBone, TFM2GUI), patchProps);
    else
        % Draws all the bones. Used for Visualization panel
        for n = 1:NoB
            patch(axH, LE(n).Mesh, patchProps);
        end
    end
end

% Lighting of the bones
H_Light(1) = light(axH);
light(axH, 'Position', -1*(get(H_Light(1),'Position')));

%% Visualize joint axes
if visJoints
    pointProps.Marker          = 'o';
    pointProps.MarkerSize      = 5;
    pointProps.LineStyle       = 'none';
    pointProps.MarkerEdgeColor = 'k';
    pointProps.MarkerFaceColor = 'k';
    for b = 2:length(LE)
        % Get joints of the bone
        joints = fieldnames(LE(b).Joints);
        for j = 1:length(joints)
            if isfield(LE(b).Joints.(joints{j}), 'Axis')
                jCenter = LE(b).Joints.(joints{j}).Pos;
                jAxis = LE(b).Joints.(joints{j}).Axis;
                % Draw joint center
                drawPoint3d(axH, jCenter, pointProps);
                jAxisOrigin = jCenter - 60 * jAxis;
                jAxisEnd = jAxisOrigin + 120 * jAxis;
                text(axH, jAxisEnd(1), jAxisEnd(2), jAxisEnd(3), joints{j});
                drawArrow3d(axH, jAxisOrigin, 120 * jAxis, 'g');
            end
        end
    end
end

%% Visualize muscles
if ~isempty(Muscles)
    lineProps.Marker = 'o';
    lineProps.Linestyle = '-';
    lineProps.MarkerSize = 1;
    for m = 1:length(Muscles)
        lineProps.DisplayName = Muscles(m).Name;
        for c = 1:size(MuscleList,1)
            if isequal(Muscles(m).Name(1:end-1),MuscleList{c,1})
                lineProps.Color = MuscleList{c,2};
            end
        end
        lineProps.MarkerEdgeColor = lineProps.Color;
        lineProps.MarkerFaceColor = lineProps.Color;
        if isempty(Muscles(m).Surface)
            switch MusclePathModel
                case 'StraightLine'
                    drawPoint3d(axH, ...
                        transformPoint3d(Muscles(m).Points([1,end],:), TFM2GUI), lineProps);
                case {'ViaPoint', 'Wrapping'}
                    drawPoint3d(axH, ...
                        transformPoint3d(Muscles(m).Points, TFM2GUI), lineProps);
            end
        else
            drawPoint3d(axH, transformPoint3d(Muscles(m).Points, TFM2GUI), lineProps);
        end
        % Draw vectors for the lines of action
        if MusclePathModel
            drawArrow3d(axH, ...
                transformPoint3d(Muscles(m).(MusclePathModel)(1:3), TFM2GUI),...
                transformVector3d(Muscles(m).(MusclePathModel)(4:6)*25, TFM2GUI));
        end
    end
end

%% Visualize wrapping cylinders
if visSurfaces
    if isfield(LE,'Surface')
        for b = 1:length(LE)
            if ~isempty(LE(b).Surface)
                surfaces = fieldnames(LE(b).Surface);
                for s=1:length(surfaces)
                    cCenter = LE(b).Surface.(surfaces{s}).Center;
                    cAxis   = LE(b).Surface.(surfaces{s}).Axis;
                    radius = LE(b).Surface.(surfaces{s}).Radius;
                    startPoint  = cCenter + cAxis * 160;
                    endPoint    = cCenter;
                    drawCylinder(axH, [startPoint, endPoint, radius], 'open', ...
                        'FaceColor', 'r', ...
                        'FaceAlpha', 0.3, ...
                        'FaceLighting', 'gouraud');
                    drawArrow3d(axH, cCenter,cAxis*160,'r');
                end
            end
        end
    end
end

%% Landmarks
if visLandmarks
    if isfield(LE,'Landmarks')
        landmarkProps.Marker='o';
        landmarkProps.LineStyle='none';
        landmarkProps.MarkerEdgeColor='k';
        landmarkProps.MarkerFaceColor='k';
        for b = 1:length(LE)
            if ~isempty(LE(b).Landmarks)
                landmarks = fieldnames(LE(b).Landmarks);
                for lm=1:length(landmarks)
                    drawPoint3d(axH, LE(b).Landmarks.(landmarks{lm}).Pos, ...
                        landmarkProps, 'DisplayName', landmarks{lm});
                end
            end
        end
    end
end

%%
xlabel(axH, 'X'); ylabel(axH, 'Y'); zlabel(axH, 'Z');
if NoB>2
    axis(axH, 'equal')
    grid(axH, 'on')
else
    axis(axH, 'equal','tight');
end

end