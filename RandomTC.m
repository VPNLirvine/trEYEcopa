function NewOrd = RandomTC(subID)
% NOT FULLY ADAPTED from RandomMS
% Idea is to output a list of filenames in randomized order
% But the randomization is controlled somehow
% For Martin & Weisberg, it alternates social and mechanical conditions
% For TriCOPA, it should RANDOMLY(?) alternate mirroring
% Need to leave a breadcrumb that tells you what was mirrored
rng('default')

pths = specifyPaths();
csvPath = fullfile(pths.TCstim, 'normal', 'stimData.csv');
T = readtable(csvPath);

stimNames = T.movie(:);
numStims = length(stimNames);
numFlipped = floor(numStims / 2);


newsubID = str2num(subID); % convert the number to numerical format
rng(newsubID); % Seed RNG based on subject ID

% Shuffle the list, split 50/50, and label
firstShuffle = stimNames(randperm(numStims));
NewOrd = cell(1,length(firstShuffle)); % initialize output

% Write a path into the filename
for i = 1:numStims
    if i <= numFlipped
        NewOrd(i) = fullfile('normal', firstShuffle(i));
    else
        try
            NewOrd{i} = fullfile('flipped', ['f_' firstShuffle{i}]);
        catch ME
            rethrow ME
        end
    end
end

% Shuffle again to get a randomized mix of conditions
newinds = randperm(numStims);
NewOrd = NewOrd(newinds);

% Leave a breadcrumb beyond just the folder name
flipOrder = zeros([1,numStims]);
flipOrder(1:numFlipped) = 1;
flipOrder = flipOrder(newinds);
% flipOrder needs to get output somewhere...
end