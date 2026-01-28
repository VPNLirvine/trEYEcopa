metricName = 'sfix';
data = getTCData(metricName);
[var1, yl] = getGraphLabel(metricName);
histogram(data.Eyetrack);
        xlabel(var1);
        title('Expect an RT-like distribution');

numSubs = length(unique(data.Subject));
% Where are the tails coming from??
minthresh = .3;
maxthresh = .8;

lowSubs = data.Subject(data.Eyetrack < minthresh);
highSubs = data.Subject(data.Eyetrack > maxthresh);
lowVids = data.StimName(data.Eyetrack < minthresh);
highVids = data.StimName(data.Eyetrack > maxthresh);

fprintf(1,'\n');
fprintf(1, '%i unique subs > %0.1f (of %i subs total)\n', length(unique(highSubs)), maxthresh, numSubs);
fprintf(1, '%i unique vids > %0.1f\n', length(unique(highVids)), maxthresh);
fprintf(1, '%i unique subs < %0.1f (of %i subs total)\n', length(unique(lowSubs)), minthresh, numSubs);
fprintf(1, '%i unique vids < %0.1f\n', length(unique(lowVids)), minthresh);
fprintf(1,'\n');

lowList = data(data.Eyetrack < minthresh, :);