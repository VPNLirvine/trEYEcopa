function data = dropMech(data)
% Drop the mechanical condition Martin & Weisberg videos from analysis
% If this accidentally gets called with TC data, no problem:
% We drop the bad videos instead of keeping the good ones.
vidList = readtable('MWConditionList.csv');
badList = vidList.NAME(strcmp(vidList.CONDITION, 'mechanical'));
badCol = contains(data.StimName, badList);
data(badCol,:) = [];