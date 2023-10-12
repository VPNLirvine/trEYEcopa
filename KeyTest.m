function [varargout] = KeyTest

KbName('UnifyKeyNames');

leftKey = KbName('4$');
rightKey = KbName('6^');
trigger = KbName('5%');

fprintf(1, 'Left Key: %i, Right Key: %i, Trigger: %i\n', leftKey, rightKey, trigger);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KbQueue
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cont = input('\n\nTry with KbQueue? (y/n)\n', 's');
% 
% if strcmp(upper(cont), 'Y')
% 
%     KbQueueCreate;% %sets up the queue
% 
%     KbQueueStart; %start listening for keypresses
%     fprintf(1, '\nPress the left Key\n');
%     start = GetSecs;
%     [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck; %check in
%     while firstPress(leftKey) == 0 & (GetSecs - start) < 3
%         [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck;
%     end
%     if firstPress(leftKey) ~= 0
%         fprintf(1, 'Caught the left keypress\n');
%     else
%         fprintf(1, 'Timed out.\n');
%     end
% 
%     fprintf(1, '\nPress the right Key\n');
%     start = GetSecs;
%     [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck; %check in
%     while firstPress(rightKey) == 0 & (GetSecs - start) < 3
%         [pressed, firstPress, firstRelease, lastPress, lastRelease] = KbQueueCheck;
%     end
%     if firstPress(rightKey) ~= 0
%         fprintf(1, 'Caught the left keypress\n');
%     else
%         fprintf(1, 'Timed out.\n');
%     end
%     KbQueueStop; %stop listening
% 
%     KbQueueRelease
% 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KbCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cont = input('\n\nTry with old KbCheck? (y/n)\n', 's');

if strcmp(upper(cont), 'Y')
    fprintf(1, 'Press the left Key\n');
    FlushEvents('keyDown');
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    start = GetSecs;
    while keyCode(leftKey) == 0 & (GetSecs - start < 3)
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    end
    if keyCode(leftKey) == 1
        fprintf(1, 'Caught the left keypress\n');
    else
        fprintf(1, 'Timed out.\n');
    end

    
    fprintf(1, 'Press the right Key\n');
    FlushEvents('keyDown');
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    start = GetSecs;
    while keyCode(rightKey) == 0 & (GetSecs - start < 3)
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    end
    if keyCode(rightKey) == 1
        fprintf(1, 'Caught the right keypress\n');
    else
        fprintf(1, 'Timed out.\n');
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% POLL ALL KEYS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cont = input('\n\nListen to all keys? (y/n)', 's');

if strcmp(upper(cont), 'Y')

    fprintf(1, 'Listening for 10 seconds. Press any keys you want.\n');
    start = GetSecs;        
    while GetSecs - start < 10
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        if keyIsDown == 1
            ID = find(keyCode == 1);
            keyName = KbName(ID);
            if ischar(keyName)
                fprintf(1, 'Key ID pressed: %s (%i)\n', keyName, ID);
            else
                fprintf(1, 'Key ID pressed: %i (%i)\n', keyName, ID);
            end
        end
    end
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Check devices
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cont = input('\n\nCheck your devices? (y/n)', 's');
% 
% if strcmp(upper(cont), 'Y')
%     
%     fprintf(1, '\nThere are %i connected devices\n', PsychHID('NumDevices'));
%     devices=PsychHID('Devices');
% else
%     devices = {};
% end
% 
% if nargout == 1
%     varargout{1} = devices;
% end
% 




