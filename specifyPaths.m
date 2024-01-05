function pths = specifyPaths()
pths.base = pwd;
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