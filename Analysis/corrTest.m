data = getTCData('ISC');

subList = unique(data.Subject);
% Now only analyze correlations based on subject 1
s = 1;
s2 = 2;
s1dat = data(strcmp(data.Subject, subList{s}), :);
s2dat = data(strcmp(data.Subject, subList{s2}), :);
numTrials = height(s1dat);
ISC = nan([numTrials, 1]);
for t = 1:numTrials
    % See if this trial exists for subject 2
    tname = s1dat.StimName{t};
    if ismember(tname, s2dat.StimName)
        % Figure which trial you need from subject 2
        ind = find(strcmp(tname, s2dat.StimName));
        % Slice out the heatmaps for both subjects
        heatmap1 = s1dat.Eyetrack{t};
        heatmap2 = s2dat.Eyetrack{ind};
        
        % Now correlate the heatmaps
        ISC(t) = corr2(heatmap1, heatmap2);
    else
        % Nothing to compare, so move to next trial
        continue
    end
end

% So now what?