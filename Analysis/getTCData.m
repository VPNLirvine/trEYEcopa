function data = getTCData(metricName, options)
% Returns a table of data for all subjects with eyetracking, trial num, etc
% Input 1: metric name, as used in selectMetric. e.g. 'tot', 'blinkrate'
% (Optional) subList: list of subject numbers to get data for.
% (Optional) numWindows: subdivides each trial into N evenly-sized temporal
% windows, and calculates the DV for each window independently
% Optional inputs are specified as name-value pairs OR as e.g. numWindows=1

arguments
    metricName {mustBeText}
    options.subList {mustBeNumeric} = []
    options.numWindows (1,1) {mustBeNumeric} = 1
end
% Set flags
useWindows = false;
if options.numWindows > 1
    % validate against a list of compatible metrics
    if ~any(strcmp(metricName, {'fixddt', 'tot'}))
        warning('No code exists to subdivide metric %s into %i windows: defaulting to 1', metricName, options.numWindows);
        options.numWindows = 1;
    else
        useWindows = true;
    end
end
useCell = any(strcmp(metricName, {'heatmap','gaze', 'track', 'devvec', 'resolution'}));

    % Find the location of our data
    addpath('..'); % Allow specifyPaths to work
    pths = specifyPaths('..');
    outputPath = pths.TCdat;
    fileList = dir(outputPath);
        % String-insensitive compare, in case file extension is uppercase
        fnames = {fileList.name};
        subset = cellfun(@(x)endsWith(lower(x), '.edf'), fnames, 'UniformOutput', false);
        subset = cell2mat(subset);
        edfList = fileList(subset); clear fileList
    if ~isempty(options.subList)
        % subset edfList to just the subjects asked for
        subIDs = arrayfun(@(x) sprintf('TC_%02.f', x), options.subList, 'UniformOutput', false);
        subset = contains({edfList.name}, subIDs);
        edfList = edfList(subset);
    end
    
    numSubs = length(edfList); % Count the number of subjects to process

    % Get some stimulus parameters that are relevant for synchronization
    params = importdata('TCstimParams.mat', 'stimParams');
    
    % Initialize an oversized dataframe, to be pruned at the end
    % Requires specifying the data type ahead of time
    
    dheader = {'Subject', 'Eyetrack', 'StimName', 'Response', 'RT', 'Flipped'};
    if useWindows
        % Special case with an extra column
        dheader = {'Subject', 'Eyetrack', 'Quadrant', 'StimName', 'Response', 'RT', 'Flipped'};
        dtypes = {'string', 'double', 'double', 'string', 'double', 'double', 'logical'};
    elseif useCell
        % Let the Eyetrack field take a cell with a 2D matrix
        dtypes = {'string', 'cell', 'string', 'double', 'double', 'logical'};
    else
        dtypes = {'string', 'double', 'string', 'double', 'double', 'logical'};
    end
    numStims = height(params);
    numInitRows = numSubs * numStims;
    opts.numWindows = options.numWindows;
    numInitRows = numInitRows * opts.numWindows; % default is 1 window
    data = table('Size', [numInitRows length(dheader)],'VariableNames', dheader, 'VariableTypes', dtypes);
    
    % Suppress a warning about the way I fill the table
    warning('off', 'MATLAB:table:RowsAddedExistingVars');
    
    % Put data for all subjects into one big dataframe
    fprintf(1, 'Importing data for %i subjects.\n\n', numSubs);
    i = 0;
    for subject = 1:numSubs
        % Get subject ID
        edfName = edfList(subject).name;
        subID = erase(edfName, '.edf');
        if contains(subID, '.EDF')
            % Catch uppercase ext while preserving everything else's case
            subID = erase(subID, '.EDF');
        end
        
        % Get behavioral data
        blist = dir(fullfile(pths.beh, [subID, '_task-TriCOPA_', '*.txt']));
        if isempty(blist)
            warning('Could not find behavioral data file for subject %s; skipping\n', subID);
            continue
            % Otherwise, load up the first hit
        end
        fname = fullfile(pths.beh, blist(1).name);
        behav = readtable(fname, 'Delimiter', '\t');
        behav = processBeh(behav); % convert stim folder to a variable
        
        % Get number of trials from behavioral file instead of EDF.
        % If a subject terminated early, it probably happened during video.
        % The EDF will thus have some data from the stopped trial,
        % while the behavioral file will have skipped the output stage.
        numTrials = height(behav);
        
        % Get eyetracking data
        fprintf(1, '%s: ', subID);
        fpath = fullfile(outputPath, edfName);
        edf = osfImport(fpath);
        eyetrack = []; % init per sub
        
        % Give feedback on progress
        fprintf(1, 'Processing trial 000')
        for t = 1:numTrials
            fprintf(1, '\b\b\b%03.f', t);
            if isempty(edf(t).Saccades) || behav.Response(t) == -1
                % Either eyetracking data is missing, or no response
                % Don't attempt to extract data that isn't there
                % Remember to drop this trial from the behavioral data
                continue
            else
                opts.flip = logical(behav.Flipped(t));
                % Subset the big stim table to just this trial's data
                stimName = getStimName(edf(t));
                [~,stimName,e] = fileparts(stimName); % strip any path
                if opts.flip
                    stimName = stimName(3:end); % strip the 'f_' part
                end
                stimName = strcat(stimName, e);
                opts.params = params(strcmp(params.StimName, stimName),:);
                
                % Get data
                eyetrack = selectMetric(edf(t), metricName, opts);
                i = i + 1;
                if useWindows
                    % Special case that expands to many rows per trial
                    ind = i:i+(opts.numWindows-1);
                    i = i+(opts.numWindows-1);
                    data.Quadrant(ind) = eyetrack(:,2);
                    eyetrack = eyetrack(:,1);
                else
                    ind = i;
                end
                data.Subject(ind) = {subID};
                data.Response(ind) = behav.Response(t);
                data.RT(ind) = behav.RT(t);
                data.Flipped(ind) = behav.Flipped(t);
                data.StimName(ind) = behav.StimName(t);
                if useCell
                    data.Eyetrack(ind) = {eyetrack};
                else
                    data.Eyetrack(ind) = eyetrack;
                end

            end
        end
        fprintf(1, '\n')
        
    end % for subject, extracting data
    % Drop any unused rows in the table, since we initialized with too many
    data = rmmissing(data);
    warning('on', 'MATLAB:table:RowsAddedExistingVars');
end % function