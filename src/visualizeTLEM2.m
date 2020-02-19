function visualizeTLEM2(LE, axH, varargin)

%% Input parsing
p = inputParser;
valFctBones = @(x) validateattributes(x, {'numeric'}, {'>=',1, '<=',length(LE)});
addParameter(p, 'Bones', length(LE), valFctBones);
addParameter(p, 'Joints', false, @islogical);
addParameter(p, 'Muscles', {}); %  @(x) isstruct(x) || isempty(x)
addParameter(p, 'MuscleList', {}, @iscell);
addParameter(p, 'Surfaces', {}, @iscell);
addParameter(p, 'ShowSurf', false, @islogical);
parse(p, varargin{:});

NoB = p.Results.Bones;
visJoints = p.Results.Joints;
Muscles = p.Results.Muscles;
% if ~isempty(Muscles); Muscles=Muscles(:,1); end
MuscleList = p.Results.MuscleList;
Surfaces = p.Results.Surfaces;
visSurfaces = p.Results.ShowSurf;


%% Visualization of the model
hold(axH,'on')
patchProps.EdgeColor    = 'none';
patchProps.FaceColor    = [0.95 0.91 0.8];
patchProps.FaceAlpha    = 1;
patchProps.EdgeLighting = 'gouraud';
patchProps.FaceLighting = 'gouraud';

%% Visualize bones
if NoB == 1 || NoB == 2
    % Draws bone only if its pelvis (1) or femur (2). Transforms bone back 
    % to its local bone CS (-> neutral postion). Used for Frontal, Sagittal 
    % and Transversal View in the Results panel.
    patch(axH, transformPoint3d(LE(NoB).Mesh, inv(LE(NoB).TFM)), patchProps);
else
    % Draws all the bones. Used for Visualization panel
    for n = 1:NoB
        patch(axH, LE(n).Mesh, patchProps);
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

%% Visualize muscles initialisation
if ~isempty(Muscles)
    % again propreties for lines and markers
    lineProps.Marker = 'o';
    lineProps.Linestyle = '-';
    lineProps.MarkerSize = 2;
    for m = 1:length(Muscles)
        lineProps.DisplayName = Muscles(m).Name{:}(1:end-1);
        for c = 1:size(MuscleList,1)
            if isequal(Muscles(m).Name{:}(1:end-1),MuscleList{c,1})
                lineProps.Color = MuscleList{c,2};
            end
        end
        lineProps.MarkerEdgeColor = lineProps.Color;
        lineProps.MarkerFaceColor = lineProps.Color;
        if isempty(Muscles(m).Surface)
            % drawing muscles as lines (Straight and Via), as there are no
            % surfaces to be drawn
            drawPoint3d(axH, Muscles(m).Points, lineProps);
        elseif size(Muscles(m).Points,1) <= 2
            % draws wrapped muscles between Origin and Insertion
            Muscles(m).Surface.plotWrappingSystem(lineProps, axH);
        elseif size(Muscles(m).Points,2) > 2
            % draws wrapped muscles between two Via Points and the rest of
            % the points between which no wrapping occurs
            Muscles(m).Surface.plotWrappingSystem(lineProps, axH);
            for p = 1:size(Muscles(m).Points,1)
                if isequal(Muscles(m).Points(p,:), Muscles(m).Surface.straightLineSegments{1}.startPoint')
                    pIdx = p;
                    break;
                end
            end
            drawPoint3d(axH, Muscles(m).Points(1:pIdx,:), lineProps);
            drawPoint3d(axH, Muscles(m).Points(pIdx+1:end,:), lineProps);
        end
    end
end


%% Visualize wrapping cylinders
if visSurfaces
    if ~isempty(Surfaces)
        for s = 1:size(Surfaces,1) % run through all the surfaces
            for b = 1:2 % run through pelvis and femur (only bones with wrapping
                if isequal(Surfaces{s,2},LE(b).Name)
                    cCenter = LE(b).Surface.(Surfaces{s,1}).Center;
                    cAxis   = LE(b).Surface.(Surfaces{s,1}).Axis;
                    radius = LE(b).Surface.(Surfaces{s,1}).Radius;
                    startPoint  = cCenter + cAxis * 160;
                    endPoint    = cCenter;
                    drawCylinder(axH, [startPoint, endPoint, radius], 'open', ...
                        'FaceColor', 'red', ...
                        'FaceAlpha', 0.2, ...
                        'FaceLighting', 'gouraud');
                end
            end
        end
    end
end

%%
axis(axH, 'equal', 'tight');
xlabel(axH, 'X'); ylabel(axH, 'Y'); zlabel(axH, 'Z');

end