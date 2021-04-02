function fasForce = muscleRecruitmentMinMax(F0,Fmin,Fmax,aeq,beq,N,OPTIONS)
%MUSCLERECRUITMENTMINMAX Min/Max muscle recruitment criterion
%
% Reference:
% [Rasmussen 2001] 2001 - Rasmussen - Muscle recruitment by the min/max 
%   criterion - a comparative numerical study
% https://doi.org/10.1016/s0021-9290(00)00191-3
%
% Inputs
% N: Normalization factor (maximum muscle strength, PCSA or others)
%
% AUTHOR: F. Schimmelpfennig
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

% [Rasmussen 2001, Eq.9]
costFunction = @(F) F(1);
aeqBis = [zeros(size(aeq,1),1) aeq];
fTemp = fmincon(costFunction,[1;F0],[],[],aeqBis,beq,[0;Fmin],[Inf;Fmax],@(F) constraintMinmax(F,N),OPTIONS);
fasForce = fTemp(2:end,:);
end

function [g,h] = constraintMinmax(F,N)
% Constraint for min/max optimization
g = F(2:end)./N-F(1);
h = [];
end
