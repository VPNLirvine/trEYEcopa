function exportResults(data, fname)
% Saves data table to CSV format, so it can be read into R etc. easier
% Apparently the table class is too exotic for the R.matlab library.
% Takes the output of getTCData or getMWData,
% adds important predictor data like AQ scores and stim parameters,
% then writes to CSV.
% Optional second input lets you define a name for the output file;
% otherwise uses the variable name of the first input.

% Check inputs
assert(istable(data), "First input must be a table variable, i.e. class(varname) == ''table''");
if nargin < 2
    fname = inputname(1);
else
    assert(isstring(fname) || ischar(fname), "Second input must be a file name (sans extension), e.g. ''MWtot''")
end

% Insert important data
fprintf(1, 'Inserting AQ scores\n');
data = insertAQ(data);
fprintf(1, 'Inserting stimulus parameters\n');
data = insertStimParams(data);

% Export, but avoid overwriting existing files without confirmation
fout = fullfile("Results", strcat(fname, ".csv"));
doSave = true;
if exist(fout, 'file')
    choice = questdlg( ...
        sprintf('File "%s" already exists. Overwrite it?', fout), ...
        'Confirm Overwrite', ...
        'Yes', 'No', 'No');

    doSave = strcmp(choice, 'Yes');
end
if doSave
    fprintf(1, "Exporting to file %s\n", fout);
    writetable(data, fout);
else
    fprintf(1, "Canceled save to file %s\n", fout);
end

end