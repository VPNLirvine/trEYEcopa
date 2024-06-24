function fpath = findVidPath(movName)
% Given the name of a file, determine the folder it exists in
pths = specifyPaths('..');

% Ensure we have a file extension attached
if ~strcmpi(movName(end-3:end), '.mov')
    movName = [movName '.mov'];
end

% Define your three options
x = fullfile(pths.TCstim, 'normal', movName);
y = fullfile(pths.TCstim, 'flipped', movName);
z = fullfile(pths.MWstim, movName);

% Check each option in sequence
if exist(movName, 'file')
    % If it's in the current Matlab path, then just go with that
    fpath = movName;
elseif exist(x, 'file')
    % TriCopa normal orientation
    fpath = x;
elseif exist(y, 'file')
    % TriCopa flipped orientation
    fpath = y;
elseif exist(z, 'file')
    % Martin & Weisberg (only one orientation)
    fpath = z;
else
    error('File %s not found in any stim folder!', movName)
end % if

end % function