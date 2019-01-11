function graphFR8data(matFileName)
% HELP SECTION TO BE ADDED
%
%
%

load(matFileName,'T');

T.efficiency = (T.numReward.*8)./T.numPress;
[perSession,sessions] = findgroups(T(:,'date'));
[perAnimal,animals] = findgroups(T(:,'animal'));
meanEfficiency = mean(T.efficiency);
meanEffiPerSesh = splitapply(@mean,T.efficiency,perSession);
SEMfxn = @(x)std(x)/sqrt(length(x));
semEffiPerSesh = splitapply(SEMfxn,T.efficiency,perSession);
outliers = isoutlier(T.efficiency);

figure(1);
clf;hold on
grid on
p1 = gscatter(T.date,T.efficiency, perSession, 'b', [], 5);
p2 = fill([table2array(sessions);flipud(table2array(sessions))],...
    [meanEffiPerSesh-semEffiPerSesh;flipud(meanEffiPerSesh+semEffiPerSesh)],...
    [.9 .9 .9],'linestyle','none','FaceAlpha',.3,'LineStyle',':');
p3 = plot(table2array(sessions),meanEffiPerSesh);
p4 = scatter(T.date(outliers),T.efficiency(outliers),10,'r', '+');
set(gca,'YLim', [0 1]);
p5 = plot(get(gca,'XLim'),[meanEfficiency meanEfficiency],'k');
xStart = T.date(3);
xEnd = T.date(2);
yStart = 0.5;
p6 = line([xStart xEnd],[yStart meanEfficiency], 'Color','black');
text(xStart,yStart-0.01,['\mu = ' num2str(meanEfficiency)], 'HorizontalAlignment',...
    'left','color','k','FontSize', 10, 'FontName', 'Arial');
xlabel('Training days','FontSize', 10, 'FontName', 'Arial');
xtickformat('MM-dd');
ylabel('Efficiency score (au)','FontSize', 10, 'FontName', 'Arial');
title('Efficiency scores across training','FontSize', 10, 'FontName', 'Arial');
mu = strcat('\mu= ',num2str(meanEfficiency));
legend([p5 p3 p2 p4], {mu,'Mean','SEM', ... 
    'Outliers',}, 'Location', 'southwest'); % gscatter groups the data and saves 
    % it in groups, that's why I cannot include it to my legend, I couldn't find a 
    % solution to this online
hold off
JNeuro= gcf;
    width= 17.6; height= 8.5; % 2 column width
JNeuro.PaperUnits= 'centimeters';
JNeuro.PaperOrientation= 'portrait';
JNeuro.PaperPosition= [0 0 width height];
JNeuro.PaperPositionMode= 'manual';
JNeuro.PaperSize= [width height];
JNeuro.Units= 'centimeters';
JNeuro.Position= [10 10 width height];
print('Figure1 (JNeuro Format)', '-dpng','-r300');


figure(2);
clf;hold on
boxplot(T.efficiency,perAnimal,'OutlierSize',4);
xticklabels(table2cell(animals));
xtickangle(45);
set(gca,'YLim', [0 1]);
plot(get(gca,'XLim'),[meanEfficiency meanEfficiency],'k');
xStart = 3;
xEnd = 2.6;
yStart = 0.45;
line([xStart xEnd],[yStart meanEfficiency], 'Color','black');
text(xStart,yStart-0.01,['\mu = ' num2str(meanEfficiency)], 'HorizontalAlignment',...
    'left','color','k', 'FontSize', 7,'FontName', 'Arial');
xlabel('Animals','FontSize', 10, 'FontName', 'Arial'); 
ylabel('Efficiency score (au)','FontSize', 10, 'FontName', 'Arial');
title('Efficiency scores per animal','FontSize', 10, 'FontName', 'Arial');
hold off
fig = gcf;
fig = get(JNeuro);
newWidth= 11.6; newHeight= 5.2;
fig.PaperPosition= [0 0 newWidth newHeight];
fig.PaperSize= [newWidth newHeight];
fig.Position= [10 10 newWidth newHeight];
print('Figure2 (JNeuro Format)', '-dpng','-r300');

figure(3);
clf; hold on
rewardSec = T.rewards{1,1}./60;
bar(rewardSec, 100.*ones(size(rewardSec)), 0.1, 'stacked', 'r');
headentSec = T.headEntries{1,1}./60;
bar(headentSec, 60.*ones(size(headentSec)), 0.4, 'stacked','k');
pressSec = T.presses{1,1}./60;
scatter(pressSec,0:1:length(pressSec)-1,'.');
end
