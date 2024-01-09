function analyzeVideos(inputDir)
% A run-once function that extracts header info from stimulus files
% Used to get the exact durations of each video
% Exports to a .csv in the same folder


flist = dir(fullfile(inputDir, '*.mov'));

if ~isempty(flist)
    % Open an output file
    outname = fullfile(inputDir, 'stimData.csv');
    fid = fopen(outname, 'w+'); % overwrite if existing
    fprintf(fid, 'NAME,DURATION\n'); % OUTPUT HEADER
    
    fprintf(1, 'Analyzing %i videos:\n', length(flist));
    
    for i = 1:length(flist)
        fname = flist(1).name;
        floc = fullfile(inputDir, fname);
        
        fprintf(1, '\t%i of %i: %s... ', i, length(flist), fname);

        dat = mmfileinfo(floc); % Extract file header info
        duration = dat.Duration; % Get duration

        % Send info to an output CSV
        fprintf(fid, '%s,%f\n', fname, duration);
        
        fprintf(1, 'Done.\n')
    end
    fclose(fid); % Write to file
    fprintf(1,'\nDone! File info exported to %s\n', outname);
end