clear; clc;
PsychDebugWindowConfiguration(0,1)
% Ask for a button response 1-5.
% Give visual feedback of which response is selected.
% Continuously update the response until a set timer runs out.
% Press escape to exit early.

response = -1;
lastPressed = -1;
maxWait = 10;
escKey = KbName('ESCAPE');
keyList(1) = KbName('1!');
keyList(2) = KbName('2@');
keyList(3) = KbName('3#');
keyList(4) = KbName('4$');
keyList(5) = KbName('5%');

qText = 'Pick a number 1-5';
respChoices = {'1', '2', '3', '4', '5'}; % not used yet
numResps = length(respChoices);

try
[w, wRect] = Screen('OpenWindow',0,255); %prepare the Screen for stimulus control
ScreenClut = [ [0:255]', [0:255]', [0:255]'];
ScreenBkgd = round(255/2); % mid gray
TextColor = 0; % black
ChoiceColor = 255; % white
% Calculate a gap size: come in 10% on both ends (or 80% of total width),
% then if you have e.g. 3 items, you need the size of 2 gaps. So n-1. 
respOffset = round((.8 * wRect(3)) / (numResps - 1));
qHeight = .25 * wRect(4);

Screen('LoadClut', w, ScreenClut);
Screen('FillRect', w, ScreenBkgd, wRect); % fill bkgd with mid-gray
Screen('TextSize', w, 0.05 * wRect(4)); % set global font size


DrawFormattedText(w, qText, 'center', qHeight, TextColor);
for i = 1:numResps
    % NOT PERFECT - debug
    offset = (.1 * wRect(3)) + (respOffset * (i-1)); % 
    if i == response
        DrawFormattedText(w, respChoices{i},  offset, 'center', ChoiceColor);
    else
        DrawFormattedText(w, respChoices{i}, offset, 'center', TextColor);
    end
end

screenFlipR = Screen('Flip', w); 

% BEGIN
while GetSecs <= screenFlipR + maxWait
    % poll for input
    FlushEvents('keyDown'); %get rid of any old keypresses
    [~, pressedSecs, keypressCode] = KbCheck();
    pressedKeys = find(keypressCode);
    if ismember(escKey, pressedKeys)
        break
    end
    
    if any(ismember(pressedKeys,keyList))
        response = find(pressedKeys(1) == keyList); % in case of multiples
        % This is still the KeyCode, not the choice number
    end
    
    if response ~= lastPressed
        % update display
        DrawFormattedText(w, qText, 'center', qHeight, TextColor);
        for i = 1:numResps
            % NOT PERFECT - debug
            offset = (.1 * wRect(3)) + (respOffset * (i-1));
            if i == response
                DrawFormattedText(w, respChoices{i}, offset, 'center', ChoiceColor);
            else
                DrawFormattedText(w, respChoices{i}, offset, 'center', TextColor);
            end
        end
        Screen('Flip', w);
        lastPressed = response;
        % restart - allow updating the response until the timeout
    end
    
end

Screen('CloseAll'); %

catch ME
    Screen('CloseAll');
    rethrow(ME)
end