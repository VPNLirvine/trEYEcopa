function init()
% This script sets up this folder in preparation for analysis. It will: 
% - create a folder to house output files
% - calculate the motion energy and "interactivity" of each video
% - extract our key metrics from the raw gaze data in the EDF files
% - save each metric to a .mat file
% - create a .csv file ready for loading in R

% Create an output folder to house a file for each metric
p = specifyPaths('..');
if ~exist(p.results, 'dir')
    fprintf(1, 'Creating new results directory:\n %s\n', p.results)
    mkdir(p.results);
end

% Loop over each metric and export to results folder
% Running deviance first ensures we generate the motion maps used elsewhere
types = {'TC', 'MW'};
metrics = {'deviance', 'sfix', 'tot', 'isc', 'movert', 'fixddt'};
for i = 1:length(types)
    stype = types{i};
    saveStimParams(stype); % get info like stimulus duration
    % Save each of these metrics with a specific variable name
    for j = 1:length(metrics)
        metric = metrics{j};
        output = fullfile(p.results, [stype, '_', metric, '.mat']);
        if exist(output, 'file')
            % If data already exists, skip with warning
            fprintf(1, '%s data %s already exists; skipping.\n', stype, metric)
        else
            % Calculate and save to disk
            S.(metric) = getData(metric, stype); % dynamically-named struct
            save(output, '-struct', 'S'); % unpacks the struct S
            clear S
        end
    end
    % Save this specific metric to disk separate from the others
    % Because it is windowed over time, i.e. has 4x the rows
    f = fullfile(p.results, [stype, '_fixddt.mat']);
    load(f, 'fixddt');
    exportResults(fixddt);
end

% Now export the rest of the results via existing function
exportResults(combineTCData(), 'alldata');
exportResults(combineMWData(), 'alldata');

fprintf(1, 'Finished initializing! Data is ready for analysis.\n')