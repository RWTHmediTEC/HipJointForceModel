function fasForce = muscleRecruitmentPoly(F0,Fmin,Fmax,aeq,beq,N,DP,opts)
%MUSCLERECRUITMENTPOLY Polynomial muscle recruitment criterion
%
% Reference:
% [Rasmussen 2001] 2001 - Rasmussen - Muscle recruitment by the min/max 
%   criterion - a comparative numerical study
% https://doi.org/10.1016/s0021-9290(00)00191-3
%
% Inputs
% p: Power
% N: Normalization factor (maximum muscle strength, PCSA or others)
%
% AUTHOR: Fabian Schimmelpfennig
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

% [Rasmussen 2001, Eq.5]
costFunction = @(F) sum((F./N).^DP);
fasForce = fmincon(costFunction,F0,[],[],aeq,beq,Fmin,Fmax,[],opts);
end