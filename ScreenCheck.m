clear; clc;
PsychDebugWindowConfiguration(0,1)

[w, wRect] = Screen('OpenWindow',0,255); %prepare the Screen for stimulus control
ScreenClut = [ [0:255]', [0:255]', [0:255]'];
Screen('LoadClut', w, ScreenClut);
Screen('FillRect', w, 255, wRect);



im1 = imread('blank.jpg');
im = floor(mean(im1, 3));
% im = 256 - rgb2ind(im1, 256);
stimRect = [0 0 size(im, 2) size(im, 1)];
txID = Screen('MakeTexture', w, im);


% put up background screen
Screen('DrawTexture', w, txID, stimRect, CenterRect(stimRect, wRect));
test = Screen('GetImage', txID);
Screen('Flip', w);


%%%%%%%%% for debugging -- remove this for expt
escKey = KbName('ESCAPE');
FlushEvents('keyDown'); %get rid of any old keypresses
[keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
maxWait = 10;

start = GetSecs;
while keyCode(escKey) == 0 && GetSecs - start < maxWait
     [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
end
Screen('CloseAll')

