function [x, vidList] = rankAQperVid(data)
% Given a stack of eyetracking data, rank each AQ subscale per video
% Calculate an LME per video and extract the Coefficients structure
% Output is a 4*n*100 matrix stacking them in the 3rd dimension
%
% Then need to think of a way to evaluate which video is "more affected" by
% one AQ scale than the others
% Greg's paper had 2 coefficients and just took their difference
% Since we have 3, it's more complicated
% Peruse Walker 2021 for better methods?

vidList = unique(data.StimName);
numVids = length(vidList); % ought to be 100
nvar = 4;
nval = 7; % ?? the number of items to extract from the coefficient table
x = zeros([nvar, nval, numVids]);

for i = 1:numVids
    vname = vidList{i};
    subset = strcmp(vname, data.StimName);
    tmpDat = data(subset, :);
    tmpMdl = fitlme(tmpDat, 'Response ~ SocialSkills + Communication + AttentionDetail');
    
    % Extract the coefficients
    x(:,:,i) = tmpMdl.Coefficients(:,2:end); % ought to all be the same size
end

% Are ANY subscales significant?
% pThresh = 0.05 / size(x, 1); % bonferroni corrected
pThresh = 0.05;
pVals = squeeze(x(2:4,5,:));
sigVids = any(pVals <= pThresh, 1);
sigVidNames = vidList(sigVids);
% Save this list to disk for use in other functions
% save('sigVids.mat', 'sigVidNames');

% What about the bottom 25 videos on this scale?
% pVals is 3x100, one for each subscale. You need to compress to 1x100.
% ...I guess just average the pValues together?? to rank that video overall
[~, lowOrder] = sort(mean(pVals, 1, 'omitnan'), 'descend');
unSigVidNames = vidList(lowOrder);
unSigVidNames = unSigVidNames(1:25);
% save('unSigVids.mat', 'unSigVidNames');


% WHICH subscales are significant?
s1 = squeeze(x(2,5,:)) <= pThresh;
SocSkillVids = vidList(s1);
s2 = squeeze(x(3,5,:)) <= pThresh;
CommVids = vidList(s2);
s3 = squeeze(x(4,5,:)) <= pThresh;
AttDetVids = vidList(s3);

% REPORT
fprintf(1, '\n');
if ~isempty(SocSkillVids)
    fprintf(1, 'SOCIAL SKILLS significant videos:\n')
    fprintf(1, '\t%s\n', SocSkillVids{:});
    fprintf(1, '\n');
else
    fprintf(1, 'No videos significant for SOCIAL SKILLS.\n\n')
end
if ~isempty(SocSkillVids)
    fprintf(1, 'COMMUNICATION significant videos:\n')
    fprintf(1, '\t%s\n', CommVids{:});
    fprintf(1, '\n');
else
    fprintf(1, 'No videos significant for COMMUNICATION.\n\n')
end
if ~isempty(SocSkillVids)
    fprintf(1, 'ATTENTION TO DETAIL significant videos:\n')
    fprintf(1, '\t%s\n', AttDetVids{:});
    fprintf(1, '\n');
else
    fprintf(1, 'No videos significant for ATTENTION TO DETAIL.\n\n')
end

sall = s1 & s2 & s3;
SigForAll = vidList(sall);
fprintf(1, 'Videos that fit all three criteria:\n');
if isempty(SigForAll)
    fprintf(1,'\t(none)\n');
else
    fprintf(1, '\t%s\n', SigForAll{:});
end