function savePosition(output)
% Expect a single row of position data, as you would get from getPosition
% Specifically want output of frame3movie, after tweaking thresholds
% Save that data to a specific location

assert(height(output) == 1, 'Too many rows of data! Expected only 1')
vidName = output.StimName{1};

pths = specifyPaths('..');
    outpath = fullfile(pths.pos);
    if ~exist(outpath, 'dir')
        mkdir(outpath);
    end
    fout = fullfile(outpath, [vidName '.mat']);
    save(fout, 'output');