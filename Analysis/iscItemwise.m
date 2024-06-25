function iscItemwise()
% Itemwise analysis of intersubject correlations
% Instead of a subjectwise analysis, analyze within each video
% Look for video-based trends that could influence subject-level data

data = doISC(getTCData('heatmap'));
stimList = unique(data.StimName);
numVids = length(stimList);

output = [];
iscBins = 0:0.1:1;
for v = 1:numVids
    vidName = stimList{v};
    subset = strcmp(vidName, data.StimName);
    output.meanISC(v) = mean(data.Eyetrack(subset));
    output.stdISC(v) = std(data.Eyetrack(subset));
    output.meanResp(v) = mean(data.Response(subset));
    output.stdResp(v) = std(data.Response(subset));
    if rem(v,10) == 1
        figure();
        x = 0;
    end
    x = x + 1;
    % Generate plots
    stimName = strrep(vidName, '_', '\_');
    subplot(2, 10, x);
        % ISC
        histogram(data.Eyetrack(subset), iscBins);
        title(stimName);
        xlabel('ISC');
        ylim([0 5]);
    subplot(2, 10, 10 + x);
        % Ratings
        histogram(data.Response(subset), [0.5 1.5 2.5 3.5 4.5 5.5]);
        title(stimName);
        xlabel('Rating');
        ylim([0 5]);
end

% Scatterplot and correlation
z = corr(output.meanResp', output.meanISC', 'Type', 'Spearman');
figure();
    scatter(output.meanResp, output.meanISC);
    xlabel('Rating');
    ylabel('ISC');
    ttxt = sprintf('Each dot = one video, averaged across subjects\n\x03C1 = %0.2f', z);
    title(ttxt);
    xlim([0,6]);
    ylim([0,1]);

% Try looking for outliers?
zISC = zscore(output.meanISC);
tally = zISC >= 3 | zISC <= -3;
fprintf(1, '%i stims with an outlier average ISC\n', sum(tally));

end