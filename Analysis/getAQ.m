function output = getAQ(pths)
% Export a table with AQ and subscores per subject
% Takes the paths struct as input
% Assumes that you already have a .tsv output from Qualtrics in pths.beh

q1 = warning('query', 'MATLAB:table:ModifiedAndSavedVarnames');
q2 = warning('query', 'MATLAB:textio:io:UnableToGuessFormat');

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames'); % doesn't impact the data vars
warning('off', 'MATLAB:textio:io:UnableToGuessFormat'); % don't care about dates

% Import AQ data from Qualtrics
x = dir(fullfile(pths.beh,'Baron Cohen*.tsv'));
fname = fullfile(pths.beh, x(1).name);
% Qualtrics spits out data in UTF-16 format
% Matlab versions previous to ~2022 do not support this format
% Convert to UTF-8 instead, for compatibility
fname = verifyEncoding(fname);

% Now finally read the data in
opts = detectImportOptions(fname, "FileType", "text", "Delimiter", "\t");
data = readtable(fname, opts);

% Set up export variable
output = table();
output.SubID = data.SubID;
output.AQ = data.SC0;

% Score the subscales:
% Step 1 - Strip out the junk columns
getCols = arrayfun(@(x) sprintf('Q%d', x), 1:50, 'UniformOutput', false);
idx = ismember(data.Properties.VariableNames, getCols);
questions = data(:,idx);

clear data % save memory?

% Step 2 - Recode the reversed questions
scoreAQ = defineAQ(); % Get 'answer key'
for i = 1:50
    if strcmp(scoreAQ.Valence(i), 'Agree')
        % On a scale of 1-4, if 1 means "strongly agree" and that's bad,
        % then change that 1/4 to a 4/4, etc.
        questions{:,i} = 5 - questions{:,i};
    end
end

% Step 3 - Tally subscales
output.SocialSkills = sum(questions{:, strcmp(scoreAQ.Subscale, 'Social Skills')}, 2);
output.Communication = sum(questions{:, strcmp(scoreAQ.Subscale, 'Communication')}, 2);
output.AttentionDetail = sum(questions{:, strcmp(scoreAQ.Subscale, 'Attention to Detail')}, 2);

% Re-calculate total AQ based on the subscales
% Score range is now 28 to 112, not 0 to 50
% But keep in mind that the English paper said total scores are useless,
% because some subscales are anti-correlated...
output.AQ = output.SocialSkills + output.Communication + output.AttentionDetail;

% Subnum is sometimes shuffled? Ensure output is sorted:
output = sortrows(output);

warning(q1.state, 'MATLAB:table:ModifiedAndSavedVarnames');
warning(q2.state, 'MATLAB:textio:io:UnableToGuessFormat');
end
