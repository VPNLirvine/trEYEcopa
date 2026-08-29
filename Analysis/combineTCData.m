function output = combineTCData()
% Put all gaze data into one table, with explicit names for each metric.
% Load data to export
p = specifyPaths('..');
fpath = fullfile(p.analysis, 'Results');
load(fullfile(fpath,'TC_movert.mat'), 'movert');
load(fullfile(fpath,'TC_deviance.mat'), 'deviance');
load(fullfile(fpath,'TC_isc.mat'), 'isc');
load(fullfile(fpath,'TC_scaledfixation.mat'), 'sfix');
load(fullfile(fpath,'TC_tot.mat'), 'tot');

% Set one as the reference table
output = renamevars(sfix, 'Eyetrack', 'ScaledFixation');

% Start inserting everything else
output.TimeOnTarget = tot.Eyetrack;
output.Deviance = deviance.Eyetrack;
output.ISC = isc.Eyetrack;
output.FixRT = movert.Eyetrack;

end