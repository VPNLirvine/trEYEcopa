% Main code for an eyetracking TriCOPA experiment
% built by Sajjad on top of PhysSoc's main design
% modified by Emily and others to be adapted to eye tracking
% ...reviewed by Brandon, this has zero eyetracking guys come on


%%%%%% Initialize %%%%%%%
clear; clc;
rand('state',sum(100*clock));

% keyboard initialization
% PsychJavaTrouble; % make GetChar work (hack fix)
FalseCalltoGetSecs = GetSecs; % call this once to speed calls to this function later
KbName('UnifyKeyNames'); % improve functionality across keyboards

[keyIsDown,secs,InitKeycode] = KbCheck;% do a call to the keyboard to check for button box
fprintf(1, 'KbCheck is returning %i keys\n', length(InitKeycode));

%screen initialization
PsychDebugWindowConfiguration(0,.5) % can make the screen transparent here to facilitate debugging
% AssertOpenGL; %test of Psychtoolbox OpenGL functionality - is this needed?
Screen('Preference', 'SkipSyncTests', 1); %skip some of Psychtoolbox tests


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prompt={'Subject Initials', 'Window ptr'};
def={'sub-01','0'};
title='SETUP MAIN EXPERIMENT...';
answer=inputdlg(prompt,title,2,def);


SubID = char(answer(1,:));
wptr = str2num(char(answer(2, :)));

% leftKey = KbName(char(answer(4, :)));
% rightKey = KbName(char(answer(5, :)));

% ProjectLabel = '2021_PhysicalSocial';
TaskID = 'tricopa';
fOutBase = strcat(SubID, '_task-', TaskID, '_date-', datestr(now, 1));
% ConditionLabels = {'social'};

% HideCursor;
BkgdColor = 255;
TextColor = 0;

ITI = 1; % minimum seconds
pths = specifyPaths();
BasePath = pths.base;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up movie files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TriCOPAPath = strcat(pths.TCstim);
fList = dir(strcat(TriCOPAPath, '/*.mov'));

numTrials = size(fList, 1);
% now shuffle!


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up JSON & write output files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save non-event information in json -- prep to be modified after DICOM is
% read (after scan session)
% cd(BasePath)
% JSONinfo.rootdir = pwd;
% JSONinfo.ProjectLabel = ProjectLabel;
% JSONinfo.SubID = SubID;
% JSONinfo.SesID = '01';
% JSONinfo.TaskID = TaskID;
% JSONinfo.RunID = 1;
% 
% JSONinfo.MatlabVersion = version;
% JSONinfo.Begin = datestr(now);
% JSONinfo.TR = TR;
% JSONinfo.OutName = strcat('beh/', fOutBase, '.json');


fNameOut = strcat('beh/', fOutBase, '.txt');
fid = fopen(fNameOut, 'a');
if fid == -1, fprintf(1, 'ALERT!!! Output file did not open properly.\n'); sysbeep; end

fprintf(fid, '%s\n', fOutBase);
fprintf(fid, '%s\n', datestr(now));
fprintf(fid, 'Run \tTrial \tStimType \tTime \tStimID \tStimName\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[w, wRect] = Screen('OpenWindow',wptr,BkgdColor); % prepare the Screen for stimulus control
ScreenClut = [ [0:255]', [0:255]', [0:255]'];
Screen('LoadClut', w, ScreenClut);
Screen('FillRect', w, BkgdColor, wRect);

cd(BasePath)
% if lr == 0 % left
%     im1 = imread('blank_left.jpg');
% elseif lr == 1 % right
%     im1 = imread('blank_right.jpg');
% end

im1 = imread('blank_right.jpg');
im = floor(mean(im1, 3));
stimRect = [0 0 size(im, 2) size(im, 1)];

txID = Screen('MakeTexture', w, im);
[CtrX, CtrY] = RectCenter(wRect);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
text1 = strcat('Instructions:');
text = strvcat(' ', ...
    'In this experiment, you are going to watch animations with balls moving in and around a box.', ...
    'Please observe the entire video and pay attention to the movements of the balls. Sometimes,', ...
    'the balls appear as characters, and sometimes they look like objects. They might look less', ...
    'clear at times', ...
    ' ', ...
    'Your task is simply to watch the events that unfold through the movie', ...
    ' ', ...
    'Please wait, the experiment is about to begin...');
[NumTextLines, TextWide] = size(text);

Screen('TextFont', w, 'Arial');
Screen('TextSize', w, 18);

Screen('DrawText', w, text1, CtrX - (TextWide*7/2), CtrY-200, TextColor);
for i = 1:NumTextLines
    Screen('DrawText', w, text(i, :), CtrX - (TextWide*7/2), CtrY-200+(i*25), TextColor);
end
Screen('Flip', w);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Experiment Start (almost)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% clear instructions
FlushEvents('keyDown'); % get rid of any old keypresses
[keyIsDown, secs, keyCode, ~] = KbCheck;
% while keyCode(triggerKey) == 0
%     [keyIsDown, secs, keyCode, ~] = KbCheck;
% end
Screen('DrawTexture', w, txID, stimRect, CenterRect(stimRect, wRect));
Screen('Flip', w);

pause(1)


EventLabels = [];
OutputTrialIndex = 0;
   
%% go through the list of movies, one by one
for trial = 1:numTrials
     
%     fPath = TriCOPAPath;
%     cd(fPath)
    
    stimName = fList(trial).name;
    cd(TriCOPAPath)
    [movie] = Screen('OpenMovie', w, stimName);
%     [movie, dur] = Screen('OpenMovie', w, strjoin({TriCOPAPath, stimName}, '/'));


    if trial == 1
        ExptStart = GetSecs;
    end
 

    % initialize on each trial
    FlushEvents('keyDown');
    RespKey = -1;


    % force a brief delay between trials
    ITIstart = GetSecs;
    checkpt = GetSecs - ITIstart;
    while checkpt < ITI
        checkpt = GetSecs - ITIstart;
    end


    % put up background screen - can modify this to signal trial is about
    % to start
    Screen('DrawTexture', w, txID, stimRect, CenterRect(stimRect, wRect));
    Screen('Flip', w);


    % play the omvie
    fprintf(1, 'Starting movie playback\n')

    trialStart = GetSecs;
    Screen('PlayMovie', movie, 1);
    
%     while GetSecs - trialStart < movieDur
    while 1
        % Wait for next movie frame, retrieve texture handle to it
        tex = Screen('GetMovieImage', w, movie);

        % Valid texture returned? A negative value means end of movie reached:
        if tex <= 0
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

    %% clean up Screen after trial
    Screen('DrawTexture', w, txID, stimRect, CenterRect(stimRect, wRect));
    cpuTime = Screen('Flip', w);

    %get timestamp
    trialEnd = GetSecs;
    trialDur = trialEnd - trialStart;
    fprintf(1, 'Movie was %0.2f sec long\n', trialDur);

    % Close movie:
    Screen('CloseMovie', movie);

    %% Code responses for the output file
%     if RespKey == leftKey
%         resp = 1;
%         RT = respTime;
%     elseif RespKey == rightKey
%         resp = 0;
%         RT = respTime;
%     else % no response recorded
%         resp = -1;
%         RT = -1;
%     end
%     Accuracy = -1;
%     stimID = 0;

    % print data to the output files
    OutputTrialIndex = OutputTrialIndex+1;
    Events(OutputTrialIndex, :) = [trialStart-ExptStart trialDur stimID];
    EventLabels = strvcat(EventLabels, Condition);

    Data{run}(OutputTrialIndex, :) = [StimType trialStart - ExptStart (trialStart - ExptStart)/TR stimID];
    fprintf(fid, '%i\t %i\t %i\t %.3f\t %.2f\t %s\t %i\t %i\t %4.3f\n', run, trial, StimType, trialStart - ExptStart, (trialStart - ExptStart)/TR, stimName);

end % end of trial


ExptEnd = round(GetSecs - ExptStart);
fprintf(1, 'Final trial ended for experimental time of %i min and %i sec.\n', floor(ExptEnd/60), rem(ExptEnd, 60))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% save output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(BasePath)

fclose(fid); % close the output file

MatfName = strcat('beh/', fOutBase, '_run-', num2str(run)); %second, more easily managed data file
save(MatfName, 'Data');


% JSONinfo.Events = Events;
% JSONinfo.EventLabels = EventLabels;
% createBIDS_events_phscLoc(JSONinfo);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% close out experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Screen('DrawText', w, 'Experiment over!', CtrX-10, CtrY, TextColor); % print to the command window

Screen('CloseAll'); % close all screens from memory
ShowCursor
