function aqStats()
% Reports descriptive statistics for AQ subscales and generates histogram

% Load table with each subject's AQ score (ie no repeats by trial)
aq = getAQ(specifyPaths('..'));
% Get list of variables to analyze
% Could also do this using aq.Properties.VariableNames
% Either way, trying to avoid including SubID since it's not a number
varNames = {'AQ', 'SocialSkills', 'Communication', 'AttentionDetail'};
stats = {'mean', 'std', 'min', 'max', 'range'};

aqSubset = aq{:,contains(aq.Properties.VariableNames, varNames)};

% groupsummary(aq, [], stats, varNames)
% Build your own custom table that doesn't just put everything on one row
output = table();
output.Mean = mean(aqSubset)';
output.Std = std(aqSubset)';
output.Min = min(aqSubset)';
output.Max = max(aqSubset)';
output.Range = range(aqSubset)';
% Label the rows with the subscale names
output.Properties.RowNames = varNames;
% Print to screen
% disp(output);

% Generate a histogram of subscale scores
binEdges = 0:3:115;

fig = uifigure('Name', 'AQ Descriptive Statistics');
fh1 = 420*.67;
fh2 = 420*.33;
fw = 560;
bf = 10;
p1 = uipanel(fig, 'Position', [bf fh2+(2*bf) fw-(2*bf) fh1-(3*bf)]);
a1 = uiaxes(p1, 'Position', [bf bf fw-(4*bf) fh1-(5*bf)]);
    histogram(a1, aq.AQ, binEdges);
    hold(a1, 'on');
    histogram(a1, aq.SocialSkills, binEdges);
    histogram(a1, aq.Communication, binEdges);
    histogram(a1, aq.AttentionDetail, binEdges);
    hold(a1, 'off');
    legend(a1, varNames);
    xlabel(a1, 'Subscale Score');
    ylabel(a1, 'Number of subjects');
    title(a1, 'AQ scale histogram');
p2 = uipanel(fig, 'Position', [bf bf fw-(2*bf) fh2]);
    uitable(p2, 'Data', output, 'Position', [bf bf fw-(4*bf) fh2-(2*bf)]);

end % function