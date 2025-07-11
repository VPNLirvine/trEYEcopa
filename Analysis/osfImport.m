function [Trials, Preamble] = osfImport(fileName)
% Import an edf file to matlab using OSF edfImport() and edfExtractInterestingEvents() 
% Input 1 is expected to contain the entire path
% This function analyzes that path to determine if the data is TC, MW, etc.
% If data was saved to .mat (in another folder), will load that instead.

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
    if contains(fileName,['source' filesep 'MW'])
        fileLoc = pths.MWdat;
        matLoc = pths.MWmat;
    elseif contains(fileName,['source' filesep 'TC'])
        fileLoc = pths.TCdat;
        matLoc = pths.TCmat;
    elseif contains(fileName, ['source' filesep 'NAR'])
        fileLoc = pths.NARdat;
        matLoc = pths.NARmat;
    elseif contains(fileName,['source' filesep 'fixation_checks'])
        fileLoc = pths.fixdat;
        matLoc = pths.fixmat;
    else
        fileLoc = pths.data;
        matLoc = pths.data;
    end

    addpath(pths.edf);

    % Check for .mat file, in case bad subject (or just to be lazy)
    [~,fileName2] = fileparts(fileName);
    % fileName2 = [fileName2(1:end-3) 'mat'];
    fileName2 = [fileName2 '.mat'];
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
        [Trials, Preamble] = edfImport(fileName, [1 1 1], '');
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