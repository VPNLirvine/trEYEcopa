function stimParams = combineStimParams(stype)
% Motion, Duration, and Interactivity are stored separately
% They're also stored in different orders, for some reason
% This function puts them all in one table, for convenience.
assert(any(strcmp(stype, {'TC', 'MW'})), 'First input must indicate TC or MW');
p = specifyPaths('..');
f1 = fullfile(p.mot, [stype, '_motionData.mat']);
f2 = fullfile(p.int, [stype, '_interactData.mat']);
load(f1, 'motion');
load(f2, 'intScore');
stimParams = motion;
for v = 1:height(stimParams)
    stimParams.Motion(v) = sum(stimParams.MotionEnergy{v});
    vidName = stimParams.StimName{v};
    vl = strcmp(intScore.StimName, vidName);
    if any(vl)
        stimParams.Interactivity(v) = intScore.Interactivity(vl);
    else
        stimParams.Interactivity(v) = nan;
    end
end
stimParams.Duration = cell2mat(stimParams.Duration);

