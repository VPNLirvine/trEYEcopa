% Plot scanpath in new window
figure();
plot(Trials(trial).Fixations.gavx, Trials(trial).Fixations.gavy);
xlim([0,1900]);
ylim([0,1200]);
j = (sub - 1) * 16 + trial;
title(['Sub ' num2str(sub) ' ' stimName ' scanpath']);