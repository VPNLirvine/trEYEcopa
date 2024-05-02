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
dur1 = double(edf.Header.duration); % Header duration
dur2 = double(edf.Header.endtime - edf.Header.starttime); % Header difference
dur3 = double(edf.Header.endtime - edf.StartTime); % osfImport duration
dur4 = getStimDuration(edf); % PTB presentation time in seconds
dur5 = double(edf.Samples.time(end) - edf.Samples.time(1)); % Length of eyetracking in ms
dur6 = findStimOffset(edf) - findStimOnset(edf);

%% Compare all three EDF durations to the expected duration
fprintf(1, '\nVideo: %s\n', stimName);
fprintf(1, 'Expected duration is %0.4f sec\n', exptDur);
fprintf(1, '\tEDF Header duration is %0.4f sec\n', dur1 / 1000);
fprintf(1, '\tCalculated duration is %0.4f sec\n', dur2 / 1000);
fprintf(1, '\tosfImport-based duration is %0.4f sec\n', dur3 / 1000);
fprintf(1, '\tMessage-based duration is %0.4f sec\n', dur4);
fprintf(1, '\tSampling duration is %0.4f sec\n', dur5 / 1000);
fprintf(1, '\tPrecise video duration is %0.4f sec\n', dur6 / 1000);
