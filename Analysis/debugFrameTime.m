% It looks like the videos are shooting for a frame rate of 60 fps
% So the expected duration is 0.0167 sec or 16.7 msec
% But the measured duration of each 'frame' is closer to 0.669 msec,
% Which means PTB is trying to refresh at a rate closer to 1000 fps
% So this analysis is a bust.
% I have no idea whether timing is significantly degraded or not.

pths = specifyPaths('..');
% pths.beh = pwd;
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
            histogram(output(i).stim(o).data * 1000);
            title(stimList(i));
            xlabel('Frame duration (msec)');
            ylabel('Num instances');
            xlim([.5,1]); % fine-tune
            % ylim([0,100]); % fine-tune
    end
    % Separate by movie
    % data = pivot(input, Columns='StimName', Method="mean", DataVariable='Duration')
    % Plot histogram of frame durations
    figure()
        histogram(input.Duration * 1000);
        title(sprintf('Considering %i movies', numStims));
        xlabel('Frame duration (msec)');
        ylabel('Num instances');
        xlim([.5,1]); % fine-tune
    
    % t-test for differences by movie?
end