function [Trials, Preamble] = osfImport(fileName)
% Import edf file to matlab using OSF edfImport() and edfExtractInterestingEvents() 
% Direct questions to A.E.
addpath('..'); % to allow specifyPaths to run
pths = specifyPaths('..');
try
    
    if ~ischar(fileName)
        fileName = char(fileName);
    end
    
    %% adding file extension if necessary
    if (isempty(regexp(fileName, '.edf$')))
        fileName= [fileName '.edf'];
    end
    
    %%
    if contains(fileName,'MW')
        fileLoc = pths.MWdat;
    elseif contains(fileName,'TC')
        fileLoc = pths.TCdat;
    elseif contains(fileName,'fix')
        fileLoc = pths.fixdat;
    else
        fileLoc = pths.data;
    end
    
    
    addpath(pths.edf);
    [Trials, Preamble] = edfImport([fileLoc filesep fileName], [1 1 1], '');
    Trials = edfExtractInterestingEvents(Trials);

catch ME
    disp(ME.identifier)
    disp(ME.message)
end

end