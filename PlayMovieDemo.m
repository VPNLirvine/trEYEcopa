clear;  clc;
Screen('CloseAll')

PsychJavaTrouble;   %make GetChar work (hack fix)
FalseCalltoGetSecs = GetSecs;  %call this once to speed the call up later

% Make the screen transparent to facilitate debugging
PsychDebugWindowConfiguration(0, 0.75)
AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 1);

%% open the monitor for controlling and displaying
wptr = 0;
[w, wRect] = Screen('OpenWindow',0, 255); %prepare the Screen for stimulus control


%% play the movie
fName = strjoin({pwd, '1_1.mp4'}, '/');

fprintf(1, 'Opening movie now...'); 
[movie, dur] = Screen('OpenMovie', w, fName)
tic;
Screen('PlayMovie', movie, 1);
while ~KbCheck
    % Wait for next movie frame, retrieve texture handle to it
    tex = Screen('GetMovieImage', w, movie);

    % Valid texture returned? A negative value means end of movie reached:
    if tex<=0
        % We're done, break out of loop:
        break;
    end

    % Draw the new texture immediately to screen:
    Screen('DrawTexture', w, tex);

    % Update display:
    Screen('Flip', w);

    % Release texture:
    Screen('Close', tex);
end
    
% Stop playback:
Screen('PlayMovie', movie, 0);

% Close movie:
Screen('CloseMovie', movie);
    
fprintf(1, 'done! (%0.2f)', toc);

%% clean up
Screen('CloseAll');