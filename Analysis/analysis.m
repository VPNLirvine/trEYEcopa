function analysis(varargin)
% Perform statistical analysis on eyetracking data

% Optional input 1 should be a metric name listed in selectMetric()
if nargin > 0
    metricName = varargin{1};
else
    % By default, use percent time spent fixating
    metricName = 'scaledfixation';
end

% The exact test depends on which stimulus set we're looking at
% So force a choice:
choice = menu('Which data do you want to analyze?','TriCOPA','Martin & Weisberg');

if choice == 1
    % TriCOPA
    fprintf(1, 'Using metric %s\n\n', metricName);
    if strcmp(metricName, 'ISC')
        data = sortISC;
    else
        data = getTCData(metricName);
    end
    numSubs = height(unique(data.Subject));

    %
    % Compare the eyetracking data to the behavioral data
    %
    figure();
    mdl = fitlm(data, 'Eyetrack ~ Response');
    plot(mdl);
        xlabel('Intentionality score');
        ylabel(getGraphLabel(metricName));
        title(sprintf('Linear model based on %i subjects', numSubs));
    disp(mdl);
    % Run some stats here
    
    
elseif choice == 2
    % Martin & Weisberg
    % Pipeline was already built, just call here:
    Ttest();
end