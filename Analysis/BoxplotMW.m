function BoxplotMW(data, metricName)

% See if you can use fancy new formatting
chk = which('tiledlayout');
ok = ~isempty(chk); % ok if not empty, not ok if empty

%% Constants
condList = data.Category;
conds = unique(condList);
numConds = length(conds);
subList = unique(data.Subject);
numSubs = length(subList);

% Have 10 subs per row
numPerRow = 10;
nRows = ceil(numSubs/numPerRow);

[axistxt, ylimvec] = getGraphLabel(metricName); % variable axis label text
%% Split by condition
close all
for i = 1:numConds
    thisCond = conds{i};
    figure();
    histogram(data.Eyetrack(strcmp(data.Category, thisCond)));
        title(thisCond);
        xlim(ylimvec);
        xlabel(axistxt);
end

%% Split by condition, grouped by subject
% close all

figure();
if ok
    tiledlayout(nRows, numPerRow);
    warning('off','stats:boxplot:BadObjectType'); % it's fine
end
for sub = 1:numSubs
    subID = subList{sub};
    subDat = strcmp(data.Subject, subID);
    if ok
        nexttile;
    else
        subplot(nRows,numPerRow,sub);
    end
    efSz = mean(data.Eyetrack(subDat & strcmp(data.Category, 'social'))) - mean(data.Eyetrack(subDat & strcmp(data.Category, 'mechanical')));
    boxplot(data.Eyetrack(subDat), data.Category(subDat), 'GroupOrder',conds);
        title(sprintf(' %s, diff = %0.2f', strrep(subID,'_','\_'), efSz));
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

warning('on','stats:boxplot:BadObjectType'); % return to dflt
    