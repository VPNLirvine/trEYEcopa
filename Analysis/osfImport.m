function [Trials, Preamble] = osfImport(fileName)
% Import edf file to matlab using OSF edfImport() and edfExtractInterestingEvents() 
% Direct questions to A.E.

try
    basePath = pwd;
    
    if ~ischar(fileName)
        fileName = char(fileName);
    end
    
    %% adding file extension if necessary
    if (isempty(regexp(fileName, '.edf$')))
        fileName= [fileName '.edf'];
    end;
    
    %%
    if contains(fileName,'MW')
        fileLoc = '/Users/vpnl/Documents/MATLAB/ExpOutputs/MWoutput';
    elseif contains(fileName,'TC')
        fileLoc = '/Users/vpnl/Documents/MATLAB/ExpOutputs/TCoutput';
    elseif contains(fileName,'fix')
        fileLoc = '/Users/vpnl/Documents/MATLAB/fixation_checks';
    else
        fileLoc = '/Users/vpnl/Documents/MATLAB/ExpOutputs';
    end
    
    
    cd /Users/vpnl/Documents/MATLAB/edfImport
    [Trials, Preamble] = edfImport([fileLoc '/' fileName], [1 1 1], '');
    Trials = edfExtractInterestingEvents(Trials);
    cd(basePath)

catch ME
    disp(ME.identifier)
    disp(ME.message)
    cd(basePath)
end

end