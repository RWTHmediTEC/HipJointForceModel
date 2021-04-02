function angles = calculateHJFangles(HJF)
%CALCULATEHJFANGLES calculates the angles of the hip joint force in the
% anatomical planes.
%
% Applicable only for a HJF in a coordinate system with 'ASR' orientation.
%
% AUTHOR: B. Eggert
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

angles(:,1) = atand(HJF(:,3)./HJF(:,2)); % Frontal angle
angles(:,2) = atand(HJF(:,1)./HJF(:,2)); % Sagittal angle
angles(:,3) = atand(HJF(:,1)./HJF(:,3)); % Transverse angle

end