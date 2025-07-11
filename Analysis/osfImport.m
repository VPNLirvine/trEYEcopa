function [Trials, Preamble] = osfImport(fileName)
% Import edf file to matlab using OSF edfImport() and edfExtractInterestingEvents() 
% Input 1 is expected to be JUST the filename, i.e. no path attached
% This function dynamically find a path to the file based on its prefix
% Direct questions to A.E.
addpath('..'); % to allow specifyPaths to run
pths = specifyPaths('..');
try
    
    if ~ischar(fileName)
        fileName = char(fileName);
    end
    
    %% adding file extension if necessary
    if (isempty(regexpi(fileName, '.edf$')))
        fileName= [fileName '.edf'];
    end
    
    %%
    if contains(fileName,'MW')
        fileLoc = pths.MWdat;
        matLoc = pths.MWmat;
    elseif contains(fileName,'TC')
        fileLoc = pths.TCdat;
        matLoc = pths.TCmat;
    elseif contains(fileName,'fix')
        fileLoc = pths.fixdat;
        matLoc = pths.fixmat;
    else
        fileLoc = pths.data;
        matLoc = pths.data;
    end

    addpath(pths.edf);

    % Check for .mat file, in case bad subject (or just to be lazy)
    fileName2 = [fileName(1:end-3) 'mat'];
    fp = fullfile(matLoc, fileName2);
    if exist(fp, 'file')
        % Import existing data
        fprintf(1, 'Importing data from %s\n', fp);
        Trials = importdata(fp);
        if isfield(Trials, 'FILENAME')
            % Convert to look like edfImport output
            Trials = edfTranslate(Trials);
        end
    else
        % Perform standard import via mex
        [Trials, Preamble] = edfImport([fileLoc filesep fileName], [1 1 1], '');
        % Export to mat file, to save time on future imports
        save(fp, 'Trials');
        fprintf(1, 'Data exported to %s\n', fp);
    end
    Trials = edfExtractInterestingEvents(Trials);

catch ME
    disp(ME.identifier)
    disp(ME.message)
end

end