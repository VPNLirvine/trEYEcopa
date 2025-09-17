function data = getMWData(varargin)
% Simplified script for getting eyetracking data for M&W data
% Based on workflow for TriCOPA data
% Exports a table that can be used with fitlm()

% Set variable
if nargin > 0
    metricName = varargin{1};
else
    % What metric to analyze - see selectMetric
    % By default, use percent time spent fixating
    metricName = 'scaledfixation';
end
fprintf(1, 'Using metric %s\n\n', metricName);

% Declare constants
condList = readtable('MWConditionList.csv');
addpath('..'); % to allow specifyPaths to run
pths = specifyPaths('..');
outputPath = pths.MWdat;

% Collect references to all edf files that exist in the outputPath
fileList = dir(outputPath);
    fnames = {fileList.name};
    subset = cellfun(@(x)endsWith(lower(x), '.edf'), fnames, 'UniformOutput', false);
    subset = cell2mat(subset);
    edfList = fileList(subset); clear fileList

    if nargin > 1
        subList = varargin{2};
        % subset edfList to just the subjects asked for
        subIDs = arrayfun(@(x) sprintf('MW_%02.f', x), subList, 'UniformOutput', false);
        subset = contains({edfList.name}, subIDs);
        edfList = edfList(subset);
    end
numSubs = length(edfList);

% Get some stimulus parameters that are relevant for synchronization
params = importdata('MWstimParams.mat', 'stimParams');

% Initialize an empty dataframe
    % Requires specifying the data type ahead of time
    dheader = {'Subject', 'Eyetrack', 'Category', 'StimName'};
    useCell = any(strcmp(metricName, {'heatmap','gaze'}));
    if useCell
        % Let the Eyetrack field take a cell with a 2D matrix
        dtypes = {'string', 'cell', 'string', 'string'};
    else
        dtypes = {'string', 'double', 'string', 'string'};
    end
    data = table('Size', [0 length(dheader)],'VariableNames', dheader, 'VariableTypes', dtypes);
    
    % Suppress a warning about the way I fill the table
    warning('off', 'MATLAB:table:RowsAddedExistingVars');
    
    % Put data for all subjects into one big dataframe
    fprintf(1, 'Importing data for %i subjects.\n\n', numSubs);

i = 0;
for subject = 1:numSubs
    fprintf(1, 'Reading from %s...\n', edfList(subject).name);
    
    subID = erase(edfList(subject).name, '.edf');
    edfName = edfList(subject).name;
    fpath = fullfile(outputPath, edfName);
    Trials = osfImport(fpath);
    
    eyetrack = []; % init per sub
    badList = [];
    for trial = 1:length(Trials)
        if isempty(Trials(trial).Saccades)
            % Eyetracking data is missing for some reason
            % Don't attempt to extract data that isn't there
            badList = [badList, trial];
        end
        
        stimName = getStimName(Trials(trial));
        opts.params = params(strcmp(params.StimName, stimName),:);
        % No MW video was ever flipped, but some functions expect a value
        opts.flip = false;

        % Ignore the mechanical videos for time on target
        % Then please only ever analyze as a correlation
        isMec = skipThisVideo(stimName, 'MW');
        if strcmp(metricName, 'tot') && isMec
            continue
        end
        
        i = i + 1;

        if useCell
            eyetrack{1} = selectMetric(Trials(trial), metricName, opts);
            % Note above is cell, not double like below
        else
            eyetrack(1) = selectMetric(Trials(trial), metricName, opts);
        end
        % Output data
        data.Subject{i} = subID;
        data.Eyetrack(i) = eyetrack;
        data.Category(i) = condList.CONDITION(strcmp(stimName, condList.NAME));
        data.StimName{i} = stimName;
    end
end
warning('on', 'MATLAB:table:RowsAddedExistingVars');
% Calculate RFX anova
% anovan(data.Eyetrack, {data.Category, data.Subject}, 'varnames', {'Condition', 'SubID'}, 'random', [2]);
