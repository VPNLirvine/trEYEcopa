 function Main_EyeLink_narrative(screenNumber, debugmode)
% Video playback with EyeLink integration and animated calibration / drift-check/correction targets.
% In each trial eye movements are recorded while a video stimulus is presented on the screen.
% Each trial ends when the space bar is pressed or the video stops playing.
%
% Usage:
% Main_EyeLink(screenNumber)
% 
% screenNumber is an optional parameter which can be used to pass a specific value to Screen('OpenWindow', ...)
% If screenNumber is not specified, or if isempty(screenNumber) then the default:
% screenNumber = max(Screen('Screens'));
% will be used.

% Bring the Command Window to the front if it is already open
if ~IsOctave; commandwindow; end

% Use default screenNumber if none specified
if (nargin < 1)
    screenNumber = [];
end
if (nargin < 2)
    debugmode = false;
else
    debugmode = logical(debugmode);
end
% Check if Psychtoolbox is configured for video presentation:
AssertOpenGL;
if IsWin && ~IsOctave && psychusejava('jvm')
    fprintf('Running on Matlab for Microsoft Windows, with JVM enabled!\n');
    fprintf('This may crash. See ''help GStreamer'' for problem and workaround.\n');
    warning('Running on Matlab for Microsoft Windows, with JVM enabled!');
end

% Required for macOS Catalina users (/w PTB 3.0.17.11) to disable audio
% with animated calibration targets and trial video stimuli to
% avoid freezing in video playback
spcf1 = 0;
if IsOSX
    [status, result] = system('sw_vers');
    if regexp(result,'ProductVersion\D*10\.15')
        spcf1 = 2; % for Screen('OpenMovie', ..., specialFlags1) see http://psychtoolbox.org/docs/Screen-OpenMovie
    end
end
try
    %% STEP 0: EXPERIMENT-SPECIFIC CUSTOMIZATIONS
    pths = specifyPaths();
    basePath = pths.base;
    
    % Set some defaults
    panic = false; % used to terminate early
    response = -1; % 0 causes panic, anything else is a button
    lastPressed = -1;
    maxWait = 4; % max duration to wait for a response
    
    InitializePsychSound;
    
    clear PsychHID; % re-scan for devices
    devices = PsychHID('Devices');
    mfg = {devices(:).manufacturer}; % i hate structs
    indicator = [];
    if sum(contains(mfg, 'Empirisoft Research Software')) > 0
        % use other
        keyList(1) = KbName('3#');
        keyList(2) = KbName('4$');
        keyList(3) = KbName('5%');
        keyList(4) = KbName('6^');
        keyList(5) = KbName('7&');
        
        % Response keys
        spaceBar = KbName('9(');
        deleteKey = KbName('1!');
        indicator = 'rightmost button';

    else
        keyList(1) = KbName('1!');
        keyList(2) = KbName('2@');
        keyList(3) = KbName('3#');
        keyList(4) = KbName('4$');
        keyList(5) = KbName('5%');
        
        % Some response keys
        spaceBar = KbName('space');% Identify keyboard key code for space bar to end each trial later on    
        deleteKey = KbName('DELETE'); % Panic button - press delete to quit immediately
        indicator = 'spacebar';

    end
%         escKey = KbName('ESCAPE');

    qText = 'How difficult was it to grasp the narrative?';
    respChoices = {'1', '2', '3', '4', '5'}; % used by getResp
    numResps = length(respChoices);
    
    %% STEP 1: INITIALIZE EYELINK CONNECTION; OPEN EDF FILE; GET EYELINK TRACKER VERSION
    
    % Initialize EyeLink connection (dummymode = 0) or run in "Dummy Mode" without an EyeLink connection (dummymode = 1);
    dummymode = 0;
    EyelinkInit(dummymode); % Initialize EyeLink connection
    status = Eyelink('IsConnected');
    if status < 1 % If EyeLink not connected
        dummymode = 1; 
    end
        % Open dialog box for EyeLink Data file name entry. File name up to 8 characters
    prompt = {'Enter subject number', 'TriCOPA (1) or Martin & Weisberg (2)?'};
    dlg_title = 'Create EDF file';
    def = {'##', '1'};
    answer = inputdlg(prompt, dlg_title, 1, def); % Prompt for new EDF file name    
    % Print some text in Matlab's Command Window if a file name has not been entered
    if  isempty(answer)
        fprintf('Session cancelled by user\n')
        cleanup; % Abort experiment (see cleanup function below)
        return
    end
    
    % Parse input
    [stimPath, outputPath, vidList, prefix] = stimFinder(answer{1}, answer{2});
    subID = strcat(prefix, answer{1});
    
    % Ask for response?
    switch answer{2}
        case '1'
            % TriCOPA
            rText = ['After each video, you will be asked\n' ...
            'how difficult it was to understand the narrative\n'...
            'on a scale of 1 (low) to 5 (high).\n'...
            'Press the corresponding button on the keyboard as fast as you can.\n\n\n'];
        case '2'
            % Martin & Weisberg     
            rText = '\nNo responses needed this time - simply watch and enjoy.\n\n\n';
    end
    
    edfFile = subID; % Save file name to a variable
    % Print some text in Matlab's Command Window if file name is longer than 8 characters
    if length(edfFile) > 8
        fprintf('Filename needs to be no more than 8 characters long (letters, numbers and underscores only)\n');
        cleanup; % Abort experiment (see cleanup function below)
        return
    end
    
    % Open an EDF file and name it
    if Eyelink('IsConnected') == 1 % if we have a live connection to a Host PC
        failOpen = Eyelink('OpenFile', edfFile);
        if failOpen ~= 0 % Abort if it fails to open
            fprintf('Cannot create EDF file %s', edfFile); % Print some text in Matlab's Command Window
            cleanup; %see cleanup function below
            return
        end
    end
    
    % Get EyeLink tracker and software version
    % <ver> returns 0 if not connected
    % <versionstring> returns 'EYELINK I', 'EYELINK II x.xx', 'EYELINK CL x.xx' where 'x.xx' is the software version
    ELsoftwareVersion = 0; % Default EyeLink version in dummy mode
    [ver, versionstring] = Eyelink('GetTrackerVersion');
    if dummymode == 0 % If connected to EyeLink
        % Extract software version number. 
        [r1, vnumcell] = regexp(versionstring,'.*?(\d)\.\d*?','Match','Tokens'); % Extract EL version before decimal point
        ELsoftwareVersion = str2double(vnumcell{1}{1}); % Returns 1 for EyeLink I, 2 for EyeLink II, 3/4 for EyeLink 1K, 5 for EyeLink 1KPlus, 6 for Portable Duo           
        % Print some text in Matlab's Command Window
        fprintf('Running experiment on %s version %d\n', versionstring, ver );
    end
    % Add a line of text in the EDF file to identify the current experimemt name and session. This is optional.
    % If your text starts with "RECORDED BY " it will be available in DataViewer's Inspector window by clicking
    % the EDF session node in the top panel and looking for the "Recorded By:" field in the bottom panel of the Inspector.
    preambleText = sprintf('RECORDED BY Psychtoolbox demo %s session name: %s', mfilename, edfFile);
    Eyelink('Command', 'add_file_preamble_text "%s"', preambleText);
    
    
    %% STEP 2: SELECT AVAILABLE SAMPLE/EVENT DATA
    % See EyeLinkProgrammers Guide manual > Useful EyeLink Commands > File Data Control & Link Data Control
    
    % Select which events are saved in the EDF file. Include everything just in case
    Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    % Select which events are available online for gaze-contingent experiments. Include everything just in case
    Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,FIXUPDATE,INPUT');
    % Select which sample data is saved in EDF file or available online. Include everything just in case
    if ELsoftwareVersion > 3  % Check tracker version and include 'HTARGET' to save head target sticker data for supported eye trackers
        Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,HTARGET,GAZERES,BUTTON,STATUS,INPUT');
        Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
    else
        Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,GAZERES,BUTTON,STATUS,INPUT');
        Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    end
    
    
    %% STEP 3: OPEN GRAPHICS WINDOW
    
    % Open experiment graphics on the specified screen
    if isempty(screenNumber)
        screenNumber = max(Screen('Screens')); % Use default screen if none specified
    end

    if debugmode
        PsychDebugWindowConfiguration(0,0.5) % AE: can make the screen transparent to facilitate debugging
%         PsychDebugWindowConfiguration(0,1) % p(1,x) hides mouse; p(x,.5) sets opacity level (e.g. 1 == fully opaque) 
        Screen('Preference', 'SkipSyncTests', 1); % AE: skip some of Psychtoolbox tests
    else
        PsychDebugWindowConfiguration(1,1); % I think this turns it off??
        Screen('Preference', 'SkipSyncTests',0); % allow test for real run
    end
    
    Screen('Preference', 'SkipSyncTests', 1); 
    window = Screen('OpenWindow', screenNumber, [128 128 128]); % Open graphics window
    Screen('Flip', window);
    % Return width and height of the graphics window/screen in pixels
    [width, height] = Screen('WindowSize', window);

    
    %% STEP 4: SET CALIBRATION SCREEN COLOURS/SOUNDS; PROVIDE WINDOW SIZE TO EYELINK HOST & DATAVIEWER; SET CALIBRATION PARAMETERS; CALIBRATE
    
    % Provide EyeLink with some defaults, which are returned in the structure "el".
    el = EyelinkInitDefaults(window);
    % set calibration/validation/drift-check(or drift-correct) background color. 
    % It is important that this background colour is similar to that of the stimuli to prevent large luminance-based 
    % pupil size changes (which can cause a drift in the eye movement data)
    el.backgroundcolour = [115 115 115];% RGB grey
    % set "Camera Setup" instructions text colour so it is different from background colour
    el.msgfontcolour = [0 0 0];% RGB black
    
    % Set calibration beeps (0 = sound off, 1 = sound on)
    % Setting beeps to off (0) for video targets
    el.targetbeep = 1;  % sound a beep when a target is presented
    el.feedbackbeep = 0;  % sound a beep after calibration or drift check/correction
    
    % Required for macOS Catalina users to disable audio
    % playback with animated calibration targets, otherwise causing
    % freezing during playback.
    el.calAnimationOpenSpecialFlags1 = spcf1;
%     el.calAnimationResetOnTargetMove = true; % false by default, set to true to rewind/replay video from start every time target moves
    el.calAnimationAudioVolume = 0.1; % default volume is 1.0, but too loud on some systems. Setting volume lower to 0.4 (minimum is 0.0)
    
    % Specify the appearance of the calibration target
    % Default values are size = 2.5, width = 1, which is too big
    el.calibrationtargetsize = 2;
    el.calibrationtargetwidth = 0.3;
    
    % You must call this function to apply the changes made to the el structure above
    EyelinkUpdateDefaults(el);
    
    % Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
    Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
    % Write DISPLAY_COORDS message to EDF file: sets display coordinates in DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Pre-trial Message Commands
    Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);    
    % Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
    Eyelink('Command', 'calibration_type = HV9'); % horizontal-vertical 9-points
    % Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
    Eyelink('Command', 'button_function 5 "accept_target_fixation"');
   % Hide mouse cursor
   if ~debugmode
        HideCursor(screenNumber);
   end
    % Suppress keypresses to Matlab windows.
    ListenChar(-1);
    % Clear Host PC display from any previus drawing
    Eyelink('Command', 'clear_screen 0');
    if dummymode == 0
        % Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
        EyelinkDoTrackerSetup(el);
    end
    
    %% STEP 4B: some final setup before main trial loop
    
    % Turn off drift-correction beeps, since we have our own beep now
    el.targetbeep = 0;
    EyelinkUpdateDefaults(el);
    
    % Screen settings for PTB
    ScreenBkgd = el.backgroundcolour; % mid gray
    TextColor = el.msgfontcolour; % black
    ChoiceColor = [255 255 255]; % white
    % Calculate a gap size: come in 10% on both ends (or 80% of total width),
    % then if you have e.g. 3 items, you need the size of 2 gaps. So n-1. 
    respOffset = round((.8 * width) / (numResps - 1));
    qHeight = .25 * height;
    wRect = [0 0 width height];
    
    Screen('TextSize', window, 0.05 * height); % set global font size
    
    % Set up behavioral output file
    [~,taskID] = fileparts(stimPath);
    fOutBase = strcat(subID, '_task-', taskID, '_date-', datestr(now, 1));
    fNameOut = fullfile(pths.beh, strcat(fOutBase, '.txt'));
    fid = fopen(fNameOut, 'w+');
    if fid == -1, fprintf(1, 'ALERT!!! Output file did not open properly.\n'); sysbeep; end

    fprintf(fid, '%s\n', fOutBase);
    fprintf(fid, '%s\n', datestr(now));
    fprintf(fid, 'Trial \tResponse \tRT \tTime \tStimName\n');

    % Set up a trial-level output file, for debugging timing info
%     fOut2 = strcat(subID, '_task-debug_date-', datestr(now, 1));
%     fOut2 = fullfile(pths.beh, [fOut2 '.tsv']);
%     fid2 = fopen(fOut2, 'w+');
%     fprintf(fid2, '%s\n', fOut2);
%     fprintf(fid2, '%s\n', datestr(now));
%     fprintf(fid2, 'Trial \tStimName \tFrame \tOnset\n');
    
    
    % Truncate the number of trials if debugging
    if debugmode
        numTrials = 4;
    else
        numTrials = length(vidList);
    end
    
    
    %% STEP 4C: Display instructions before experiment starts
    
    iText = sprintf(['You are about to watch a series of %i short video clips,\n'...
    'depicting some moving shapes. %s' ...
    'Please press the %s when you are ready to begin.'], numTrials, rText, indicator);
    Screen('FillRect', window, ScreenBkgd, wRect); % fill bkgd with mid-gray
    DrawFormattedText(window, iText, 'center', 'center', TextColor);
    Screen('Flip', window);
    begin = false;
    FlushEvents('keyDown'); %get rid of any old keypresses
    while ~begin
        [~,ExptStart,buttonPress] = KbCheck();
        if ismember(spaceBar, find(buttonPress))
            begin = true;
        end
    end
    %% STEP 5A: PRACTICE TRIAL LOOP.
   
    % Start with some practice trials
    % If you assume we're using a subset of just 26 "discriminative" stims,
    % then pick a set of 4 vids outside that list to illustrate the task
    stimList = {'normal/Q51_6694_attack.mov', 'normal/Q4_6643_slam_door.mov', 'normal/Q24_6665_wave_greet.mov'};
    
    % Display some warning text
    Screen('FillRect', window, ScreenBkgd, wRect); % fill bkgd with mid-gray
    pText = sprintf('The first three trials will be for practice.\nPush the %s again to begin.', indicator);
    DrawFormattedText(window, pText, 'center', 'center', TextColor);
    Screen('Flip', window);
    
    % Wait for button press
    WaitSecs(.5);
    begin = false;
    FlushEvents('keyDown'); %get rid of any old keypresses
    while ~begin
        [~,ExptStart,buttonPress] = KbCheck();
        if ismember(spaceBar, find(buttonPress))
            begin = true;
        end
    end
    
    % Begin practice trials
    for i = 1:length(stimList)
        %
        response = -1;
        movieName = char(stimList(i));
        % Check if movieName has extension already
        if ~strcmpi(movieName(end-3:end), '.MOV')
            movieName = strcat(movieName, '.MOV');
        end
        moviePath = fullfile(stimPath, movieName);
        [movie, ~, ~, Movx, Movy] = Screen('OpenMovie', window, moviePath, [], [], spcf1); % spcf1 required to disable audio on macOS Catalina and avoid playback freezing issues
        
        % Calculate new size for video
        newRect = resizeVideo(Movx, Movy, wRect);
        Movx = newRect(3); Movy = newRect(4); % Send to Eyelink
        timeOut = 'yes'; % Variable set to a default value. Changes to 'no' if key pressed to end video early
        % Start playback engine:
        Screen('PlayMovie', movie, 1);
        frameNum = 0;        
        % Wait until user releases keys on keyboard:
        KbReleaseWait;       
        % Playback loop: Runs until end of movie or keypress:
        while 1
            % Wait for next movie frame, retrieve texture handle to it
            tex = Screen('GetMovieImage', window, movie);
            if tex<=0 % Valid texture returned? A negative value means end of movie reached
                break;
            end
            % Draw the new texture immediately to screen:
            Screen('DrawTexture', window, tex, [], newRect);            
            % Update display:
            frameOn = Screen('Flip', window);
            frameNum = frameNum + 1;
            if frameNum == 1
                vidStart = GetSecs;  % Start a timer
            end
            % End trial if space bar is pressed
            [~, kbSecs, keyCode] = KbCheck;
            if keyCode(spaceBar) || keyCode(deleteKey)
                % Write message to EDF file to mark the space bar press time
                timeOut = 'no';
                % Release texture:
                Screen('Close', tex);
                if keyCode(deleteKey)
                    % Finish calculating things for this trial,
                    % then terminate the whole experiment
                    panic = true;
                end
                break;
            end
            Screen('Close', tex); % Release texture if no key is pressed
        end  % End while loop
        Screen('PlayMovie', movie, 0); % Stop playback
        Screen('CloseMovie', movie); % Close movie
        
        % Draw blank screen at end of trial
        Screen('FillRect', window, el.backgroundcolour);
        [~, vidEnd] = Screen('Flip', window); % Present blank screen
        
        WaitSecs(1.5);
        if panic
            % Exit trial loop, but still export files
            break
        else
            switch taskID
                case 'MartinWeisberg'
                % Don't bother collecting a rating of "understandability"
                % The videos are so simple, they'll all be 4 or 5
                % Ideally you'd avoid opening a response file at all,
                % but I don't want to retool all the code. Just do this.
                    RT = -1; response = -1;
                case 'TriCOPA'
                % Invoke subroutine for collecting response.
                % Keep in mind that this happens AFTER the video,
                % so the RT is kind of useless at the moment.
                % But it also sets a global 'response' variable we need.
                    RT = getResp;
            end
            if panic
                break
            end
        end % if panic
    end % for 4 practice trials
    
    
    % Display some end text
    Screen('FillRect', window, ScreenBkgd, wRect); % fill bkgd with mid-gray
    pText = sprintf('This ends the practice phase.\nPush the %s to continue.', indicator);
    DrawFormattedText(window, pText, 'center', 'center', TextColor);
    Screen('Flip', window);
    
    % Wait for button press
    begin = false;
    FlushEvents('keyDown'); %get rid of any old keypresses
    while ~begin
        [~,ExptStart,buttonPress] = KbCheck();
        if ismember(spaceBar, find(buttonPress))
            begin = true;
        end
    end
    
    %% STEP 5B: MAIN TRIAL LOOP
    % Initialize audio device
    pahandle = PsychPortAudio('Open', [], 2, 0, 44100, 1);
    PsychPortAudio('GetAudioData', pahandle, 60);
    for i = 1:numTrials
        trialStart = GetSecs;
        response = -1; % reset on each trial
        
        % Before running trial, see if it's time for a break:
        takeABreak(i,numTrials);
        
        % Open movie file:
        movieName = char(vidList(i));
        % Check if movieName has extension already
        if ~strcmpi(movieName(end-3:end), '.MOV')
            movieName = strcat(movieName, '.MOV');
        end
        moviePath = fullfile(stimPath, movieName);
        [movie, ~, ~, Movx, Movy] = Screen('OpenMovie', window, moviePath, [], [], spcf1); % spcf1 required to disable audio on macOS Catalina and avoid playback freezing issues
        
        % Calculate new size for video
        newRect = resizeVideo(Movx, Movy, wRect);
        Movx = newRect(3); Movy = newRect(4); % Send to Eyelink
            
        % STEP 5.1: START TRIAL; SHOW TRIAL INFO ON HOST PC; SHOW BACKDROP IMAGE AND/OR DRAW FEEDBACK GRAPHICS ON HOST PC; DRIFT-CHECK/CORRECTION
        
        % Write TRIALID message to EDF file: marks the start of a trial for DataViewer
        % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Defining the Start and End of a Trial
        Eyelink('Message', 'TRIALID %d', i);
        Eyelink('Message', '!V TRIAL_VAR video_file %s', movieName);
        % Write !V CLEAR message to EDF file: creates blank backdrop for DataViewer
        % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Simple Drawing
        Eyelink('Message', '!V CLEAR %d %d %d', el.backgroundcolour(1), el.backgroundcolour(2), el.backgroundcolour(3));
        % Supply the trial number as a line of text on Host PC screen
        Eyelink('Command', 'record_status_message "TRIAL %d %s"', i, movieName);        
        % Draw graphics on the EyeLink Host PC display. See COMMANDS.INI in the Host PC's exe folder for a list of commands
        Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode before drawing Host PC graphics and before recording
        Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing
        % Optional: draw feedback box and lines on Host PC interface
        % See section 25.7 'Drawing Commands' in the EyeLink Programmers Guide manual
        Eyelink('Command', 'draw_box %d %d %d %d 15', round(width/2-Movx/2), round(height/2-Movy/2), round(width/2+Movx/2), round(height/2+Movy/2));
        Eyelink('Command', 'draw_box %d %d %d %d 15', round(width/2-80), round(height/2-70), round(width/2+80), round(height/2+90));
        Eyelink('Command', 'draw_line %d %d %d %d 15', round(width/2-Movx/2), round(height/2)+40, round(width/2+Movx/2), round(height/2)+40);
        
        % Perform a drift check/correction.
        % Optionally provide x y target location, otherwise target is presented on screen centre
        EyelinkDoDriftCorrection(el, round(width/2), round(height/2));
        
%         % Initialize audio device
%         pahandle = PsychPortAudio('Open', [], 2, 0, 44100, 1);
%         PsychPortAudio('GetAudioData', pahandle, 60);
        
        
        %STEP 5.2: START RECORDING
        
        % Put tracker in idle/offline mode before recording. Eyelink('SetOfflineMode') is recommended 
        % however if Eyelink('Command', 'set_idle_mode') is used allow 50ms before recording as shown in the commented code:        
        % Eyelink('Command', 'set_idle_mode');% Put tracker in idle/offline mode before recording
        % WaitSecs(0.05); % Allow some time for transition           
        Eyelink('SetOfflineMode');% Put tracker in idle/offline mode before recording
        Eyelink('StartRecording'); % Start tracker recording
        PsychPortAudio('Start', pahandle); % Start audio recording
        WaitSecs(0.1); % Allow some time to record a few samples before presenting first stimulus
        
        % STEP 5.3: PRESENT VIDEO; CREATE DATAVIEWER BACKDROP AND INTEREST AREA; STOP RECORDING
        Snd('Play',sin(0:200), 4000); % play sound for microphone sync
        
        timeOut = 'yes'; % Variable set to a default value. Changes to 'no' if key pressed to end video early
        % Start playback engine:
        Screen('PlayMovie', movie, 1);
        frameNum = 0;        
        % Wait until user releases keys on keyboard:
        KbReleaseWait;       
        % Playback loop: Runs until end of movie or keypress:
        while 1
            % Check that eye tracker is  still recording. Otherwise close and transfer copy of EDF file to Display PC
            error = Eyelink('CheckRecording');
            if(error ~= 0)
                fprintf('EyeLink Recording stopped!\n');
                % Transfer a copy of the EDF file to Display PC
                Eyelink('SetOfflineMode');% Put tracker in idle/offline mode
                Eyelink('CloseFile'); % Close EDF file on Host PC
                Eyelink('Command', 'clear_screen 0'); % Clear trial image on Host PC at the end of the experiment
                WaitSecs(0.1); % Allow some time for screen drawing
                % Transfer a copy of the EDF file to Display PC
                transferFile; % See transferFile function below
                cleanup; % Abort experiment (see cleanup function below)
                return
            end
            % Wait for next movie frame, retrieve texture handle to it
            tex = Screen('GetMovieImage', window, movie);
            if tex<=0 % Valid texture returned? A negative value means end of movie reached
                break;
            end
            % Draw the new texture immediately to screen:
            Screen('DrawTexture', window, tex, [], newRect);            
            % Update display:
            frameOn = Screen('Flip', window);
            frameNum = frameNum + 1;
            if frameNum == 1
                % Write message to EDF file to mark the start time of stimulus presentation.
                Eyelink('Message', 'STIM_ONSET');
                % Write !V IAREA message to EDF file: creates interest areas in DataViewer
                % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Interest Area Commands
                Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 1, round(width/2-80), round(height/2-70), round(width/2+80), round(height/2+90), 'BOX_IA');
                vidStart = GetSecs;  % Start a timer
            end
            % Write message to EDF file to mark the time of each video frame
            Eyelink('Message', 'Frame to be displayed %d', frameNum);
            % Write a !V VFRAME message to the data file specifying the frame number, location and file name so DataViewer can play back the video
            Eyelink('Message', '%d !V VFRAME %d %d %d %s', 0, frameNum, round(width/2-Movx/2), round(height/2-Movy/2), movieName);

            % End trial if space bar is pressed
            [~, kbSecs, keyCode] = KbCheck;
            if keyCode(spaceBar) || keyCode(deleteKey)
                % Write message to EDF file to mark the space bar press time
                Eyelink('Message', 'KEY_PRESSED');
                timeOut = 'no';
                % Release texture:
                Screen('Close', tex);
                if keyCode(deleteKey)
                    % Finish calculating things for this trial,
                    % then terminate the whole experiment
                    panic = true;
                end
                break;
            end
            Screen('Close', tex); % Release texture if no key is pressed
            
            % Output debug data
            % 'Trial \tStimName \tFrame \tOnset\n'
%             fprintf(fid2, '%i\t%s\t%i\t%4.6f\n', i, movieName, frameNum, frameOn - vidStart);

        end  % End while loop
        Screen('PlayMovie', movie, 0); % Stop playback
        Screen('CloseMovie', movie); % Close movie
        
        % Draw blank screen at end of trial
        Screen('FillRect', window, el.backgroundcolour);
        [~, vidEnd] = Screen('Flip', window); % Present blank screen
        % Write message to EDF file to mark time when blank screen is presented
        Eyelink('Message', 'BLANK_SCREEN');
        
        % Calculate video duration
        if strcmp(timeOut, 'yes') % If no key pressed during video
            vidDur = round((vidEnd-vidStart)*1000); % Duration of video until BLANK_SCREEN
        else % If key pressed during video
            vidDur = round((kbSecs-vidStart)*1000); % Duration of video until key is pressed
        end
        % fprintf("%s duration is: %f\n",movieName,vidDur/1000) % AE: to see how long presentations are

        % Write !V CLEAR message to EDF file: creates blank backdrop for DataViewer
        % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Simple Drawing
        Eyelink('Message', '!V CLEAR %d %d %d', el.backgroundcolour(1), el.backgroundcolour(2), el.backgroundcolour(3));
        
         
        % Stop recording eye movements at the end of each trial
        WaitSecs(0.1); % Add 100 msec of data to catch final events before stopping 
        
        % STEP 5.4: CREATE VARIABLES FOR DATAVIEWER; END TRIAL
        
        % Write !V TRIAL_VAR messages to EDF file: creates trial variables in DataViewer
        % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Trial Message Commands
        Eyelink('Message', '!V TRIAL_VAR iteration %d', i); % Trial iteration
        % Eyelink('Message', '!V TRIAL_VAR video_file %s', movieName); % Video name % AE: moved it to top to preserve it in last trial
        Eyelink('Message', '!V TRIAL_VAR video_duration %d', vidDur); % Video duration until key press or end of video
        Eyelink('Message', '!V TRIAL_VAR timeout %s', timeOut); % Key pressed to end trial early? 'yes' or 'no'        
        % Write TRIAL_RESULT message to EDF file: marks the end of a trial for DataViewer
        % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Defining the Start and End of a Trial
        Eyelink('Message', 'TRIAL_RESULT 0');
        WaitSecs(0.01); % Allow some time before ending the trial
        
        Eyelink('SetOfflineMode');% Put tracker in idle/offline mode
        WaitSecs(1.5); % Let people keep talking a bit before question

        if panic
            % Close the audio recording
            PsychPortAudio('Stop', pahandle);
            [audioData, ~, ~] = PsychPortAudio('GetAudioData', pahandle);
            [~, movF, ~] = fileparts(movieName);
            wavout = fullfile(pths.audio, [subID,'-', num2str(i), '-', movF,'.wav']);
            audiowrite(wavout, audioData, 44100);
            % Exit trial loop, but still export files
            break
        else
            switch taskID
                case 'MartinWeisberg'
                % Don't bother collecting a rating of "understandability"
                % The videos are so simple, they'll all be 4 or 5
                % Ideally you'd avoid opening a response file at all,
                % but I don't want to retool all the code. Just do this.
                    RT = -1; response = -1;
                case 'TriCOPA'
                % Invoke subroutine for collecting response.
                % Keep in mind that this happens AFTER the video,
                % so the RT is kind of useless at the moment.
                % But it also sets a global 'response' variable we need.
                    RT = getResp;
            end
            if panic
                % Close the audio recording
                PsychPortAudio('Stop', pahandle);
                [audioData, ~, ~] = PsychPortAudio('GetAudioData', pahandle);
                [~, movF, ~] = fileparts(movieName);
                wavout = fullfile(pths.audio, [subID,'-', num2str(i), '-', movF,'.wav']);
                audiowrite(wavout, audioData, 44100);
                
                break
            end
            % Close the audio recording
            PsychPortAudio('Stop', pahandle);
            [audioData, ~, ~] = PsychPortAudio('GetAudioData', pahandle);
                if isempty(audioData)
                    % do SOMETHING
                    audioData = 0;
                    fprintf(1, '\nEnd of trial %i, GetAudioData returned an empty audioData\n', i);
                end
            [~, movF, ~] = fileparts(movieName);
            wavout = fullfile(pths.audio, [subID,'-', num2str(i), '-', movF,'.wav']);
            audiowrite(wavout, audioData, 44100);
            
            % Output trial data to file
            % 'Trial \tResponse \RT \tTime \tStimName\n'
            fprintf(fid, '%i\t %i\t %1.6f\t %4.3f\t %s\n', i, response, RT, trialStart - ExptStart, movieName);
        end

    end % End trial loop

    
    %% STEP 6: CLOSE EDF FILE. TRANSFER EDF COPY TO DISPLAY PC. CLOSE EYELINK CONNECTION. FINISH UP
    
    % Put tracker in idle/offline mode before closing file. Eyelink('SetOfflineMode') is recommended.
    % However if Eyelink('Command', 'set_idle_mode') is used, allow 50ms before closing the file as shown in the commented code:
    % Eyelink('Command', 'set_idle_mode');% Put tracker in idle/offline mode
    % WaitSecs(0.05); % Allow some time for transition  
    Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode
    Eyelink('Command', 'clear_screen 0'); % Clear Host PC backdrop graphics at the end of the experiment
    WaitSecs(0.5); % Allow some time before closing and transferring file    
    Eyelink('CloseFile'); % Close EDF file on Host PC       
    % Transfer a copy of the EDF file to Display PC
    transferFile; % See transferFile function below    
    
    fclose(fid); % close the behavioral output file
%     fclose(fid2); % close the debug file
catch % If syntax error is detected
    cleanup;
    % Print error message and line number in Matlab's Command Window
    psychrethrow(psychlasterror);
end

% Cleanup function used throughout the script above
    function cleanup
        try
            Screen('CloseAll'); % Close window if it is open
        end
        Eyelink('Shutdown'); % Close EyeLink connection
        ListenChar(0); % Restore keyboard output to Matlab
        ShowCursor; % Restore mouse cursor
        if ~IsOctave; commandwindow; end % Bring Command Window to front
    end

% Function for transferring copy of EDF file to the experiment folder on Display PC.
% Allows for optional destination path which is different from experiment folder
    function transferFile
        try
            if dummymode ==0 % If connected to EyeLink
                % Show 'Receiving data file...' text until file transfer is complete
                Screen('FillRect', window, el.backgroundcolour); % Prepare background on backbuffer
                Screen('DrawText', window, 'Receiving data file...', 5, height-(0.2 * height), 0); % Prepare text
                Screen('Flip', window); % Present text
                fprintf('Receiving data file ''%s.edf''\n', edfFile); % Print some text in Matlab's Command Window
                
                % Transfer EDF file to Host PC
                % [status =] Eyelink('ReceiveFile',['src'], ['dest'], ['dest_is_path'])
                % status = Eyelink('ReceiveFile');
                cd(outputPath);
                status = Eyelink('ReceiveFile');
                
                % Check if EDF file has been transferred successfully and print file size in Matlab's Command Window
                if status > 0
                    fprintf('EDF file size: %.1f KB\n', status/1024); % Divide file size by 1024 to convert bytes to KB
                end
                % Print transferred EDF file path in Matlab's Command Window
                fprintf('Data file ''%s.edf'' can be found in ''%s''\n', edfFile, pwd);
            else
                fprintf('No EDF file saved in Dummy mode\n');
            end
            cd(basePath);
            cleanup;
        catch % Catch a file-transfer error and print some text in Matlab's Command Window
            fprintf('Problem receiving data file ''%s''\n', edfFile);
            cleanup;
            psychrethrow(psychlasterror);
        end
    end

% Function for collecting responses after watching a video
% Asks for a button response 1-5 and gives visual feedback.
% Continuously updates the response until a set timer runs out.
    function RT = getResp
        
        Screen('FillRect', window, ScreenBkgd, wRect); % fill bkgd with mid-gray
        DrawFormattedText(window, qText, 'center', qHeight, TextColor);
        % Dynamically place a certain number of response options
        for c = 1:numResps
            % NOT PERFECT - debug
            offset = (.1 * width) + (respOffset * (c-1)); % 
            if c == response
                DrawFormattedText(window, respChoices{c},  offset, 'center', ChoiceColor);
            else
                DrawFormattedText(window, respChoices{c}, offset, 'center', TextColor);
            end
        end

        screenFlipR = Screen('Flip', window); 

        % BEGIN
        while GetSecs <= screenFlipR + maxWait
            % poll for input
            FlushEvents('keyDown'); %get rid of any old keypresses
            [~, pressedSecs, keypressCode] = KbCheck();
            pressedKeys = find(keypressCode);
            % If the panic key is pressed, terminate
            if ismember(deleteKey, pressedKeys)
                panic = true;
                break
            end
            
            % See if any of our response buttons were pressed
            if any(ismember(pressedKeys,keyList))
                response = find(pressedKeys(1) == keyList); % in case of multiples
            end
            
            % Compare current button to the last one pressed
            % and only bother to update the screen if there's a change
            if response ~= lastPressed
                respTimestamp = pressedSecs; % which updates
                % update display
                DrawFormattedText(window, qText, 'center', qHeight, TextColor);
                for c = 1:numResps
                    % NOT PERFECT - debug
                    offset = (.1 * width) + (respOffset * (c-1));
                    if c == response
                        DrawFormattedText(window, respChoices{c}, offset, 'center', ChoiceColor);
                    else
                        DrawFormattedText(window, respChoices{c}, offset, 'center', TextColor);
                    end
                end
                Screen('Flip', window);
                lastPressed = response;
                % restart - allow updating the response until the timeout
            end

        end
        if panic || ~exist('respTimestamp', 'var')
            RT = -1;
        else
            RT = respTimestamp - screenFlipR;
        end
    end % function getResp

    function takeABreak(trial, maxTrials)
        % Set a ratio of trials to take a break on
        ratio = 1/3;
        maxBreak = 60; % seconds
        
        % Determine whether this trial qualifies
        if ~rem(trial, floor(maxTrials * ratio) + 1)
            % Interrupt the experiment for up to a minute
            bText = sprintf(['You have completed %i of %i trials!\n' ...
                'Take a minute to relax your eyes.\n\n' ...
                'Press the %s when you are ready to continue'], ...
                trial-1, maxTrials, indicator);
            Screen('FillRect', window, ScreenBkgd, wRect); % fill bkgd with mid-gray
            DrawFormattedText(window, bText, 'center', 'center', TextColor);
            
            timeOn = Screen('Flip', window);
            
            while GetSecs < timeOn + maxBreak
                % Poll for keyboard to exit early
                FlushEvents('keyDown'); %get rid of any old keypresses
                [~, ~, keypressCode] = KbCheck();
                pressedKeys = find(keypressCode);
                if ismember(spaceBar, pressedKeys)
                    break
                end
            end
        end % otherwise skip
    end % function takeABreak
    
end