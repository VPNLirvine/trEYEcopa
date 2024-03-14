function iscItemwise()
% Itemwise analysis of intersubject correlations
% Instead of a subjectwise analysis, analyze within each video
% Look for video-based trends that could influence subject-level data

data = doISC;
stimList = unique(data.StimName);
numVids = length(stimList);

output = [];
iscBins = 0:0.1:1;
for v = 1:numVids
    vidName = stimList{v};
    subset = strcmp(vidName, data.StimName);
    output(v,1) = mean(data.Eyetrack(subset));
    output(v,2) = mean(data.Response(subset));
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

% Overall scatterplot shows no relation
figure();
    scatter(output(:,2), output(:,1));
    xlabel('Rating');
    ylabel('ISC');

end