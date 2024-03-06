keyIsDown = 0;
clear PsychHID
while ~keyIsDown
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck();
%     if strcmp(KbName(keyCode),1 'ErrorRollOver')
%         keyIsDown = 0;
%     end
end