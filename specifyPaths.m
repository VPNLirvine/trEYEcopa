function pths = specifyPaths()
pths.base = pwd;
pths.analysis = fullfile(pths.base, 'Analysis');
pths.data = fullfile(pths.base, 'ExpOutputs'); % but rename to 'data'
    pths.MWdat = fullfile(pths.data, 'MWoutput');
    pths.TCdat = fullfile(pths.data, 'TCoutput');
    pths.fixdat = fullfile(pths.data, 'fixation_checks');

pths.stimuli = fullfile(pths.base, 'stims'); % verify
    
pths.frames = fullfile(pths.base, 'frames'); % verify
pths.edf = fullfile(pths.base, 'edfImport');
pths.beh = fullfile(pths.base, 'beh'); % behavioral data e.g. RTs
end