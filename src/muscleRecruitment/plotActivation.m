function plotActivation(nOAM,muscleRecruitmentCriteria,fasActi,nOAF,musActi,muscleNames)
nBOM = length(muscleNames);
xFas = (1:nOAM);
xMus = (1:nBOM);
switch muscleRecruitmentCriteria    
    case 'MinMax'
        leg = 'Min/Max Criteria';
    case 'Polynom2'
        leg = 'Polynom2 Criteria';
    case 'Polynom3'
        leg = 'Polynom3 Criteria';
    case 'Polynom5'
        leg = 'Polynom5 Criteria';
    case 'Energy'
        leg = 'Energy Criteria';
end

figure('color','w','Position',[20,50,1600,700])
bar(xFas,fasActi,'FaceColor','g');
title('Activation per fascicle')
xlabel('Fascicle')
ylabel('Activation')
xTicks = (1:1:nOAM);
yTicks = (0:.2:1.2);
set(gca,'xtick',xTicks,'ytick',yTicks,'xticklabel',nOAF,'xlim',[0,nOAM+1],'ylim',[0,1.1])
xtickangle(90)
legend(leg)
grid('on')

figure('color','w','Position',[20,50,1600,700])
bar(xMus,musActi,'FaceColor','g');
title('Activation per muscle')
xlabel('Muscle')
ylabel('Activation')
xTicks = (1:1:nBOM);
yTicks = (0:.2:1.2);
set(gca,'xtick',xTicks,'ytick',yTicks,'xticklabel',muscleNames,'xlim',[0,nBOM+1],'ylim',[0,1.1])
xtickangle(90)
legend(leg)
grid('on')
end