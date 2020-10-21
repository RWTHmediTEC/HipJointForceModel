function fasForce = muscleRecruitmentEnergy(C1,F_0,F_MIN,fMax,aeq,beq,PCSA,OPTIONS,fasMass)
% Energy [Praagman et al. 2006]
C2 = 1-C1;
costFunction = @(F) sum(fasMass.*((C1*F)./PCSA +((C2*F)./fMax).^2));
[fasForce,exitflag] = fmincon(costFunction,F_0,[],[],aeq,beq,F_MIN,fMax,[],OPTIONS);
end