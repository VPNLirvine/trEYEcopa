function Trials = srImport(fileName)
% Import edf file to matlab using SR Reseach (manufacturer) 
% Direct questions to A.E.

%% adding file extension if necessary 
if (isempty(regexp(fileName, '.edf$')))
  fileName= [fileName '.edf'];
end;

%%
if contains(fileName,'MW')
    fileLoc = '/Users/vpnl/Documents/MATLAB/ExpOutputs/MWoutput';
elseif contains(fileName,'TC')
    fileLoc = '/Users/vpnl/Documents/MATLAB/ExpOutputs/TCoutput';
else
    fileLoc = '/Users/vpnl/Documents/MATLAB/ExpOutputs';

    

cd /Users/vpnl/Documents/MATLAB/edf_alt
Trials = edfmex([fileLoc '/' fileName]);
% Trials = edfExtractInterestingEvents(Trials);
cd /Users/vpnl/Documents/MATLAB/ExpAnalyze
end