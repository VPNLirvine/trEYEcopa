function plotPupil(data, subList, trialList)
% Take a full stack of pupillometry data as input (i.e. all subs)
% Plot a specific subset, based on subject ID and/or stimulus name
% DO NOT default to plotting everything since there are ~100 trials/sub
subset = contains(data.Subject, subList) & contains(data.StimName, trialList);
eyetrack = data.Eyetrack(subset);
n = sum(subset);
inds = find(subset);
figure();
sr = 500; % assume eye data was sampled at 250 Hz; may vary by sub...
for i = 1:n
    j = inds(i);
    subID = data.Subject{j};
    trialID = data.StimName{j};
    subplot(n,1,i);
    x = 0:1/sr:(length(eyetrack{i}) - 1)/sr;
    y = eyetrack{i};
    y = y(1,:); % strip out the second row
    plot(x, y);
    t = sprintf('%s\n%s', subID, trialID);
    title(replace(t, '_', '\_'));
    % Y axis is pupil size, but units unknown.
    ylabel('Pupil size');
    % X axis is time, likely in samples, MAYBE at 250Hz?
    xlabel('Time (sec)');
    xlim([0 9000/sr]);
    ylim([0 3000]);
end