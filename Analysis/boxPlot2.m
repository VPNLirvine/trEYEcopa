%% Constants
fixMec = y(strcmp(condList, 'Mechanical'));
fixSoc = y(strcmp(condList, 'Social'));
[axistxt, histy, ylimvec] = getGraphLabel(metricName); % variable axis label text
%% Histograms split by condition
close all
for i = 1:2
    figure();
    if i == 1
        histogram(fixSoc);
        title('Social');
    else
        histogram(fixMec);
        title('Mechanical');
    end
   ylim(histy);
   xlim(ylimvec);
   xlabel(axistxt);
end

%% Boxplots for each condition
figure();
    boxplot([fixSoc, fixMec]);
    cname = {'Social', 'Mechanical'};
    xticklabels(cname);
    ylim(ylimvec);
    ylabel(axistxt);

%% Split by condition, grouped by subject
% close all
cname = {'Social', 'Mechanical'};
figure();
for sub = 1:length(s)
    data = [];
    for c = 1:2
        if c == 1
            stimList = s(sub).socMovies;
            thisDat = s(sub).socFixations;
        else
            stimList = s(sub).mecMovies;
            thisDat = s(sub).mecFixations;
        end
        for t = 1:8
            stimName = stimList{t}; % unused
            data(t,c) = thisDat(t);
        end
    end
    subplot(1,length(s),sub);
    boxplot(data);
    title(strrep(edfList(sub).name,'_','\_'));
    xticklabels(cname);
    ylim(ylimvec);
    ylabel(axistxt);
end

%% Split by condition, SCALED by subject
% close all
cname = {'Social', 'Mechanical'};
figure();
groupDat = [];
for sub = 1:length(s)
    data = [];
    for c = 1:2 % condition
        if c == 1
            stimList = s(sub).socMovies;
            thisDat = s(sub).socFixations;
        else
            stimList = s(sub).mecMovies;
            thisDat = s(sub).mecFixations;
        end
        for t = 1:8 % stimulus
            stimName = stimList{t}; % unused
            data(t,c) = thisDat(t);
        end
    end
    groupDat = [groupDat; zscore(data, 0, 'all') ];
%     groupDat = [ groupDat; data / mean(data, 'all') ]; 
end

    boxplot(groupDat);
%     title(strrep(edfList(sub).name,'_','\_'));
    xticklabels(cname);
%     ylim(ylimvec);
    ylabel(['z-score of ' axistxt]);


%% Split by stimulus, grouped by condition
% under construction
% close all
figure();
cname = {'Social', 'Mechanical'};
for c = 1:2
    data = [];
    for sub = 1:length(s)
        if c == 1
            stimList = s(sub).socMovies;
            thisDat = s(sub).socFixations;
        else
            stimList = s(sub).mecMovies;
            thisDat = s(sub).mecFixations;
        end
        for t = 1:8
            stimName = stimList{t};
            data(sub,t) = thisDat(t);
        end
    end
    subplot(1,2,c);
    boxplot(data);
    title(cname{c});
    xticklabels(stimList);
    ylim(ylimvec);
    ylabel(axistxt);
end
    