function leverArm = leverOfMuscles(r,s,z)
%% Get lever arm of muscles around hip joint center
% Projecting a point onto a line
NoAF = size(r,1);
leverArm = nan(1,NoAF);
zOnLineOfAction = nan(NoAF,3);
for i = 1:NoAF
    % Point onto force direction line in which lever arm is perpendicular 
    zOnLineOfAction(i,:) = projPointOnLine3d(z,[r(i,:) s(i,:)]);    
    % Length of lever arm
    leverArm(i) = norm(z-zOnLineOfAction(i,:));                            
end
% Index of LP which are on the right of hip joint center 
negIdx = find(zOnLineOfAction(:,3)<0);         
% Change of algebraic sign
leverArm(negIdx) = -leverArm(negIdx);                                 
end