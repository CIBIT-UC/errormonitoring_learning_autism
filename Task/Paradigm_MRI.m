function [S] = Paradigm_MRI(S)

% Usage: [S] = Paradigm_MRI(S)
%
% Inputs:
%   : S - struct containing very important info (screen, subject, colors,
%   textures, trigger, response box, eyetracker, etc)
%
% Outputs:
%   : S - struct containing time of start, end and trigger of the
%   stimulation, key presses and codes, user responses.
%
%% 
    % ============== Clean the COMs ==============
    if S.RSPBOX
        IOPort('Purge',S.response_box_handle);
    end
    if S.TRIGGER
        IOPort('Purge', S.syncbox_handle);
    end
    %% 
    % ============== Identify Key Codes ==============
    if S.RSPBOX
        % Left Button
        DrawFormattedText(S.window, 'Press Left Button', 'center', 'center', S.white);
        Screen('Flip',S.window);
        pr = 1;
        while pr
            key = IOPort('Read',S.response_box_handle);
            if ~isempty(key) && (length(key) == 1)
                S.leftKeyCode = key;
                pr = 0;
            end 
            IOPort('Flush',S.response_box_handle);
        end
        % Right Button
        DrawFormattedText(S.window, 'Press Right Button', 'center', 'center', S.white);
        Screen('Flip',S.window);
        pr = 1;
        while pr
            key = IOPort('Read',S.response_box_handle);
            if ~isempty(key) && (length(key) == 1)
                S.rightKeyCode = key;
                pr = 0;
            end
            IOPort('Flush',S.response_box_handle);
        end 
        clear code key pr
    end
    %% 
    % ============== Initiate EyeTracker (Calibration) ==============
    if S.EYETRACKER
        [success,S,el]= initEyeTracker(S.window,S,S.RUN_ID);
    end
    %% 
    % ======= Define EyeTracker Feedback and other parameters =======
    mxold= 0;
    myold= 0;
    S.ngazePositionsTarget= 1;
    S.ngazePositionsCross= 1;
    S.ngazePositionsAction= 1;
    S.gazePositionsTarget= nan(18000,4);
    S.gazePositionsCross= nan(18000,4);
    S.gazePositionsAction= nan(18000,4);
    S.trialPlot= [];
    S.tClick= []; 
    trial=1;
    block=1;
    S.NoiseTime = [];
    %% 
    % ============ Start EyeTracker ============
    if S.EYETRACKER
        Eyelink('Message', 'RUN_ID %s START', S.RUN_ID); %Testar diferença entre comand e message
        Eyelink('command', 'record_status_message "TRIAL %s_%s_GETREADY"',S.SUBJECT,S.RUN_ID);
        Eyelink('StartRecording');
        Eyelink('Message', 'SYNCTIME');
    end
    tic
    %% 
    % ============== Get Ready Presentation ==============
    % -- Wait for Trigger
    if S.TRIGGER    
        DrawFormattedText(S.window, 'GetReady...', 'center', 'center', S.white);
        Screen('Flip',S.window);
        disp('[runT] Waiting for trigger...')
        [gotTrigger, timeStamp] = waitForTrigger(S.syncbox_handle,1,90); % timeOut = 90s
        if gotTrigger
            S.run_initTime = toc;
            disp('[runT] Trigger Received.')
            IOPort('Flush', S.syncbox_handle);
            IOPort('Purge', S.syncbox_handle);
        else
            disp('[runT] Trigger Not Received. Aborting!')
            sca
            return
        end
    else
        S.run_initTime = toc;
        DrawFormattedText(S.window, 'GetReady...', 'center', 'center', S.white);
        Screen('Flip',S.window);
    end 
    while toc-S.run_initTime < S.readyTime
        [keyIsDown,clickTime,keyCode]= KbCheck;
        if keyCode(S.escKey) %If you click escape, the run finishes
            S.runTime=toc;
            sca;
            if S.EYETRACKER
                Eyelink('StopRecording');
            end
            return;
        end
    end
    %% 
    % ============== Initiate Paradigm Cicle ==============
    while trial < S.NrTrials
        for rep = 1:S.NrReps(block)
            picNr= S.instMatRand(trial+rep-1);
            % ============ EyeTracker & Trigger (TRIAL START) ============
            if S.EYETRACKER
                Eyelink('Message', 'TRIAL %d_%s_%s',trial+rep-1,S.SUBJECT,S.RUN_ID);
                Eyelink('command', 'record_status_message "TRIAL %d_%s_%s"',trial+rep-1,S.SUBJECT,S.RUN_ID);
            end
            % ============ Gap Presentation ============
            gapShownTime= toc;
            if rep == 1 % if rep ~= 1, the stimulus maintains from the last phase (inter-condition gap 2)
                Screen('FillRect',S.window,S.black);
                Screen('DrawLines',S.window,[S.horizontalLine,S.verticalLine1,S.verticalLine2],S.lineWidthPix,S.lineColor);
                Screen('DrawLines',S.window,S.allCoords,S.crossWidthPix,S.crossColor);
                Screen('Flip',S.window,0,1);
            end
            % ============== EyeTracker & Trigger (GAP) ==============
            if S.EYETRACKER
                Eyelink('Message', 'TRIAL %d_%s_%s_GAP',trial+rep-1,S.SUBJECT,S.RUN_ID);
                Eyelink('command', 'record_status_message "TRIAL %d_%s_%s_GAP"',trial+rep-1,S.SUBJECT,S.RUN_ID);
            end
            while toc-gapShownTime < S.gapTime
                [keyIsDown,clickTime,keyCode]= KbCheck;
                if keyCode(S.escKey) %If you click escape, the run finishes
                    S.runTime=toc;
                    sca;
                    if S.EYETRACKER
                        Eyelink('StopRecording');
                    end
                    return;
                end
            end
            % ============ Instruction Presentation ============
            instShownTime= toc;
            Screen('DrawTexture',S.window,S.Textures(picNr),[],S.textureRect,0);
            Screen('Flip',S.window);
            if (picNr >= 1 && picNr <= 4) || (picNr >= 9 && picNr <= 12)
                targetShown= 1; % Click
            else
                targetShown= 2; % Saccade
            end
            % ============ EyeTracker & Trigger (INSTRUCTION) ==============
            if S.EYETRACKER
                Eyelink('Message', 'TRIALID %d_%s_%s_INSTRUCTION',trial+rep-1,S.SUBJECT,S.RUN_ID);
                Eyelink('command', 'record_status_message "TRIAL %d_%s_%s_INSTRUCTION"',trial+rep-1,S.SUBJECT,S.RUN_ID);
            end
    %         ============ EyeTracker Feedback (INSTRUCTION) ============
            preSaccadeResp= 0;
            preResponse= 0;
            if S.EYETRACKER
                eye_used = Eyelink('EyeAvailable');
                if eye_used == el.BINOCULAR
                    eye_used = el.LEFT_EYE;
                end
            end
            tInitPreSaccade = 0;
            tPreResponse = 0;
            tInitPreSac = 0;
            tPreResp = 0;
            while toc-instShownTime < S.instructionTime
                if S.EYETRACKER
                    if Eyelink('NewFloatSampleAvailable') > 0
                        event= Eyelink('NewestFloatSample');
                        if eye_used~= 1 
                            %If the eye-tracker stops recording, it assumes the last x and y values until it records again
                            x= event.gx(eye_used+1); 
                            y= event.gy(eye_used+1);
                            if x~= el.MISSING_DATA && y~= el.MISSING_DATA && event.pa(eye_used+1) > 0
                                mx= x;
                                my= y;
                            end
                        end
                    end
                    if (mx~= mxold || my~= myold) %Save eye-tracking data
                        S.gazePositionsTarget(S.ngazePositionsTarget,1)= mx;
                        S.gazePositionsTarget(S.ngazePositionsTarget,2)= my;
                        S.gazePositionsTarget(S.ngazePositionsTarget,3)= toc;
                        S.gazePositionsTarget(S.ngazePositionsTarget,4)= trial+rep-1;
                        S.ngazePositionsTarget= S.ngazePositionsTarget + 1;
                        
                        saccadeLeft= IsInRect(mx,my,S.allFrames(:,1));
                        saccadeRight= IsInRect(mx,my,S.allFrames(:,2));
                        microLeft= IsInRect(mx,my,S.allFrames(:,3));
                        microRight= IsInRect(mx,my,S.allFrames(:,4));
                        fixationOn= IsInRect(mx,my,S.allFrames(:,5));
                        if fixationOn == 0
                            tInitPreSaccade = [tInitPreSaccade toc];
                        end
                        if microLeft== 1 || saccadeLeft== 1
                            preSaccadeResp= 1; % saccade/smallSaccade performed during instruction
                        elseif  microRight== 1 || saccadeRight== 1
                            preSaccadeResp= 2;
                        end
                    end
                end
                [keyIsDown,clickTime,keyCode]= KbCheck;
                if keyCode(S.escKey) %If you click escape, the run finishes
                    S.runTime=toc;
                    sca;
                    if S.EYETRACKER
                        Eyelink('StopRecording');
                    end
                    return;
                end
                if S.RSPBOX
                    %Detection of clicks
                    [keyCode,timestamp] = IOPort('Read',S.response_box_handle);
                    if ~isempty(keyCode) && (length(keyCode) == 1)
                        IOPort('Flush',S.response_box_handle);
                        if keyCode == S.leftKeyCode
                            preResponse= 1;
                            tPreResponse = [tPreResponse toc];
                        elseif keyCode == S.rightKeyCode
                            preResponse= 2;
                            tPreResponse = [tPreResponse toc];
                        end
                    end
                    IOPort('Flush',S.response_box_handle);
                else
                    if keyCode(S.leftKey)
                        preResponse= 1;
                        tPreResponse = [tPreResponse toc];
                    elseif keyCode(S.rightKey)
                        preResponse = 2;
                        tPreResponse = [tPreResponse toc];
                    end
                end
            end
             % ============ Inter Condition Gap Presentation ============
            interCondShownTime= toc;
            Screen('DrawLines',S.window,[S.horizontalLine,S.verticalLine1,S.verticalLine2],S.lineWidthPix,S.lineColor);
            Screen('DrawLines',S.window,S.allCoords,S.crossWidthPix,S.crossColor);
            Screen('Flip',S.window);
            % ============ EyeTracker & Trigger (INTER CONDITION GAP 1) ==============
            if S.EYETRACKER
                Eyelink('Message', 'TRIAL %d_%s_%s_INTER_CONDITION',trial+rep-1,S.SUBJECT,S.RUN_ID);
                Eyelink('command', 'record_status_message "TRIAL %d_%s_%s_INTER_CONDITION"',trial+rep-1,S.SUBJECT,S.RUN_ID);
            end
    %         ============ EyeTracker Feedback (INTER CONDITION GAP 1) ============
            if S.EYETRACKER
                eye_used = Eyelink('EyeAvailable');
                if eye_used == el.BINOCULAR
                    eye_used = el.LEFT_EYE;
                end
            end
            while toc-interCondShownTime < S.interCondTime1(trial+rep-1)
                if S.EYETRACKER
                    if Eyelink('NewFloatSampleAvailable') > 0
                        event= Eyelink('NewestFloatSample');
                        if eye_used~= 1
                            %If the eye-tracker stops recording, it assumes the last x and y values until it records again
                            x= event.gx(eye_used+1);
                            y= event.gy(eye_used+1);
                            if x~= el.MISSING_DATA && y~= el.MISSING_DATA && event.pa(eye_used+1) > 0
                                mx= x;
                                my= y;
                            end
                        end
                    end
                    if (mx~= mxold || my~= myold) %Save eye-tracking data
                        S.gazePositionsCross(S.ngazePositionsCross,1)= mx;
                        S.gazePositionsCross(S.ngazePositionsCross,2)= my;
                        S.gazePositionsCross(S.ngazePositionsCross,3)= toc;
                        S.gazePositionsCross(S.ngazePositionsCross,4)= trial+rep-1;
                        S.ngazePositionsCross= S.ngazePositionsCross + 1;
                        saccadeLeft= IsInRect(mx,my,S.allFrames(:,1));
                        saccadeRight= IsInRect(mx,my,S.allFrames(:,2));
                        microLeft= IsInRect(mx,my,S.allFrames(:,3));
                        microRight= IsInRect(mx,my,S.allFrames(:,4));
                        fixationOn= IsInRect(mx,my,S.allFrames(:,5));
                        if fixationOn == 0
                            tInitPreSaccade = [tInitPreSaccade toc];
                        end
                        if microLeft== 1 || saccadeLeft== 1
                            preSaccadeResp= 1; % saccade/smallSaccade performed during inter-condition gap 1
                        elseif  microRight== 1 || saccadeRight== 1
                            preSaccadeResp= 2;
                        end
                    end
                end
                [keyIsDown,clickTime,keyCode]= KbCheck;
                if keyCode(S.escKey) %If you click escape, the run finishes
                    S.runTime=toc;
                    sca;
                    if S.EYETRACKER
                        Eyelink('StopRecording');
                    end
                    return;
                end
                if S.RSPBOX
                    %Detection of clicks
                    [keyCode,timestamp] = IOPort('Read',S.response_box_handle);
                    if ~isempty(keyCode) && (length(keyCode) == 1)
                        IOPort('Flush',S.response_box_handle);
                        if keyCode == S.leftKeyCode
                            preResponse= 1;
                            tPreResponse = [tPreResponse toc];
                        elseif keyCode == S.rightKeyCode
                            preResponse= 2;
                            tPreResponse = [tPreResponse toc];
                        end
                    end
                    IOPort('Flush',S.response_box_handle);
                else
                    if keyCode(S.leftKey)
                        preResponse= 1;
                        tPreResponse = [tPreResponse toc];
                    elseif keyCode(S.rightKey)
                        preResponse = 2;
                        tPreResponse = [tPreResponse toc];
                    end
                end
            end
            % ============ Actions to Perform ============
            if picNr== 1 || picNr== 4 || picNr== 5 || picNr== 8 || picNr== 10 || ...
                    picNr== 11 || picNr== 14 || picNr== 15
                if targetShown== 1
                    keyToPress= 1;
                    saccadeToMake= 0;
                else
                    keyToPress= 0;
                    saccadeToMake= 1;
                end
            elseif targetShown== 1
                keyToPress= 2;
                saccadeToMake= 0;
            else
                keyToPress= 0;
                saccadeToMake= 2;
            end
            % ============== Action Cycle ==============
            tStart= toc;
            response= 0;
            saccadeResp= 0;
            clickCount= [];
            saccadeEval= [];
            microEval= [];
            Screen('DrawLines',S.window,[S.horizontalLine,S.verticalLine1,S.verticalLine2],S.lineWidthPix,S.lineColor);
            Screen('Flip',S.window,0,1);
            % ============== EyeTracker & Trigger (ACTION) ==============
            if S.EYETRACKER
                Eyelink('Message', 'TRIALID %d_%s_%s_ACTION',trial+rep-1,S.SUBJECT,S.RUN_ID);
                Eyelink('command', 'record_status_message "TRIAL %d_%s_%s_ACTION"',trial+rep-1,S.SUBJECT,S.RUN_ID);
                eye_used = Eyelink('EyeAvailable');
                if eye_used == el.BINOCULAR
                    eye_used = el.LEFT_EYE;
                end
            end
            tInitSaccade = 0;
            tInitSac = 0;
            while toc-tStart < S.actionTime
                if S.EYETRACKER
                    if Eyelink('NewFloatSampleAvailable') > 0
                    event= Eyelink('NewestFloatSample');
                        if eye_used~= 1
                            %If the eye-tracker stops recording, it assumes the last x and y values until it records again
                            x= event.gx(eye_used+1);
                            y= event.gy(eye_used+1);
                            if x~= el.MISSING_DATA && y~= el.MISSING_DATA && event.pa(eye_used+1) > 0
                                mx= x;
                                my= y;
                            end
                        end
                    end
                    if (mx~= mxold || my~= myold) %Save eye-tracking data
                        S.gazePositionsAction(S.ngazePositionsAction,1)= mx;
                        S.gazePositionsAction(S.ngazePositionsAction,2)= my;
                        S.gazePositionsAction(S.ngazePositionsAction,3)= toc; 
                        S.gazePositionsAction(S.ngazePositionsAction,4)= trial+rep-1;
                        S.ngazePositionsAction= S.ngazePositionsAction + 1;
                        saccadeLeft= IsInRect(mx,my,S.allFrames(:,1));
                        saccadeRight= IsInRect(mx,my,S.allFrames(:,2));
                        microLeft= IsInRect(mx,my,S.allFrames(:,3));
                        microRight= IsInRect(mx,my,S.allFrames(:,4));
                        fixationOn= IsInRect(mx,my,S.allFrames(:,5));
                        if fixationOn == 0
                            tInitSaccade = [tInitSaccade toc];
                        end 
                        if microLeft== 1
                           microEval= [microEval 1];
                           if length(microEval) == 2
                                tEndMicroSaccade= toc;
                           end
                        elseif microRight== 1
                            microEval= [microEval 2];
                            if length(microEval) == 2
                                tEndMicroSaccade= toc;
                            end
                        elseif saccadeLeft== 1
                            saccadeEval= [saccadeEval 1];
                            if length(saccadeEval)== 2
                                tEndSaccade= toc;
                            end
                        elseif saccadeRight== 1
                            saccadeEval= [saccadeEval 2];
                            if length(saccadeEval) == 2
                                tEndSaccade= toc;
                            end
                        end
                    end
                end
                [keyIsDown,clickTime,keyCode]= KbCheck;
                if keyCode(S.escKey) %If you click escape, the run finishes
                    S.runTime=toc;
                    sca;
                    if S.EYETRACKER
                        Eyelink('StopRecording');
                    end
                    return;
                end
                if S.RSPBOX
                    %Detection of clicks
                    [keyCode,timestamp] = IOPort('Read',S.response_box_handle);
                    if ~isempty(keyCode) && (length(keyCode) == 1)
                        IOPort('Flush',S.response_box_handle);
                        if keyCode == S.leftKeyCode
                            response= 1;
                            % ===== EyeTracker & Trigger (Left) ==============
                            if S.EYETRACKER
                                Eyelink('Message', 'TRIALID %d_%s_%s_KEYPRESS',trial+rep-1,S.SUBJECT,S.RUN_ID);
                                Eyelink('command', 'record_status_message "TRIAL %d_%s_%s_KEYPRESS"',trial+rep-1,S.SUBJECT,S.RUN_ID);
                            end
                            tEnd= toc;
                            S.trialPlot= [S.trialPlot trial+rep-1];
                            S.tClick= [S.tClick tEnd-tStart];
                            clickCount= [clickCount response];
                        elseif keyCode == S.rightKeyCode
                            response= 2;
                            % ===== EyeTracker & Trigger (Right) ==============
                            if S.EYETRACKER
                                Eyelink('Message', 'TRIALID %d_%s_%s_KEYPRESS',trial+rep-1,S.SUBJECT,S.RUN_ID);
                                Eyelink('command', 'record_status_message "TRIAL %d_%s_%s_KEYPRESS"',trial+rep-1,S.SUBJECT,S.RUN_ID);
                            end
                            tEnd= toc;
                            S.trialPlot= [S.trialPlot trial+rep-1];
                            S.tClick= [S.tClick tEnd-tStart];
                            clickCount= [clickCount response];
                        end
                    end
                    IOPort('Flush',S.response_box_handle);
                else
                    if keyCode(S.leftKey) %If you click escape, the run finishes
                        response= 1;
                        % ===== EyeTracker & Trigger (KEYPRESS_1) ==============
                        if S.EYETRACKER
                            Eyelink('Message', 'TRIALID %d_%s_%s_KEYPRESS',trial+rep-1,S.SUBJECT,S.RUN_ID);
                            Eyelink('command', 'record_status_message "TRIAL %d_%s_%s_KEYPRESS"',trial+rep-1,S.SUBJECT,S.RUN_ID);
                        end
                        tEnd= toc;
                        S.trialPlot= [S.trialPlot trial+rep-1];
                        S.tClick= [S.tClick tEnd-tStart];
                        clickCount= [clickCount response];
                    elseif keyCode(S.rightKey)
                        response= 2;
                        % ===== EyeTracker & Trigger (KEYPRESS_2) ==============
                        if S.EYETRACKER
                            Eyelink('Message', 'TRIALID %d_%s_%s_KEYPRESS',trial+rep-1,S.SUBJECT,S.RUN_ID);
                            Eyelink('command', 'record_status_message "TRIAL %d_%s_%s_KEYPRESS"',trial+rep-1,S.SUBJECT,S.RUN_ID);
                        end
                        tEnd= toc;
                        S.trialPlot= [S.trialPlot trial+rep-1];
                        S.tClick= [S.tClick tEnd-tStart];
                        clickCount= [clickCount response];
                    end
                end
            end
            % ============ Evaluate Correct Saccade ============
            evalSaccades1= find(saccadeEval(:,:)== 1);
            evalSaccades2= find(saccadeEval(:,:)== 2);
            evalMicro1= find(microEval(:,:)== 1);
            evalMicro2= find(microEval(:,:)== 2);
            if length(saccadeEval) > 1
                saccadeResp= saccadeEval(2);
                if saccadeResp== 1
                    if length(evalSaccades1) ~= length(saccadeEval)-1 || length(evalMicro1) ~= length(microEval)-1
                        saccadeResp= 31;
                    end
                elseif saccadeResp== 2
                    if length(evalSaccades2) ~= length(saccadeEval)-1 || length(evalMicro2) ~= length(microEval)-1
                        saccadeResp= 32;
                    end
                end
            end
            if saccadeResp == 0
                tEndSaccade = nan;
                if length(evalMicro1) > 1
                    saccadeResp= 41;
                    tEndSaccade= tEndMicroSaccade;
                elseif length(evalMicro2) > 1
                    saccadeResp= 42;
                    tEndSaccade= tEndMicroSaccade;
                end
            end
            if preSaccadeResp == 1
                saccadeResp= 51;
            elseif preSaccadeResp == 2
                saccadeResp = 52;
            end
            if length(tInitPreSaccade) == 1
                tInitPreSac = nan;
            elseif length(tInitPreSaccade) > 1
                tInitPreSac = tInitPreSaccade(2);
            end
            if length(tInitSaccade) == 1
                tInitSac = nan;
            elseif length(tInitSaccade) > 1
                tInitSac = tInitSaccade(2);
            end
            % ============ Evaluate Correct KeyPress ============
            if response== 0
                tEnd = nan;
            end
            if length(clickCount) > 2 && clickCount(1)~= clickCount(2)
                if clickCount(1) == 1
                    response = 31;
                elseif clickCount(1) == 2
                    response = 32;
                end
            end
            if preResponse== 1
                response= 41;
                tPreResp = tPreResponse(2);
            elseif preResponse == 2
                response = 42;
                tPreResp = tPreResponse(2);
            else
                tPreResp = nan;
            end
             % ============ Inter Condition Gap 2 Presentation ============
            interCond2ShownTime= toc;
            Screen('DrawLines',S.window,S.allCoords,S.crossWidthPix,S.crossColor);
            Screen('Flip',S.window,0,1);
            % ============ EyeTracker & Trigger (INTER CONDITION GAP 2) ==============
            if S.EYETRACKER
                Eyelink('Message', 'TRIAL %d_%s_%s_INTER_CONDITION2',trial+rep-1,S.SUBJECT,S.RUN_ID);
                Eyelink('command', 'record_status_message "TRIAL %d_%s_%s_INTER_CONDITION2"',trial+rep-1,S.SUBJECT,S.RUN_ID);
            end
            while toc-interCond2ShownTime < S.interCondTime2(trial+rep-1)
                [keyIsDown,clickTime,keyCode]= KbCheck;
                if keyCode(S.escKey) %If you click escape, the run finishes
                    S.runTime=toc;
                    sca;
                    if S.EYETRACKER
                        Eyelink('StopRecording');
                    end
                    return;
                end
            end
            % ============ SAVE Trial Data ============
            S.dataMat(1,trial+rep-1)= picNr;
            S.dataMat(2,trial+rep-1)= keyToPress;
            S.dataMat(3,trial+rep-1)= response;
            S.dataMat(4,trial+rep-1)= targetShown;
            S.dataMat(5,trial+rep-1)= gapShownTime;
            S.dataMat(6,trial+rep-1)= instShownTime;
            S.dataMat(7,trial+rep-1)= interCondShownTime;
            S.dataMat(8,trial+rep-1)= tStart;
            S.dataMat(9,trial+rep-1)= interCond2ShownTime;
            S.dataMat(10,trial+rep-1)= tEnd;
            S.dataMat(11,trial+rep-1)= tEnd - tStart;
            S.dataMat(12,trial+rep-1)= saccadeToMake;
            S.dataMat(13,trial+rep-1)= saccadeResp;
            S.dataMat(14,trial+rep-1)= tEndSaccade - tStart;
            S.dataMat(15,trial+rep-1)= tInitPreSac - tStart;
            S.dataMat(16,trial+rep-1)= tInitSac - tStart;
            S.dataMat(17,trial+rep-1)= tPreResp - tStart;
        end
        %Pause - Noise
        S.NoiseTime = [S.NoiseTime toc];
        Screen('DrawTexture',S.window,S.Textures(17),[],S.textureWhiteNoise,0);
        Screen('Flip',S.window);
        while toc-S.NoiseTime(length(S.NoiseTime))<S.whiteNoiseTime(block)
            if keyCode(S.escKey) %If you click escape, the run finishes
                S.runTime=toc;
                sca;
                if S.EYETRACKER
                    Eyelink('StopRecording');
                end
                return;
            end
        end
        block = block+1;
        trial = trial+rep;
    end
     % ============ Stop EyeTracker ============
    S.runFinalTime = toc;
    if S.EYETRACKER
        Eyelink('StopRecording');
        Eyelink('Message', 'TRIAL_RESULT 0')
    end
    % ============ Finish ============
    DrawFormattedText(S.window, 'Experiment Finished \n\n Press "Esc" Key To Exit',...
    'center', 'center', S.white);
    Screen('Flip', S.window);
    WaitSecs(0.5);
    if S.EYETRACKER
        Eyelink('CloseFile');
    end
    % ============ Download Data File ============
    if S.EYETRACKER
        try
            fprintf('Receiving data file ''%s''\n', S.edfFile );
            status=Eyelink('ReceiveFile');
            if status > 0
                fprintf('ReceiveFile status %d\n', status);
            end
            if 2==exist(S.edfFile, 'file')
                fprintf('Data file ''%s'' can be found in ''%s''\n', S.edfFile, pwd );
            end
        catch 
            fprintf('Problem receiving data file ''%s''\n', S.edfFile );
        end
    end
    KbStrokeWait;
    sca;
    S.runTime=toc;
    S.runTimeMin= S.runTime/60;
    [keyIsDown,clickTime,keyCode]= KbCheck;
    if keyCode(S.escKey)
        sca;
        return;
    end
end