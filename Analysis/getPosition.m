function output = getPosition(stimName)
% Selects one of two methods to get position data, based on stim name.
% TriCOPA position data has some quirks that needed a special function,
% while MW is theoretically more generalizable.

% Check whether position data is saved and ready to load
p = specifyPaths('..');

% Determine stim type from stim name somehow
if nargin > 0
    [~,stimType] = findVidPath(stimName);
    f = false;
else
    stimType = 'TC'; % default
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
    % Do the other method
    % Convert extension from .mov to .mat
    [~,x,~] = fileparts(stimName); 
    fname = [x, '.mat'];
    % Try loading position data
    fpath1 = fullfile(p.pos, fname);
    if exist(fpath1, 'file')
        output(1).StimName = x;
        output(1).Data = importdata(fpath1);
    else
        % Load LabelSession data and convert to usable format
        fpath2 = fullfile(p.analysis,'LabelSessionExports', fname);
        gTruth = importdata(fpath2);
        output(1).StimName = x;
        output(1).Data = extractPosition2(gTruth);
    end
end