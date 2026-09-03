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
    metricName = 'sfix';
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
    if strcmp(metricName, 'fixddt')
        % Special case with an extra column
        dheader = {'Subject', 'Eyetrack', 'Quadrant', 'Category', 'StimName'};
        dtypes = {'string', 'double', 'double', 'string', 'string'};
    elseif useCell
        % Let the Eyetrack field take a cell with a 2D matrix
        dtypes = {'string', 'cell', 'string', 'string'};
    else
        dtypes = {'string', 'double', 'string', 'string'};
    end
    numStims = height(params);
    numInitRows = numSubs * numStims;
    if strcmp(metricName, 'fixddt')
        numWindows = 4;
        numInitRows = numInitRows * numWindows;
    end
    data = table('Size', [numInitRows length(dheader)],'VariableNames', dheader, 'VariableTypes', dtypes);
    
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
    for trial = 1:length(Trials)
        if isempty(Trials(trial).Saccades)
            % Eyetracking data is missing for some reason
            % Don't attempt to extract data that isn't there
            continue
        end
        
        stimName = getStimName(Trials(trial));
        opts.params = params(strcmp(params.StimName, stimName),:);
        % No MW video was ever flipped, but some functions expect a value
        opts.flip = false;

        % Ignore the mechanical videos for time on target
        % Then please only ever analyze as a correlation
        isMec = skipThisVideo(stimName, 'MW');
        if any(contains({'tot', 'movert'}, metricName)) && isMec
            continue
        end
        
        % Get data
        eyetrack = selectMetric(Trials(trial), metricName, opts);

        % Output data
        i = i + 1;
        if strcmp(metricName, 'fixddt')
            % Special case that expands to many rows per trial
            ind = i:i+3;
            i = i+3;
            data.Quadrant(ind) = eyetrack(:,2);
            eyetrack = eyetrack(:,1);
        else
            ind = i;
        end
        data.Subject(ind) = {subID};
        data.StimName(ind) = {stimName};
        if useCell
            data.Eyetrack(ind) = {eyetrack};
        else
            data.Eyetrack(ind) = eyetrack;
        end
        data.Category(ind) = condList.CONDITION(strcmp(stimName, condList.NAME));
    end
end
data = rmmissing(data);
warning('on', 'MATLAB:table:RowsAddedExistingVars');
% Calculate RFX anova
% anovan(data.Eyetrack, {data.Category, data.Subject}, 'varnames', {'Condition', 'SubID'}, 'random', [2]);
