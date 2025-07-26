function pths = specifyPaths(varargin)

% Define base directory everything else is relative to
% Allow an input to serve as the base dir
if nargin == 0
    % Default value is the location of this function
    pths.base = fileparts(mfilename("fullpath"));
else
    base = varargin{1};
    assert(ischar(base), 'Input to specifyPaths must be a string!')
    assert(exist(base, 'dir') > 0, 'Provided path %s does not exist!', base);

    % In case input is e.g. '..', convert to an actual path
    [~, info] = fileattrib(base);
    % Store path
    pths.base = info.Name;
end

pths.analysis = fullfile(pths.base, 'Analysis');
pths.data = fullfile(pths.base, 'data', 'source');
    pths.MWdat = fullfile(pths.data, 'MW');
    pths.TCdat = fullfile(pths.data, 'TC');
    pths.NARdat = fullfile(pths.data, 'NAR');
    pths.fixdat = fullfile(pths.data, 'fixation_checks');
pths.matdata = fullfile(pths.base, 'data', 'derivatives');
    pths.MWmat = fullfile(pths.matdata, 'MW');
    pths.TCmat = fullfile(pths.matdata, 'TC');
    pths.NARmat = fullfile(pths.matdata, 'NAR');

pths.stimuli = fullfile(pths.base, 'stims');
    pths.MWstim = fullfile(pths.stimuli, 'MartinWeisberg');
    pths.TCstim = fullfile(pths.stimuli, 'TriCOPA'); % verify contents
    
pths.frames = fullfile(pths.base, 'frames');
pths.edf = fullfile(pths.base, 'edfImport');
pths.edfalt = fullfile(pths.base, 'edf_alt');

pths.beh = fullfile(pths.base, 'beh'); % behavioral data e.g. RTs
pths.pos = fullfile(pths.analysis, 'Position'); % adjusted position data
pths.map = fullfile(pths.analysis, 'motionMaps'); % stim motion heatmaps
pths.mot = fullfile(pths.analysis, 'motionData'); % optic flow values

pths.fixcheck = fullfile(pths.base, 'fixation_checks'); % calibration
end