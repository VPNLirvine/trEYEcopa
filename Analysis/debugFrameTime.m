% trial number
% stimulus ID
% timestamp of frame onset
% pths = specifyPaths('..');
pths.beh = pwd;
flist = dir(fullfile(pths.beh, '*_task-debug_date-*.tsv'));
numFiles = length(flist);
for i = 1:numFiles
    fname = fullfile(pths.beh, flist(i).name);
    input = readtable(fname, "FileType","text",'Delimiter', '\t');
    % 'Trial \tStimName \tFrame \tDuration\n'
    stimList = unique(input.StimName);
    numStims = length(stimList);
    output(i).name = fname;
    output(i).numStims = numStims;
    figure();
    for o = 1:numStims
        output(i).stim(o).name = stimList(i);
        output(i).stim(o).data = input.Duration(strcmp(input.StimName,stimList(i)));

        % Subplot histograms for every movie
        subplot(1,numStims,o);
            histogram(output(i).stim(o).data);
            title(stimList(i));
            xlabel('Frame duration (sec)');
            ylabel('Num instances');
            % xlim([20,40]); % fine-tune
            % ylim([0,100]); % fine-tune
    end
    % Separate by movie
    % data = pivot(input, Columns='StimName', Method="mean", DataVariable='Duration')
    % Plot histogram of frame durations
    figure()
        histogram(input.Duration);
        title(sprintf('Considering %i movies', numStims));
        xlabel('Frame duration (sec)');
        ylabel('Num instances');

    
    % t-test for differences by movie?
end