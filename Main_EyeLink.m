function Main_EyeLink(screenNumber, debugmode)
% Simple video demo with EyeLink integration and animated calibration / drift-check/correction targets.
% In each trial eye movements are recorded while a video stimulus is presented on the screen.
% Each trial ends when the space bar is pressed or the video stops playing. A different drift-check/correction
% animated target is used in each of the 2 trials.
%
% Illustrates how a video file can be added for trial play back in Data Viewer's "Trial Play Back Animation" view. 
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
% Check if Psychtoolbox is conigured for video presentation:
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
    %% STEP 0: This section tailors the code to work with MW videos
%     subID = num2str(input("What is subject ID? MW_"));
%     [stimPath, outputPath, stimList, def] = SimpleVideo_List(subID);
%     basePath = pwd;
    pths = specifyPaths();
    basePath = pths.base;
    
    
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
    el.targetbeep = 0;  % sound a beep when a target is presented
    el.feedbackbeep = 0;  % sound a beep after calibration or drift check/correction
    
    % Required for macOS Catalina users to disable audio
    % playback with animated calibration targets, otherwise causing
    % freezing during playback.
    el.calAnimationOpenSpecialFlags1 = spcf1;
    
    % Configure animated calibration target path and properties
    el.calTargetType = 'video';
    calMovieName = ('calibVid.mov');
    
    el.calAnimationTargetFilename = fullfile(basePath, calMovieName);
    el.calAnimationResetOnTargetMove = true; % false by default, set to true to rewind/replay video from start every time target moves
    el.calAnimationAudioVolume = 0.0; % default volume is 1.0, but too loud on some systems. Setting volume lower to 0.4 (minimum is 0.0)
    
    % You must call this function to apply the changes made to the el structure above
    EyelinkUpdateDefaults(el);
    
    % Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
    Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
    % Write DISPLAY_COORDS message to EDF file: sets display coordinates in DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Pre-trial Message Commands
    Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);    
    % Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
    Eyelink('Command', 'calibration_type = HV5'); % horizontal-vertical 5-points
    % Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
    Eyelink('Command', 'button_function 5 "accept_target_fixation"');
   % Hide mouse cursor
    %HideCursor(screenNumber); % AE: not hiding cursor for debug purposes
    % Start listening for keyboard input. Suppress keypresses to Matlab windows.
    ListenChar(-1);
    % Clear Host PC display from any previus drawing
    Eyelink('Command', 'clear_screen 0');
    % Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
    EyelinkDoTrackerSetup(el);
    
    
    %% STEP 5: TRIAL LOOP.
    
    driftVidList = {'dotsGrey.mov' 'wheelGrey.mov'};% Provide drift-check video file list for 2 trials
    % vidList = {'expected.mov' 'disappear.mov'};% Provide trial video file list for 2 trials
    
    spaceBar = KbName('space');% Identify keyboard key code for space bar to end each trial later on    
    for i = 1:length(vidList)
           
        % Change animated calibration target path for drift-check/correction
        % calMovieName = char(driftVidList(i));
        calMovieName = char(driftVidList(1)); % changed by AE so that it can accomodate for more than 2 videos
        el.calAnimationTargetFilename = fullfile(basePath, calMovieName);       
        % You must call this function to apply the changes made to the el structure above
        EyelinkUpdateDefaults(el);
        
        % Open movie file:
        movieName = char(vidList(i));
        % Check if movieName has extension already
        if ~strcmpi(movieName(end-3:end), '.MOV')
            movieName = strcat(movieName, '.MOV');
        end
        moviePath = fullfile(stimPath, movieName);
        [movie, ~, ~, Movx, Movy] = Screen('OpenMovie', window, moviePath, [], [], spcf1); % spcf1 required to disable audio on macOS Catalina and avoid playback freezing issues
        
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
        
        %STEP 5.2: START RECORDING
        
        % Put tracker in idle/offline mode before recording. Eyelink('SetOfflineMode') is recommended 
        % however if Eyelink('Command', 'set_idle_mode') is used allow 50ms before recording as shown in the commented code:        
        % Eyelink('Command', 'set_idle_mode');% Put tracker in idle/offline mode before recording
        % WaitSecs(0.05); % Allow some time for transition           
        Eyelink('SetOfflineMode');% Put tracker in idle/offline mode before recording
        Eyelink('StartRecording'); % Start tracker recording
        WaitSecs(0.1); % Allow some time to record a few samples before presenting first stimulus
        
        % STEP 5.3: PRESENT VIDEO; CREATE DATAVIEWER BACKDROP AND INTEREST AREA; STOP RECORDING
        
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
            Screen('DrawTexture', window, tex);            
            % Update display:
            Screen('Flip', window);
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
            if keyCode(spaceBar)
                % Write message to EDF file to mark the space bar press time
                Eyelink('Message', 'KEY_PRESSED');
                timeOut = 'no';
                % Release texture:
                Screen('Close', tex);
                break;
            end
            Screen('Close', tex); % Release texture if no key is pressed
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
                Screen('DrawText', window, 'Receiving data file...', 5, height-35, 0); % Prepare text
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
end