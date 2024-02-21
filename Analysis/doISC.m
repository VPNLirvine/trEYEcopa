function ISC = doISC()
% get intersubject correlations of scan paths
data = getTCData('heatmap');

subList = unique(data.Subject);
stimList = unique(data.StimName);

numSub = length(subList);
numStims = length(stimList);

% Init the output variable
ISC = table('Size', [numStims, numSub+2], 'VariableNames', [{'StimName'}; {'GroupAverage'}; cellstr(subList)], 'VariableTypes', [{'string'}; {'cell'}; cellstr(repmat('double', [numSub, 1]))]);
numExtra = width(ISC) - numSub;

% First, get a group-average heatmap for each stimulus
groupAverage = struct;
for v = 1:numStims
    thisStim = stimList{v};
    ISC.StimName(v) = thisStim;
    thisData = data.Eyetrack(strcmp(thisStim,data.StimName));
    % Stack all the heatmaps into a 3D matrix
    imStack = [];
    for e = 1:size(thisData, 1)
        imStack(:,:,e) = thisData{e};
    end
    % Now average across the 3rd dimension
    ISC.GroupAverage{v} = mean(imStack, 3);
end

% isc = nan([numSub, 1]);
% for s = 1:numSub
%     % Do stuff per trial
%     numTrials = height(data(s).beh);
%     for t = 1:numTrials
%         % See if this trial exists for subject 2


for s = 1:numSub
    % Analyze correlations of each subject to the group average
    subDat = data(strcmp(data.Subject, subList{s}), :);
    numTrials = height(subDat);
    for t = 1:numTrials
        tname = subDat.StimName{t};
        % Figure which trial you need from the group stack
        ind = find(strcmp(tname, ISC.StimName));
        % Compare this subject to the group average
        heatmap1 = subDat.Eyetrack{t};
        heatmap2 = ISC.GroupAverage{ind};
        
        % Now correlate the heatmaps
        ISC(ind, s+numExtra) = {corr2(heatmap1, heatmap2)};
    end
end
% So now what?
end