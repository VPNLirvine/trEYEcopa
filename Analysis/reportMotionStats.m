function reportMotionStats(stype)
% Check for stored motion data
fname = [stype, '_motionData.mat'];
fpath = fullfile(pwd, 'motionData', fname);
if ~exist(fpath, 'file')
    motion = getMotionEnergy('eng', stype);
else
    motion = importdata(fpath);
end

switch stype
    case 'MW'
        % Assign category labels to each video
        % ...find them from stim csv?
        socInds = [];
        mecInds = [];
        motion.Category(socInds) = 'social';
        motion.Category(mecInds) = 'mechanical';
        % Import video duration
        load('MWstimParams.mat');
        
        % Sum the motion energy per video
        for i = 1:height(motion)
            motion.total(i) = sum(motion.MotionEnergy{i});
            motion.Rate(i) = motion.total(i) / motion.Duration{i};
        end
        % Perform a t-test between categories
        [h,p,ci,stats] = ttest2(motion.totalMotion(s),motion.totalMotion(m));
        % Report the statistics
        t = {'is not', 'is'};
        fprintf(1, 'There %s a significant difference between categories\n', t{h+1})
        fprintf(1, 't(%i) = %0.2f, p = %0.3f\n', stats.df, stats.tstat, p(1));
        fprintf(1, 'Social = %0.1f (SD = %0.1f), ', mean(motion.Rate(socInds)) / deg2pix(1), std(motion.Rate(socInds)) / deg2pix(1));
        fprintf(1, 'Mechanical = %0.1f (SD = %0.1f)', mean(motion.Rate(mecInds)) / deg2pix(1), std(motion.Rate(mecInds)) / deg2pix(1));

    case 'TC'
        % Report correlations between Motion, Interactivity, and Duration
        intScore = importdata('interactData/TC_interactData.mat'); % get dynamically
        % Motion is sorted alpha, int is not. Adjust:
        intScore = sortrows(intScore);
        motion.Duration = cell2mat(motion.Duration);
        for i = 1:height(motion)
            motion.total(i) = sum(motion.MotionEnergy{i});
            motion.Rate(i) = motion.total(i) / motion.Duration(i);
        end
        [c1,p1] = corr(motion.total, motion.Duration, 'Type', 'Spearman');
        [c2,p2] = corr(intScore.Interactivity, motion.Duration, 'Type', 'Spearman');
        [c3,p3] = corr(motion.total, intScore.Interactivity, 'Type', 'Spearman');
        var1 = getGraphLabel('motion');
        var2 = getGraphLabel('duration');
        var3 = getGraphLabel('interact');
        fprintf(1,'\n');
        fprintf(1, 'Correlation between %s and %s:\n', var1, var2)
        fprintf(1, '\t\x03C1 = %0.2f, p = %0.4f\n', c1, p1);
        fprintf(1, 'Correlation between %s and %s:\n', var3, var2)
        fprintf(1, '\t\x03C1 = %0.2f, p = %0.4f\n', c2, p2);
        fprintf(1, 'Correlation between %s and %s:\n', var1, var3)
        fprintf(1, '\t\x03C1 = %0.2f, p = %0.4f\n', c3, p3);
end