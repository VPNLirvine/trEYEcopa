function buttonHist()
% Generate a histogram of button press values
% Pull data from /beh/*.txt

addpath('..');
pths = specifyPaths('..');

task = 'task-TriCOPA';

datList = dir(fullfile(pths.beh, ['*', task, '*.txt']));
numSubs = length(datList);

responses = [];
for s = 1:numSubs
    % Read in data for this subject
    fname = datList(s).name;
    fpath = fullfile(pths.beh, fname);
    dat = readtable(fpath, 'Delimiter', '\t');
    
    % Slice data into output var
    % Don't preallocate size bc number of trials varies across subjects
    tmp = dat.Response;
    tmp(:,2) = s; % inject a column tracking subject number, just in case
    responses = [responses; tmp];
end

%% Plot data
figure();
histogram(responses(:,1)); % only analyze the values, not the subject number
    title('Response frequency');
    xlabel('Button value');
    
end % function