function visualizeMuscleActivation(MSC, activation, varargin)
%VISUALIZEMUSCLEACTIVATION visualizes the activation of the muscles for the
% optimization based muscle recruitment.
%
% AUTHOR: F. Schimmelpfennig
% COPYRIGHT (C) 2021 mediTEC, RWTH Aachen University
% LICENSE: EUPL v1.2

hAx = gca;
if isAxisHandle(MSC)
    hAx = MSC;
    MSC = activation;
    activation = varargin{1};
end

NoAE = size(activation,1);
xFas = (1:NoAE);
bar(hAx, xFas,activation.Activation,'FaceColor','g');
ylabel(hAx, 'Activation')
xTicks = (1:1:NoAE);
yTicks = (0:.2:1.2);
set(hAx, 'xtick',xTicks,'ytick',yTicks,...
    'xticklabel',activation.Properties.RowNames,'xlim',[0,NoAE+1],'ylim',[0,1.1])
xtickangle(hAx, 45)
legend(hAx, [MSC ' Criterion'])
grid(hAx, 'on')
end