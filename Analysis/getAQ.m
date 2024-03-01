function output = getAQ(pths)
% Export a table with AQ and subscores per subject
% Takes the paths struct as input
% Assumes that you already have a .tsv output from Qualtrics in pths.beh

warning('off', 'MATLAB:table:ModifiedAndSavedVarnames'); % doesn't impact the data vars
warning('off', 'MATLAB:textio:io:UnableToGuessFormat'); % don't care about dates

% Import AQ data from Qualtrics
x = dir(fullfile(pths.beh,'Baron Cohen*.tsv'));
fname = fullfile(pths.beh, x(1).name);
data = readtable(fname, "FileType", "delimitedtext", "Delimiter", "\t");

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

% Step 2 - Recode values of 1:4 to 0 or 1
scoreAQ = defineAQ(); % Get 'answer key'
for i = 1:50
    if strcmp(scoreAQ.Valence(i), 'Agree')
        questions{questions{:,i} <= 2, i} = 1;
        questions{questions{:,i} >= 3, i} = 0;
    elseif strcmp(scoreAQ.Valence(i), 'Disagree')
        questions{questions{:,i} <= 2, i} = 0;
        questions{questions{:,i} >=3, i} = 1;
    end
end

% Step 3 - Tally subscales
output.SocialSkills = sum(questions{:, strcmp(scoreAQ.Subscale, 'Social Skills')}, 2);
output.AttentionSwiching = sum(questions{:, strcmp(scoreAQ.Subscale, 'Attention Switching')}, 2);
output.AttentionDetail = sum(questions{:, strcmp(scoreAQ.Subscale, 'Attention to Detail')}, 2);
output.Communication = sum(questions{:, strcmp(scoreAQ.Subscale, 'Communication')}, 2);
output.Imagination = sum(questions{:, strcmp(scoreAQ.Subscale, 'Imagination')}, 2);

warning('on', 'MATLAB:table:ModifiedAndSavedVarnames');
warning('on', 'MATLAB:textio:io:UnableToGuessFormat');
end
