function LE = transformTLEM2(LE, TFM)
%TRANSFORMTLEM2 Transformation of the model by matrix TFM

for b = 1:length(LE)
    if ~isequal(TFM(:,:,b), eye(4))
        % Bones
        if isfield(LE(b),'Mesh')
            LE(b).Mesh = transformPoint3d(LE(b).Mesh, TFM(:,:,b));
        end
        % Joints
        if isfield(LE(b),'Joints')
            joints = fieldnames(LE(b).Joints);
            for j = 1:length(joints)
                % Joint position
                LE(b).Joints.(joints{j}).Pos = transformPoint3d(...
                    LE(b).Joints.(joints{j}).Pos, TFM(:,:,b));
                % Joint axis
                if isfield(LE(b).Joints.(joints{j}), 'Axis')
                    LE(b).Joints.(joints{j}).Axis = transformVector3d(...
                       LE(b).Joints.(joints{j}).Axis, TFM(:,:,b));
                end
            end
        end
        % Muscles
        if isfield(LE(b),'Muscle')
            if ~isempty(LE(b).Muscle)
                fascicles = fieldnames(LE(b).Muscle);
                for m = 1:length(fascicles)
                    LE(b).Muscle.(fascicles{m}).Pos = transformPoint3d(...
                        LE(b).Muscle.(fascicles{m}).Pos, TFM(:,:,b));
                end
            end
        end
        % Surfaces
        if isfield(LE(b),'Surface')
            if ~isempty(LE(b).Surface)
                surfaces = fieldnames(LE(b).Surface);
                for s = 1:length(surfaces)
                    % Center of surface
                    LE(b).Surface.(surfaces{s}).Center = ...
                        transformPoint3d(LE(b).Surface.(surfaces{s}).Center, TFM(:,:,b));
                    % Axis of surface
                    LE(b).Surface.(surfaces{s}).Axis = ...
                        transformVector3d(LE(b).Surface.(surfaces{s}).Axis, TFM(:,:,b));
                end
            end
        end
        % Landmarks
        if isfield(LE(b),'Landmarks')
            if ~isempty(LE(b).Landmarks)
                landmarks = fieldnames(LE(b).Landmarks);
                for m = 1:length(landmarks)
                    LE(b).Landmarks.(landmarks{m}).Pos = transformPoint3d(...
                        LE(b).Landmarks.(landmarks{m}).Pos, TFM(:,:,b));
                end
            end
        end
    end
end

end