function motion = reportMotionStats(stype)
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
        % Fetch category labels for each video
        stimList = readtable('MWConditionList.csv');
        % Establish mapping between motion table and label table
        stimList = sortrows(stimList, 1); % Assumes both have stimName as 1
        motion = sortrows(motion, 1);
        socInds = strcmp(stimList.CONDITION, 'social');
        mecInds = strcmp(stimList.CONDITION, 'mechanical');
        % Write category labels into motion table
        motion.Condition = stimList.CONDITION;
        
        % Sum the motion energy per video
        for i = 1:height(motion)
            motion.total(i) = sum(motion.MotionEnergy{i});
            motion.Rate(i) = motion.total(i) / motion.Duration{i};
        end
        % Perform a t-test between categories
        [h,p,ci,stats] = ttest2(motion.total(socInds),motion.total(mecInds));
        % Report the statistics
        t = {'is not', 'is'};
        fprintf(1, '\nConsidering motion energy:\n');
        fprintf(1, '\tThere %s a significant difference between conditions\n', t{h+1})
        fprintf(1, '\tt(%i) = %0.2f, p = %0.3f\n', stats.df, stats.tstat, p(1));
        fprintf(1, '\tSocial = %0.1f (SD = %0.1f), ', mean(motion.Rate(socInds)) / deg2pix(1), std(motion.Rate(socInds)) / deg2pix(1));
        fprintf(1, '\tMechanical = %0.1f (SD = %0.1f)', mean(motion.Rate(mecInds)) / deg2pix(1), std(motion.Rate(mecInds)) / deg2pix(1));
        fprintf(1, '\n');
    case 'TC'
        % Report correlations between Motion, Interactivity, and Duration
        intScore = importdata('interactData/TC_interactData.mat'); % get dynamically
        % Ensure both are sorted the same way
        intScore = sortrows(intScore, 1);
        motion = sortRows(motion, 1);
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