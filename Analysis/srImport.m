function Trials = srImport(fileName)
% Import edf file to matlab using SR Reseach (manufacturer) 
% Direct questions to A.E.

%% adding file extension if necessary 
if (isempty(regexp(fileName, '.edf$')))
  fileName= [fileName '.edf'];
end

pths = specifyPaths('..');

% Guess file location based on subject prefix
if contains(fileName,'MW')
    fileLoc = pths.MWdat;
elseif contains(fileName,'TC')
    fileLoc = pths.TCdat;
else
    fileLoc = pths.data;
end

% Extract data
cd(pths.edfalt)
Trials = edfmex([fileLoc '/' fileName]);
% Trials = edfExtractInterestingEvents(Trials);
% cd /Users/vpnl/Documents/MATLAB/ExpAnalyze
cd(pths.analysis)
end