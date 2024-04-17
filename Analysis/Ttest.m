function Ttest(varargin)
% Analyzes eyetracking data by reading in EDF files
% Calculates a t-test, then generates plots
% Optional input specifies a metric, e.g. mean fixation time
% Hardcodes to analyze Martin & Weisberg social v mechanical data

% Set variable
if nargin > 0
    metricName = varargin{1};
else
    % What metric to analyze - see selectMetric
    % By default, use percent time spent fixating
    metricName = 'scaledfixation';
end
fprintf(1, 'Using metric %s\n\n', metricName);

% Declare constants
T = readtable('condition list - Sheet1.csv');
socCellArr = T.NAME(string(T.CONDITION) == 'social');
mecCellArr = T.NAME(string(T.CONDITION) == 'mechanical');
addpath('..'); % to allow specifyPaths to run
pths = specifyPaths('..');
stimPath = pths.MWstim;
outputPath = pths.MWdat;

stimList = dir(fullfile(stimPath, '*.mov'));
% for idx = 1:length(fList)
%     vidList{idx} = fList(idx).name;
% end

% Collect references to all edf files that exist in the outputPath
edfList = dir(strcat(outputPath, '/*.edf')); 
% edfList = dir(strcat(outputPath, '/MW_14.edf'));
% for j = 1:length(subList)
%     name(j) = split(subList
% 
% orderPresent = 1:length(vidList)


s = struct;
for subject = 1:length(edfList)
    fprintf(1, 'Reading from %s...\n', edfList(subject).name);
    presentOrder = 1:16; %%%%%%%%%%%%%%
    % Accumulate all average fixations for Social condition
    socFix = zeros(1,8);
    
    % Accumulate all average fixations for Social condition
    mecFix = zeros(1,8);
    
    socNum = 0;
    mecNum = 0;
    socMovies = {};
    mecMovies = {};
    Trials = osfImport(edfList(subject).name);
    
    for trial = 1:length(Trials)
        % Determine which movie was actually presented
        stimName = getStimName(Trials(trial));

        % Organize data by condition
        if ismember(stimName, socCellArr)
%         if ismember(erase(stimList(presentOrder(trial)).name, ".MOV"), socCellArr)
            socNum = socNum + 1;
%             socMovies{socNum} = stimList(presentOrder(trial)).name;
            socMovies{socNum} = stimName;
            socFix(socNum) = selectMetric(Trials(trial), metricName);
        elseif ismember(stimName, mecCellArr)
%         elseif ismember(erase(stimList(presentOrder(trial)).name, ".MOV"), mecCellArr)
            mecNum = mecNum + 1;
%             mecMovies{mecNum} = stimList(presentOrder(trial)).name;
            mecMovies{mecNum} = stimName;
            mecFix(mecNum) = selectMetric(Trials(trial), metricName);
        end
        
    end
    
    assert(socNum == 8, "A social trial is missing for sub %d", subject)
    assert(mecNum == 8, "A mechanical trial is missing for sub %d", subject)
    
    s(subject).socMovies = socMovies;
    s(subject).mecMovies = mecMovies;
    s(subject).socFixations = socFix;
    s(subject).mecFixations = mecFix;
end

aggregateSocFix = [];
aggregateMecFix = [];

for subject = 1:length(s)
%     aggregateSocFix = [aggregateSocFix sum(s(subject).socFixations)];
%     aggregateMecFix = [aggregateMecFix sum(s(subject).mecFixations)];
%     aggregateSocFix = [aggregateSocFix mean(s(subject).socFixations)];
%     aggregateMecFix = [aggregateMecFix mean(s(subject).mecFixations)];
    aggregateSocFix = [aggregateSocFix s(subject).socFixations];
    aggregateMecFix = [aggregateMecFix s(subject).mecFixations];
end

[y, subList, condList, trialList] = prepforanova(s);
% Just modeling condition says F = 2.16, p = 0.14
%     anovan(y,{condList}, 'varnames', {'Condition'});

% Adding subjectID as an RFX produces F = 5.41 p = 0.02
anovan(y, {condList, subList}, 'varnames', {'Condition', 'SubID'}, 'random', [2]);

% Adding subNum and stimName as RFX says F = 0 p = NaN for condition
% This has modeled away all the variance, leaving no residuals to analyze.
% Would need repeats of each stimulus to use this method.
% anovan(y, {condList, subList, trialList}, 'varnames', {'Condition', 'SubID', 'Stimulus'}, 'random', [2, 3]);


[h,p,~,stats] = ttest2(aggregateSocFix,aggregateMecFix);
hlist = {'Fail to reject', 'Reject'};
fprintf("\n\n\n")
fprintf("%d subjects were considered.\n", subject)
fprintf("%s the null hypothesis\n",hlist{h+1})

disp(stats)
fprintf("\tp = %f\n",p) % stats are indented

boxPlot2(metricName, y, s, condList, edfList); % Generates figures

function [dataMatrix, subList, condList, trialList] = prepforanova(inStruct)
% Take a structure with fixation data for separate conditions, per subject
% Export one long data matrix with columns for condition labels

numSubs = length(inStruct);
numSoc = length(inStruct(1).socFixations);
numMec = length(inStruct(1).mecFixations); % should both be 8, total 16
numRows = numSubs * (numSoc + numMec);
% Order is data, subNum, conditionID, trialID
dataMatrix = zeros(numRows, 1);
    subList = dataMatrix;
    condList = cell(numRows, 1);
    trialList = condList;
for i = 1:numSubs
    for c = 1:2 % condition social or mechanical
        if c == 1
            thisDat = inStruct(i).socFixations;
        else
            thisDat = inStruct(i).mecFixations;
        end
        for t = 1:numSoc % trial number - assume equal number per cond
            idx = t + ((i-1)*(numSoc*2)) + ((c-1)*numSoc); % nested position
            % Export data
            dataMatrix(idx) = thisDat(t); % fixation time
            subList(idx) = i; % subject number
            % Condition ID
            if c == 1
                condList{idx} = 'Social';
                stimName = inStruct(i).socMovies{t};
            else
                condList{idx} = 'Mechanical';
                stimName = inStruct(i).mecMovies{t};
            end
            % Stimulus name
            trialList{idx} = stimName;
        end % for trial
    end % for condition
end % for sub

end % prepforanova

end % main function