function NewOrd = RandomTC(subID, varargin)
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

if nargin > 1
    stimList = importdata('stimList_byAQ.mat');
    % use col 2 to find the filenames from T.movie(:)
    % I'm sure there's a more efficient method but...
    sl = false(height(T), 1);
    for i = 1:size(stimList,1)
        sl = sl + contains(T.movie, num2str(stimList(i,2)));
    end
    sl = logical(sl);
    stimNames = T.movie(sl);
else
    stimNames = T.movie(:);
end
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