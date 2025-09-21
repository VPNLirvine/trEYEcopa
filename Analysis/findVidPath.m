function [fpath, varargout] = findVidPath(movName)
% Given the name of a file, determine the folder it exists in
pths = specifyPaths('..');

% Ensure we have a file extension attached
[~,~,ext] = fileparts(movName);
if ~strcmpi(ext, '.mov')
    movName = [movName '.mov'];
end

% Define your three options
x = fullfile(pths.TCstim, 'normal', movName);
y = fullfile(pths.TCstim, 'flipped', movName);
z = fullfile(pths.MWstim, movName);

% Check each option in sequence
if exist(x, 'file')
    % TriCopa normal orientation
    fpath = x;
    stimType = 'TC';
elseif exist(y, 'file')
    % TriCopa flipped orientation
    fpath = y;
    stimType = 'TC';
elseif exist(z, 'file')
    % Martin & Weisberg (only one orientation)
    fpath = z;
    stimType = 'MW';
else
    error('File %s not found in any stim folder!', movName)
end % if

if nargout > 1
    varargout{1} = stimType;
end % function