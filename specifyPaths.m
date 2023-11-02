function pths = specifyPaths()
% Outputs a struct that defines the paths for everything you need
% Critically, they're all relative to this root directory

pths.root = pwd;
pths.stims = fullfile(pths.root, 'stims');
pths.MW = fullfile(pths.stims, 'Martin Weisberg');
pths.TC = fullfile(pths.stims, 'TriCOPA');
pths.frames = fullfile(pths.root, 'frames');
end