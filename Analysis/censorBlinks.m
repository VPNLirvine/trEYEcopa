function [output, bs] = censorBlinks(output, edfDat)
% Reject blink data and interpolate replacement values
% But the default blink detection is slightly too conservative,
% so pad the given values to catch on/off artifacts
% These are round numbers based on qualitative assessment of one subject.
if isfield(edfDat, 'Blinks') && ~isempty(edfDat.Blinks)
    st = edfDat.Blinks.sttime - 50;
    en = edfDat.Blinks.entime + 150;
    blinkDurs = cell2mat(arrayfun(@(start, stop) start:stop, st, en, 'UniformOutput', false));
        blinkDurs = single(blinkDurs);
    gazeTimes = edfDat.Samples.time - edfDat.Header.rec.time;
        gazeTimes = single(gazeTimes);
    % Can't index directly with blinkDurs since it may have extra vals
    % So first, find the values in blinkDurs that exist in gazeTimes
    bs = ismember(gazeTimes, blinkDurs); % blink samples
    % Now interpolate the values for bs based on everything else
    output(:,bs) = interp1(gazeTimes(~bs), output(~bs), gazeTimes(bs), 'makima');

    % but don't output the number with the buffer

else
    % 'output' is the input, so don't need to define it
    % but if no blinks were found, return an empty vector
    bs = [];
end

end
