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
condList = readtable('condition list - Sheet1.csv');
addpath('..'); % to allow specifyPaths to run
pths = specifyPaths('..');
outputPath = pths.MWdat;

% Collect references to all edf files that exist in the outputPath
edfList = dir(fullfile(outputPath, '*.edf')); 
numSubs = length(edfList);

% Initialize an empty dataframe
    % Requires specifying the data type ahead of time
    dheader = {'Subject', 'Eyetrack', 'Category', 'StimName'};
    if strcmp(metricName, 'heatmap')
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
    Trials = osfImport(edfList(subject).name);

    for trial = 1:length(Trials)
        if isempty(Trials(trial).Saccades)
            % Eyetracking data is missing for some reason
            % Don't attempt to extract data that isn't there
            continue
        end
        i = i + 1;
        stimName = getStimName(Trials(trial));
        % Output data
        data.Subject{i} = subID;
        data.Eyetrack(i) = selectMetric(Trials(trial), metricName);
        data.Category(i) = condList.CONDITION(strcmp(stimName, condList.NAME));
        data.StimName{i} = stimName;
    end
end
warning('on', 'MATLAB:table:RowsAddedExistingVars');
% Calculate RFX anova
% anovan(data.Eyetrack, {data.Category, data.Subject}, 'varnames', {'Condition', 'SubID'}, 'random', [2]);