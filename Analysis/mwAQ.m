function mwAQ(data, aqTable)
% Try to correlate the within-subject effect size with AQ
subList = unique(data.Subject);
numSubs = length(subList);
efSz = zeros([numSubs, 1]);
figure('Name', 'AQ vs Effect Size');
for a = 1:3 % aq subscales
    aq = zeros([numSubs, 1]);
    for s = 1:numSubs
        subID = subList{s};
        % Extract the effect size for this subject
        % This shouldn't change depending on AQ subscale,
        % but I'm too lazy to make two independent loops
        subset = strcmp(data.Subject, subID);
        soc = strcmp(data.Category, "social");
        mec = strcmp(data.Category, "mechanical");
        socdat = data.Eyetrack(subset & soc);
        mecdat = data.Eyetrack(subset & mec);
        % Calculate Cohen's d: mean difference over shared variance
        efSz(s) = (mean(socdat) - mean(mecdat)) / std(data.Eyetrack(subset));

        % Extract the right AQ score for this subscale
        if a == 1
            aq(s) = aqTable.SocialSkills(strcmp(subID, aqTable.SubID));
            aqt = 'AQ1';
        elseif a == 2
            aq(s) = aqTable.Communication(strcmp(subID, aqTable.SubID));
            aqt = 'AQ2';
        elseif a == 3
            aq(s) = aqTable.AttentionDetail(strcmp(subID, aqTable.SubID));
            aqt = 'AQ3';
        end
    end
    [aqL, xl] = getGraphLabel(aqt);

    % Report the correlation for this subscale
    [c, p] = corr(efSz, aq, 'Type', 'Spearman');
    h = p <= 0.05;
    h1 = {' not ', ' '};
    fprintf(1, '%s is%scorrelated with within-subject effect size: r = %0.3f, p = %0.3f\n', aqL, h1{h+1}, c, p);

    subplot(1,3,a);
    scatter(aq, efSz);
    xlabel(aqL);
    xlim(xl);
    ylabel('Cohen''s d');
    ylim([-2, 2]);
    title(sprintf('r = %0.3f, p = %0.3f', c, p))

end
end