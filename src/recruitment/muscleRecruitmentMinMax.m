function fasForce = muscleRecruitmentMinMax(F_0,F_MIN,fMax,aeq,beq,N,OPTIONS)
% Min/Max criterion [Olhoff 1989, Rasmussen et al. 2001]
costFunction = @(F) F(1);
aeqBis = [zeros(size(aeq,1),1) aeq];
fTemp = fmincon(costFunction,[1;F_0],[],[],aeqBis,beq,[0;F_MIN],[Inf;fMax],@(F) constraintMinmax(F,N),OPTIONS);
fasForce = fTemp(2:end,:);
end

function [g,h] = constraintMinmax(F,N)
% Constraint for min/max optimization
g=F(2:end)./N-F(1);
h=[];
end
