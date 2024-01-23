% Parameters to recover
mu = 24; sigma = .3;

% Open output file
outputPath = fullfile(pwd, 'sub-01_task-debug_date-22-Jan-2024.tsv');
fid = fopen(outputPath, 'a');
fprintf(fid, 'Trial \tStimName \tFrame \tDuration\n'); % write header

numSims = 4;
duration = 15; % seconds, say
numFrames = duration * mu;

for s = 1:numSims
    simName = sprintf('%2.f_fakeMovie_frameRate-%i.mov', s, mu);
    simData = (sigma * randn([numFrames, 1])) + mu; % simulate new data per run
    for f = 1:numFrames
        % output simulated data
        fprintf(fid, '%i\t%s\t%i\t%4.6f\n', s, simName, f, simData(f));
    end
    simData = []; % clear before recalculating, just to be careful
end
fclose(fid);
fprintf(1, 'Simulated data exported to %s\n', outputPath);