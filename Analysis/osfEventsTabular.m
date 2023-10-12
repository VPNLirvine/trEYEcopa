function osfEventsTabular(Trials, trialNum)

fprintf("%10s %10s %10s %5s %20s\n", "timepoint", "sttime", "entime", "type", "message")

for i = 1:length(Trials(trialNum).Events.sttime)
    fprintf("%10d %10d %10d %5d   ", i, Trials(trialNum).Events.sttime(i), Trials(trialNum).Events.entime(i), Trials(trialNum).Events.type(i))
    fprintf(replace(Trials(trialNum).Events.message{i},char(10),' '))
    fprintf('\n')
end

end

