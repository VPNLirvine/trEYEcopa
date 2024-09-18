% Get file location
pths = specifyPaths('..');
fname = 'stimData.csv';
fpath = fullfile(pths.TCstim, 'normal', fname);

% Read data
stimData = readtable(fpath);
durs = stimData.duration;
modifiedDurs = durs + 5 + 2; % add 5-sec response window and 2 sec drift check
n = length(durs); % total number of videos - should be 100

numIter = 1000;
numVids = 70; % number to subset to per iteration
totals = [];

% Get a few random draws of the videos, and get the total video time
for i = 1:numIter
    x = randperm(n, numVids); % get a subset
    totals(i) = sum(modifiedDurs(x)); % sum those durations
end

modifiedTotals = totals / 60; % scale to minutes from seconds

% Plot results
figure();
histogram(modifiedTotals);
    title(sprintf('Duration after %i videos', numVids));
    xlabel('Duration (minutes)');

% Print results to screen
fprintf(1, 'Mean duration = %0.2f minutes\n', mean(modifiedTotals));
fprintf(1, 'Range = %0.2f to %0.2f minutes\n', min(modifiedTotals), max(modifiedTotals));
