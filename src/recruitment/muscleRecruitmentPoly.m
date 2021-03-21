function fasForce = muscleRecruitmentPoly(DP,F_0,F_MIN,fMax,aeq,beq,N,OPTIONS)
% Polynomial [Pedotti et al. 1978, Herzog 1978, Happee 1994]
costFunction = @(F) sum((F./N).^(DP));
fasForce = fmincon(costFunction,F_0,[],[],aeq,beq,F_MIN,fMax,[],OPTIONS);
end