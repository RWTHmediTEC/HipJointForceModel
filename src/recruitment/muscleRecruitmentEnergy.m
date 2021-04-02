function fasForce = muscleRecruitmentEnergy(F0,Fmin,Fmax,aeq,beq,PCSA,C1,fasMass,OPTIONS)
%MUSCLERECRUITMENTENERGY Energy muscle recruitment criterion
%
% Reference:
% [Praagman 2006] 2006 - Praagman - The relationship between two different 
%   mechanical cost functions and muscle oxygen consumption
% https://doi.org/10.1016/j.jbiomech.2004.11.034
%
% Inputs
% PCSA: physiological cross-sectional area 
% C1: Contribution from the linear term
% fasMass: fascicle mass
%
% AUTHOR: Fabian Schimmelpfennig
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

% [Praagman 2006, Eq.8]
C2 = 1-C1;
costFunction = @(F) sum(fasMass.*((C1*F)./PCSA +((C2*F)./Fmax).^2));
fasForce = fmincon(costFunction,F0,[],[],aeq,beq,Fmin,Fmax,[],OPTIONS);
end