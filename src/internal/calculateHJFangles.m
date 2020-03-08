function angles = calculateHJFangles(HJF)

% For 'ASR' coordinate system
angles(:,1) = atand(HJF(:,3)./HJF(:,2)); % Frontal angle
angles(:,2) = atand(HJF(:,1)./HJF(:,2)); % Sagittal angle
angles(:,3) = atand(HJF(:,1)./HJF(:,3)); % Transverse angle

end