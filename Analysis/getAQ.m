function output = getAQ(pths)
% Import AQ data from Qualtrics
% Export a dataframe with main score and subscores per subject
% Take the paths struct as input?
warning('off', 'MATLAB:table:ModifiedAndSavedVarnames');
x = dir(fullfile(pths,beh,'Baron Cohen*.tsv'));
data = readtable(x(1).name, "FileType", "delimitedtext", "Delimiter", "\t");

output = table();
output.SubID = data.Q58;
output.AQ = data.SC0;

warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
end
