function pths = specifyPaths(varargin)

% Define base directory everything else is relative to
% Allow an input to serve as the base dir
if nargin == 0
    % Default value is local directory
    pths.base = pwd;
else
    base = varargin{1};
    assert(ischar(base), 'Input to specifyPaths must be a string!')
    assert(exist(base, 'dir'), 'Provided path %s does not exist!', base);

    % In case input is e.g. '..', convert to an actual path
    [~, info] = fileattrib(base);
    % Store path
    pths.base = info.Name;
end

pths.analysis = fullfile(pths.base, 'Analysis');
pths.data = fullfile(pths.base, 'ExpOutputs'); % but rename to 'data'
    pths.MWdat = fullfile(pths.data, 'MWoutput');
    pths.TCdat = fullfile(pths.data, 'TCoutput');
    pths.fixdat = fullfile(pths.data, 'fixation_checks');

pths.stimuli = fullfile(pths.base, 'stims');
    pths.MWstim = fullfile(pths.stimuli, 'MartinWeisberg');
    pths.TCstim = fullfile(pths.stimuli, 'TriCOPA'); % verify contents
    
pths.frames = fullfile(pths.base, 'frames');
pths.edf = fullfile(pths.base, 'edfImport');
pths.edfalt = fullfile(pths.base, 'edf_alt');

pths.beh = fullfile(pths.base, 'beh'); % behavioral data e.g. RTs
end