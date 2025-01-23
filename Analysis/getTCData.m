function data = getTCData(metricName)
    % Find the location of our data
    addpath('..'); % Allow specifyPaths to work
    pths = specifyPaths('..');
    outputPath = pths.TCdat;
    edfList = dir(fullfile(outputPath, '*.edf'));
    numSubs = length(edfList); % Count the number of subjects to process
    
    % Initialize an empty dataframe
    % Requires specifying the data type ahead of time
    useCell = any(strcmp(metricName, {'heatmap','gaze', 'track', 'deviance'}));
    dheader = {'Subject', 'Eyetrack', 'Response', 'RT', 'Flipped'};
    if useCell
        % Let the Eyetrack field take a cell with a 2D matrix
        dtypes = {'string', 'cell', 'double', 'double', 'logical'};
    else
        dtypes = {'string', 'double', 'double', 'double', 'logical'};
    end
    data = table('Size', [0 length(dheader)],'VariableNames', dheader, 'VariableTypes', dtypes);
    
    % Suppress a warning about the way I fill the table
    warning('off', 'MATLAB:table:RowsAddedExistingVars');
    
    % Put data for all subjects into one big dataframe
    fprintf(1, 'Importing data for %i subjects.\n\n', numSubs);
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
        edf = osfImport(edfName);
        eyetrack = []; % init per sub
        badList = [];
        for t = 1:numTrials
            if isempty(edf(t).Saccades) || behav.Response(t) == -1
                % Either eyetracking data is missing, or no response
                % Don't attempt to extract data that isn't there
                % Remember to drop this trial from the behavioral data
                badList = [badList, t];
            else
                opts = logical(behav.Flipped(t));
                if useCell
                    eyetrack{t} = selectMetric(edf(t), metricName, opts);
                    % Note above is cell, not double like below
                else
                    eyetrack(t) = selectMetric(edf(t), metricName, opts);
                end
            end
        end
        
        % Drop trials on the bad list
        behav(badList, :) = [];
        numTrials = height(behav);
        eyetrack(badList) = [];
        
        % Now Trials is a huge struct of eyetracking data,
        % And behav is a big table of response data.
        % Extract the relevant bits and slice into the dataframe.
        
        newRange = size(data, 1)+1:size(data, 1)+numTrials;
        data.Subject(newRange) = subID;
        data.Eyetrack(newRange) = eyetrack;
        data.Response(newRange) = behav.Response;
        data.RT(newRange) = behav.RT;
        data.Flipped(newRange) = behav.Flipped;
        data.StimName(newRange) = behav.StimName;
        
    end % for subject, extracting data
    warning('on', 'MATLAB:table:RowsAddedExistingVars');
end % function