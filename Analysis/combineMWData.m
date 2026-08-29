function output = combineMWData()
% Put all DVs into one table before sending to exportResults().
% M&W requires special attention because of the Condition variable:
% We dropped the mechanical condition trials entirely from the ToT table,
% because those metrics can't be calculated if there are no characters.
% So now we need to insert NaNs for those mechanical condition trials,
% so that we can have separate columns for each DV in one nice table.

% Use fixation duration as the reference table
fpath = 'Results';
f1 = fullfile(fpath, 'MW_fix.mat');
mwfix = importdata(f1);

% Parse the other variables
tot = nan([height(mwfix), 1]);
dev = tot;
isc = tot;
rt = tot;
f2 = fullfile(fpath, 'MW_tot.mat');
f3 = fullfile(fpath, 'MW_deviance.mat');
f4 = fullfile(fpath, 'MW_isc.mat');
f5 = fullfile(fpath, 'MW_movert.mat');
mwtot = importdata(f2);
mwdev = importdata(f3);
mwisc = importdata(f4);
mwrt = importdata(f5);
for i = 1:height(mwfix)
    subName = mwfix.Subject{i};
    vidName = mwfix.StimName{i};
    % inelegant but it works:
    match1 = strcmp(mwtot.Subject, subName) & strcmp(mwtot.StimName, vidName);
    match2 = strcmp(mwdev.Subject, subName) & strcmp(mwdev.StimName, vidName);
    match3 = strcmp(mwisc.Subject, subName) & strcmp(mwisc.StimName, vidName);
    match4 = strcmp(mwrt.Subject, subName) & strcmp(mwrt.StimName, vidName);
    if any(match1)
        tot(i) = mwtot.Eyetrack(match1);
    end
    if any(match2)
        dev(i) = mwdev.Eyetrack(match2);
    end
    if any(match3)
        isc(i) = mwisc.Eyetrack(match3);
    end
    if any(match4)
        rt(i) = mwrt.Eyetrack(match4);
    end
end

% Put everything into one variable for output
output = table();
output.Subject = mwfix.Subject;
output.Category = mwfix.Category;
output.StimName = mwfix.StimName;
output.ScaledFixation = mwfix.Eyetrack;
output.TimeOnTarget = tot;
output.Deviance = dev;
output.ISC = isc;
output.FixRT = rt;
end