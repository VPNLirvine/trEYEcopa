function output = getPosition(input)
% Selects one of two methods to get position data, based on stim name.
% TriCOPA position data has some quirks that needed a special function,
% while MW is theoretically more generalizable.

% Check whether position data is saved and ready to load
p = specifyPaths('..');

% Determine stim type from stim name somehow
if nargin > 0
    flag = nameOrType(input);
    switch flag
        case 'name'
            % Just one video. Find its type.
            stimName = input;
            [~,stimType] = findVidPath(stimName);
            f = false;
        case 'type'
            % We want ALL videos from this stimulus set.
            stimType = input;
            f = true;
    end 
else
    % Get all TC data by default
    stimType = 'TC';
    f = true;
end

if strcmp(stimType, 'TC')
    % Do the TriCOPA method
    if f
        % No input ~= empty input
        tmp = getTCPosition();
    else
        tmp = getTCPosition(stimName);
    end
    tmp = interpPosition(tmp); % edit this to accept struct format?
    % Keep postab2struct here for now, just to let this run.
    % But ideally, edit getTCPosition to output in struct form
    for i = 1:height(tmp)
        output(i).StimName = tmp.StimName{i};
        output(i).Data = postab2struct(tmp);
    end
else
    % Extract with this alternate method
    if f
        % Find a list of stims
        p = specifyPaths('..');
        if strcmp(stimType, 'MW')
            % No position data for mechanical videos, so exclude from list.
            fullList = readtable(fullfile(p.analysis,'MWConditionList.csv'));
            stimList = fullList.NAME(strcmp(fullList.CONDITION, 'social'));
        else
            % Here's a format for getting your stimlist otherwise.
            pth = p.MWstim; % edit this
            stimList = dir(fullfile(pth,'*.mov'));
            stimList = {stimList.name};
        end
    else
        % Just do the one. But for compatibility, put in a cell.
        stimList{1} = stimName;
    end
    for i = 1:length(stimList)
        stimName = stimList{i};
        % Convert extension from .mov to .mat
        [~,x,~] = fileparts(stimName); 
        fname = [x, '.mat'];
        % Try loading position data
        fpath1 = fullfile(p.pos, fname);
        if exist(fpath1, 'file')
            output(i).StimName = x;
            output(i).Data = importdata(fpath1);
        else
            % Load LabelSession data and convert to usable format
            fpath2 = fullfile(p.analysis,'LabelSessionExports', fname);
            gTruth = importdata(fpath2);
            output(i).StimName = x;
            output(i).Data = extractPosition2(gTruth);
        end
    end % for stim
end % stimType