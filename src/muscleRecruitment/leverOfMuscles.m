function h = leverOfMuscles(nOAM,r,s,z)
%% Get lever arm of muscles around hip joint center
% Projecting a point onto a line
h = nan(1,nOAM);
lP = nan(3,nOAM);
for i = 1:nOAM
    lP(:,i) = projPointOnLine3d(z,[r(i,:) s(i,:)])';    % Point onto force direction line in which lever arm is perpendicular 
    h(i) = norm(z'-lP(:,i));                            % Length of lever arm
end

negIdx = find(lP(3,:)<0);                               % Index of LP which are on the right of hip joint center 
h(negIdx) = -h(negIdx);                                 % Change of algebraic sign
end