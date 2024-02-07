function analysis(varargin)
% Perform statistical analysis on eyetracking data

% Optional input 1 should be a metric name listed in selectMetric()
if nargin > 0
    metricName = varargin{1};
else
    % By default, use percent time spent fixating
    metricName = 'scaledfixation';
end

% The exact test depends on which stimulus set we're looking at
% So force a choice:
choice = menu('Which data do you want to analyze?','TriCOPA','Martin & Weisberg');

if choice == 1
    % TriCOPA
    fprintf(1, 'Using metric %s\n\n', metricName);
    % Find the location of our data
    addpath('..'); % Allow specifyPaths to work
    pths = specifyPaths('..');
    outputPath = pths.TCdat;
    edfList = dir(fullfile(outputPath, '*.edf'));
    numSubs = length(edfList); % Count the number of subjects to process
    
    % Initialize an empty dataframe
    % Requires specifying the data type ahead of time
    dheader = {'Subject', 'Eyetrack', 'Response', 'RT', 'Flipped'};
    dtypes = {'string', 'double', 'double', 'double', 'logical'};
    data = table('Size', [0 length(dheader)],'VariableNames', dheader, 'VariableTypes', dtypes);
    
    % Suppress a warning about the way I fill the table
    warning('off', 'MATLAB:table:RowsAddedExistingVars');
    
    % Put data for all subjects into one big dataframe
    fprintf(1, 'Importing data for %i subjects.\n\n', numSubs);
    for subject = 1:numSubs
        % Get subject ID
        edfName = edfList(subject).name;
        subID = erase(edfName, '.edf');
        
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
        
        for t = 1:numTrials
            eyetrack(t) = selectMetric(edf(t), metricName);
        end
        
        
        % Now Trials is a huge struct of eyetracking data,
        % And behav is a big table of response data.
        % Extract the relevant bits and slice into the dataframe.
        
        newRange = size(data, 1)+1:size(data, 1)+numTrials;
        data.Subject(newRange) = subID;
        data.Eyetrack(newRange) = eyetrack;
        data.Response(newRange) = behav.Response;
        data.RT(newRange) = behav.RT;
        data.Flipped(newRange) = behav.Flipped;
        
    end
    warning('on', 'MATLAB:table:RowsAddedExistingVars');
    %
    % Compare the eyetracking data to the behavioral data
    %
    figure();
    mdl = fitlm(data, 'Eyetrack ~ Response');
    plot(mdl);
        xlabel('Intentionality score');
        ylabel(getGraphLabel(metricName));
        title(sprintf('Linear model based on %i subjects', numSubs));
    disp(mdl);
    % Run some stats here
    
    
elseif choice == 2
    % Martin & Weisberg
    % Pipeline was already built, just call here:
    Ttest();
end