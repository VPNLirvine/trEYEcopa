% Main script for analyzing the eyetracking data

pths = specifyPaths();
addpath(pths.base); % to allow specifyPaths to work later on

cd(pths.analysis);

Ttest();