function BoxplotMW(data, metricName)

%% Constants
condList = data.Category;
conds = unique(condList);
numConds = length(conds);
subList = unique(data.Subject);
numSubs = length(subList);

[axistxt, histy, ylimvec] = getGraphLabel(metricName); % variable axis label text
%% Split by condition
close all
for i = 1:numConds
    thisCond = conds{i};
    figure();
    histogram(data.Eyetrack(strcmp(data.Category, thisCond)));
        title(thisCond);
        % ylim(histy);
        xlim(ylimvec);
        xlabel(axistxt);
end

%% Split by condition, grouped by subject
% close all

figure();
for sub = 1:numSubs
    subID = subList{sub};
    subDat = strcmp(data.Subject, subID);
    subplot(1,numSubs,sub);
    boxplot(data.Eyetrack(subDat), data.Category(subDat), 'GroupOrder',conds);
        title(strrep(subID,'_','\_'));
        xticklabels(conds);
        ylim(ylimvec);
        ylabel(axistxt);
end

%% Split by stimulus, grouped by condition
% close all

for c = 1:numConds
    thisCond = strcmp(data.Category, conds{c});
    stimList = unique(data.StimName(thisCond));
    figure();
    boxplot(data.Eyetrack(thisCond), data.StimName(thisCond), 'GroupOrder', stimList);
        title(conds{c});
        xticklabels(stimList);
        ylim(ylimvec);
        ylabel(axistxt);
end
    