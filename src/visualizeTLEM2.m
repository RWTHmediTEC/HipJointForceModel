function visualizeTLEM2(LE, muscleList, axH, varargin)

% Input parsing
p = inputParser;
valFctBones=@(x) validateattributes(x,{'numeric'},{'>=',1,'<=',length(LE)});
addParameter(p,'Bones',length(LE),valFctBones);
addParameter(p,'Joints',false,@islogical);
addParameter(p,'Muscles',{},@iscell);
parse(p,varargin{:});

NoB = p.Results.Bones;
visJoints = p.Results.Joints;
visMuscles=p.Results.Muscles;

%% Visualization of the model
hold(axH,'on')
patchProps.EdgeColor    = 'none';
patchProps.FaceColor    = [0.95 0.91 0.8];
patchProps.FaceAlpha    = 1;
patchProps.EdgeLighting = 'gouraud';
patchProps.FaceLighting = 'gouraud';

% Visualize bones
meshHandle = zeros(NoB);
for n = 1:NoB
    meshHandle(n) = patch(axH, LE(n).Mesh, patchProps);
end

H_Light(1) = light(axH); light(axH, 'Position', -1*(get(H_Light(1),'Position')));

% Visualize joint axes
if visJoints
    % pointProps.Marker          = 'o';
    % pointProps.MarkerSize      = 5;
    % pointProps.LineStyle       = 'none';
    % pointProps.MarkerEdgeColor = 'k';
    % pointProps.MarkerFaceColor = 'k';
    for b = 2:length(LE)
        % Get joints of the bone
        joints = fieldnames(LE(b).Joints);
        for j = 1:length(joints)
            if isfield(LE(b).Joints.(joints{j}), 'Axis')
                jCenter = LE(b).Joints.(joints{j}).Pos;
                jAxis = LE(b).Joints.(joints{j}).Axis;
                % Draw joint center
                % drawPoint3d(axH, jCenter, pointProps);
                jAxisOrigin = jCenter - 60*jAxis;
                % jAxisEnd = jAxisOrigin + 120*jAxis;
                % text(axH, jAxisEnd(1), jAxisEnd(2), jAxisEnd(3), joints{j});
                quiver3D(axH, jAxisOrigin, 120*jAxis, rand(1,3), 0.9);
            end
        end
    end
end

% Visualize muscles
if ~isempty(visMuscles)
    lineProps.Marker = 'o';
    lineProps.MarkerSize = 2;
    % Loop over bones with muscles
    BwM = find(~arrayfun(@(x) isempty(x.Muscle), LE));
    for b = BwM
        Muscles = fieldnames(LE(b).Muscle);
        % Loop over the muscles of the bone
        for m = 1:length(Muscles)
            Via = [];
            % Check if the muscle originates from this bone
            oIdx = strcmp(LE(b).Muscle.(Muscles{m}).Type, 'Origin');
            if any(oIdx) && ismember(Muscles{m}, visMuscles)
                Origin = LE(b).Muscle.(Muscles{m}).Pos(oIdx,:);
                % Check if there are Via points on the bone of Origin
                vIdx = strcmp(LE(b).Muscle.(Muscles{m}).Type, 'Via');
                if any(vIdx)
                    Via = LE(b).Muscle.(Muscles{m}).Pos(vIdx,:);
                end
                % Loop over the other bones exept the bone of Origin
                for bb = BwM(BwM~=b)
                    matchingMuscle = fieldnames(LE(bb).Muscle);
                    if any(strcmp(Muscles(m), matchingMuscle))
                        % Check if there are Via points on the bone
                        vIdx=strcmp(LE(bb).Muscle.(Muscles{m}).Type, 'Via');
                        if any(vIdx)
                            Via = [Via; LE(bb).Muscle.(Muscles{m}).Pos(vIdx,:)];
                        end
                        % Check if it is the bone of insertion
                        iIdx = strcmp(LE(bb).Muscle.(Muscles{m}).Type, 'Insertion');
                        if any(iIdx)
                            Insertion = LE(bb).Muscle.(Muscles{m}).Pos(iIdx,:);
                        end
                    end
                end
                
                % Combine Origin, Via points & Insertion
                mPoints = [Origin; Via; Insertion];
                lineProps.DisplayName = Muscles{m};
                colorIdx = strcmp(Muscles{m}(1:end-1), muscleList(:,1));
                lineProps.Color = muscleList{colorIdx,2};
                lineProps.MarkerEdgeColor = lineProps.Color;
                lineProps.MarkerFaceColor = lineProps.Color;
                drawPoint3d(axH, mPoints, lineProps);
            end
        end
    end
end

axis(axH, 'equal','tight');
xlabel(axH, 'X'); ylabel(axH, 'Y'); zlabel(axH, 'Z');

end