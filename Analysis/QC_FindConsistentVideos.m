function data = QC_FindConsistentVideos(N, tcisc)
% Returns a subset of data based on three intersecting criteria:
% the videos with the N longest duration, N highest gaze metric, 
% and N highest understandability rating.
% Uses ISC as the default metric, but you can provide data for another.
% May end up returning 0 videos if all three criteria don't intersect,
% which is a function of N (i.e. N = 1 is very unlikely to return ANYTHING, 
% but N = 100 will return EVERYTHING)
%
% The idea is to find videos that all subjects interpret similarly:
% short videos don't give enough information to be useful,
% higher ISC implies that they all receive/pursue the same information,
% and high ratings theoretically mean that they do actually get the story.
% An intersection of these criteria should list the highest-ToM stims.

if nargin < 2
    tcisc = analysis('ISC'); close all;
end

% How many videos do we want to consider for each criterion?
if nargin < 1
    N = 30;
end

%% Find the top 50 longest videos
% First, get a table with the duration of each video
vidList = unique(tcisc.StimName);
for i = 1:length(vidList)
    subset = strcmp(tcisc.StimName, vidList{i});
    vidDurs(i) = mean(tcisc.Duration(subset));
end
% Sort by duration, highest first, and grab the first 50
[~, topNi] = sort(vidDurs, 'descend');
topNi = topNi(1:N);
topN1 = vidList(topNi);
% Then propagate that up to the full table, with all subjects
check1 = ismember(tcisc.StimName, topN1);

%% Find the top 50 videos with the highest average ISCs
vidList = unique(tcisc.StimName);
for i = 1:length(vidList)
    subset = strcmp(tcisc.StimName, vidList{i});
    vidEye(i) = mean(tcisc.Eyetrack(subset));
end
% Sort by ISC, highest first, and grab the first 50
[~, topNi] = sort(vidEye, 'descend');
topNi = topNi(1:N);
topN2 = vidList(topNi);
% Then propagate that up to the full table, with all subjects
check2 = ismember(tcisc.StimName, topN2);

%% Find the top 50 videos with the highest average rating
vidList = unique(tcisc.StimName);
for i = 1:length(vidList)
    subset = strcmp(tcisc.StimName, vidList{i});
    vidRat(i) = mean(tcisc.Response(subset));
end
% Sort by rating, highest first, and grab the first 50
[~, topNi] = sort(vidRat, 'descend');
topNi = topNi(1:N);
topN3 = vidList(topNi);
% Then propagate that up to the full table, with all subjects
check3 = ismember(tcisc.StimName, topN3);

%% Do an intersection of the three
data = tcisc(check1 & check2 & check3, :);