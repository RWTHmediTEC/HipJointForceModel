function LE = transformTLEM2(LE, TFM)
% Transformation of the model by matrix TFM

for b = 1:length(LE)
    if ~isequal(TFM(:,:,b), eye(4))
        % Bones
        LE(b).Mesh = transformPoint3d(LE(b).Mesh, TFM(:,:,b));
        % Joints
        joints = fieldnames(LE(b).Joints);
        for j = 1:length(joints)
            % Joint position
            LE(b).Joints.(joints{j}).Pos =...
                transformPoint3d(LE(b).Joints.(joints{j}).Pos, TFM(:,:,b));
            % Joint axis
            if isfield(LE(b).Joints.(joints{j}), 'Axis')
%                 LE(b).Joints.(joints{j}).Axis =...
%                     transformVector3d(LE(b).Joints.(joints{j}).Axis, TFM(:,:,b));
            end
        end
        % Muscles
        if ~isempty(LE(b).Muscle)
            fascicles = fieldnames(LE(b).Muscle);
            for m = 1:length(fascicles)
                LE(b).Muscle.(fascicles{m}).Pos =...
                    transformPoint3d(LE(b).Muscle.(fascicles{m}).Pos, TFM(:,:,b));
            end
        end
    end
end

end