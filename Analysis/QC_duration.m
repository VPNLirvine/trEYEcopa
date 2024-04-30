function QC_duration(edf)
% After extracting some edf data into `edf`, analyze the duration info
% There are three sources of video duration, and all seem unreliable
% The sample rate that is given for each trial also seems unreliable
% Investigate.

stimName = getStimName(edf);
%% Get the expected duration of the video
% Get file location
pths = specifyPaths('..');
fname = fullfile(pths.TCstim, stimName);

% % Read the expected duration of the video
% vidHeader = mmfileinfo(fname);
% exptDur = vidHeader.Duration;
%
% Use a Mac built-in function to find video duration
% Do this instead of mmfileinfo() bc I get a codec error on my laptop
exe = sprintf("mdls %s | grep Duration | awk '{ print $3 }'", fname);
[~,exptDur] = system(exe);
exptDur = str2double(exptDur);

%% Estimate the duration of the video from the EDF data
dur1 = edf.Header.duration; % Header duration
dur2 = edf.Header.endtime - edf.Header.starttime; % Header difference
dur3 = edf.Header.endtime - edf.StartTime; % osfImport duration
sr = edf.Header.rec.sample_rate;
sr2 = 250; % I think the above defaults to 500, even though we do 250

%% Compare all three EDF durations to the expected duration
fprintf(1, '\nVideo: %s\n', stimName);
fprintf(1, 'Expected duration is %0.4f sec\n', exptDur);
fprintf(1, '\tHeader duration at %i Hz is %0.4f sec\n', sr, dur1 / sr);
fprintf(1, '\tCalculated duration at %i Hz is %0.4f sec\n', sr, dur2 / sr);
fprintf(1, '\tosfImport duration at %i Hz is %0.4f sec\n', sr, dur3 / sr);
fprintf(1, '\n');
fprintf(1, '\tHeader duration at %i Hz is %0.4f sec\n', sr2, dur1 / sr2);
fprintf(1, '\tCalculated duration at %i Hz is %0.4f sec\n', sr2, dur2 / sr2);
fprintf(1, '\tosfImport duration at %i Hz is %0.4f sec\n', sr2, dur3 / sr2);
