% Reads in ANY .tsv file in beh/ with 'task-debug' in the filename
% Expects to see a column called 'Onset' for each frame of each video
% Calculates frame duration based on onset times, 
% then generates a histogram 

% 
addpath('..');
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
    flatOutput = [];
    for o = 1:numStims
        output(i).stim(o).name = stimList(o);
        % We're dealing with onset times, but we care about durations
        % So use diff to get the differences b/w onset times, 
        % which is essentially the same thing as duration
        % Produces n-1 results since we don't get an offset for the final
        output(i).stim(o).data = diff(input.Onset(strcmp(input.StimName,stimList(o))));
        flatOutput = [flatOutput; output(i).stim(o).data];
        % Subplot histograms for every movie
        figure();
            histogram(output(i).stim(o).data * 1000);
            title(strrep(stimList(o),'_','\_'));
            xlabel('Frame duration (msec)');
            ylabel('Num instances');
            xlim([0,36]); % fine-tune
            % ylim([0,100]); % fine-tune
    end
    % Separate by movie
    % data = pivot(input, Columns='StimName', Method="mean", DataVariable='Duration')
    % Plot histogram of frame durations
    figure()
        histogram(flatOutput * 1000);
        title(sprintf('Considering %i movies', numStims));
        xlabel('Frame duration (msec)');
        ylabel('Num instances');
        xlim([0,36]); % fine-tune
    
    % t-test for differences by movie?
end