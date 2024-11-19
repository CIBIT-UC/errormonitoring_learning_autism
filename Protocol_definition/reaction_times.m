%% 
% ================= REACTION TIMES =================

%%
clear all; close all; clc;
addpath('C:\toolbox\edfImport1.0.5\')
group = "A";    % P = non-autistic; A = autistic 
%% 
for s = 1:15
    
    if s < 10
        sub = strcat(group,'0',num2str(s));
    else
        sub = strcat(group,num2str(s));
    end
    
    dir_files = strcat('F:\SEM_mri_rawdata\', sub); % Path
    
    % Sampling Rate
    if sub ~= "P04"
        srate = 500;
    else
        srate = 1000;
    end

    if sub == "A01" || sub == "A02" || sub == "A09"
        eye = 2; 
    else
        eye = 1;
    end
    %% 
    if sub == "A09" || sub == "A15"
        runs = [1:5];
    else
        runs = [1:7];
    end
       
    for r = runs
        
        nrun = strcat('R',num2str(r));
        edfFile = strcat(sub, '_', nrun, '.edf');
        run = edfImport(char(strcat(dir_files,"\ET\" ,edfFile)), [1 1 1], '');
        responses = load(strcat(dir_files, '\protocol\results_', nrun, '.mat'));
        responses = responses.responses;
                
        triggers = load(strcat(dir_files, '\mat_files\', sub, '_', nrun, '.mat'));
        start_time = triggers.Output.Run.run_initTime;
        noiseTime = triggers.Output.Run.NoiseTime - start_time;
        triggers = triggers.Output.Run.dataMat;
        triggers(5:10,:) = triggers(5:10,:) - start_time;
        instTime = triggers(6,:); 
        responseTime = triggers(8,:); 
        gap2Time = triggers(9,:); 
        
        if group == "P"
            ET_details = load('F:\SEM_mri\MRI\SEM_mri_rawdata\ET_details_non-autistic.mat', 'ET_details_table');
        else
            ET_details = load('F:\SEM_mri\MRI\SEM_mri_rawdata\ET_details_autistic.mat', 'ET_details_table');
        end
        ET_details = ET_details.ET_details_table;
        screenYpixels = cell2mat(ET_details.((r-1)*5+2)(s));
        left_lim = cell2mat(ET_details.((r-1)*5+3)(s));
        right_lim = cell2mat(ET_details.((r-1)*5+4)(s));
        dist_ylim = cell2mat(ET_details.((r-1)*5+5)(s));
        xmin = cell2mat(ET_details.((r-1)*5+6)(s));
        
        r_time = zeros(48,1);
        r_time = array2table(r_time, 'VariableNames', {'Reaction_time'});
        responses = [responses r_time];
        
        for i=1:height(responses)
            
            % Gaze before response time
            xGazeBefore = run.Samples.gx(eye,round(instTime(i)+start_time,1)*srate:round(responseTime(i)+start_time+1,1)*srate-1); % +1 para o caso da sacada já terminar na etapa seguinte
            yGazeBefore = run.Samples.gy(eye,round(instTime(i)+start_time,1)*srate:round(responseTime(i)+start_time+1,1)*srate-1);
            tBefore = round(instTime(i),1):1/srate:round(responseTime(i),1)+1;
            tBefore = tBefore(1:end-1);
            
            % Gaze during response time
            xGazeResponse = run.Samples.gx(eye,round(responseTime(i)+start_time,1)*srate:round(gap2Time(i)+start_time+1,1)*srate-1);
            yGazeResponse = run.Samples.gy(eye,round(responseTime(i)+start_time,1)*srate:round(gap2Time(i)+start_time+1,1)*srate-1);
            tResponse = round(responseTime(i),1):1/srate:round(gap2Time(i),1)+1;
            tResponse = tResponse(1:end-1);
            
            if string(responses.Result(i)) ~= "Correct (late)" && ...
                    string(responses.Result(i)) ~= "Action error (late correct)" && ...
                    string(responses.Result(i)) ~= "Action error (late error)" &&...
                    string(responses.Result(i)) ~= "Action error (late indecision)" && ...
                    string(responses.Result(i)) ~= "Error (late indecision)" && ...
                    string(responses.Result(i)) ~= "Error (late)"
                if string(responses.Result(i)) == "Error (no-go)"
                    responses.Reaction_time(i) = round(triggers(8,i),1);
                elseif (string(responses.Saccade2make(i)) == "Fixation" && ...
                        string(responses.Result_ET(i)) == "Correct") || ... 
                        string(responses.Result_ET(i)) == "Error (no-go)" || ...
                        contains(string(responses.Result(i)), "+KP anticipated") || ...
                        (string(responses.Key2press(i)) ~= "Fixation" && ...
                        string(responses.Result(i)) == "Correct") || ...
                        contains(string(responses.Result_ET(i)), "late") || ...
                        string(responses.Result(i)) == "Late response to previous trial"
                    if contains(string(responses.Result_KP(i)), "anticipated") || ...
                            string(responses.Result(i)) == "Late response to previous trial"
                        responses.Reaction_time(i) = round(triggers(8,i) + triggers(17,i),1);
                    elseif ~contains(string(responses.Result_KP(i)), "anticipated")
                        responses.Reaction_time(i) = round(triggers(10,i),1);
                    end
                elseif (string(responses.Key2press(i)) == "Fixation" && ...
                        string(responses.Result_KP(i)) == "Correct") || ... 
                        string(responses.Result_KP(i)) == "Error (no-go)" || ...
                        contains(string(responses.Result(i)), "+ET anticipated") || ...
                        (string(responses.Saccade2make(i)) ~= "Fixation" && ...
                        string(responses.Result(i)) == "Correct")
                    
                    if string(responses.Pre_ET(i)) == "Left" || ...
                            (string(responses.Pre_ET(i)) == "Fixation" && string(responses.Response_ET(i)) == "Left")
                        
                        if contains(string(responses.Result_ET(i)), "anticipated")
                            idx_init = find(xGazeBefore>xmin & xGazeBefore<left_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim,1);
                            tSaccade = get_tSaccade(xGazeBefore,idx_init,tBefore);
                            responses.Reaction_time(i) = round(tSaccade,1);
                        else
                            idx_init = find(xGazeResponse>xmin & xGazeResponse<left_lim & yGazeResponse>dist_ylim & yGazeResponse <screenYpixels-dist_ylim,1);
                            tSaccade = get_tSaccade(xGazeResponse,idx_init,tResponse);
                            responses.Reaction_time(i) = round(tSaccade,1);
                        end
                        
                    elseif string(responses.Pre_ET(i)) == "Right" || ...
                            (string(responses.Pre_ET(i)) == "Fixation" && string(responses.Response_ET(i)) == "Right")
                        
                        if contains(string(responses.Result_ET(i)), "anticipated")
                            idx_init = find(xGazeBefore>right_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim,1);
                            tSaccade = get_tSaccade(xGazeBefore,idx_init,tBefore);
                            responses.Reaction_time(i) = round(tSaccade,1);
                        else 
                            idx_init = find(xGazeResponse>right_lim & yGazeResponse>dist_ylim & yGazeResponse <screenYpixels-dist_ylim,1);
                            tSaccade = get_tSaccade(xGazeResponse,idx_init,tResponse);
                            responses.Reaction_time(i) = round(tSaccade,1);
                        end
                        
                    elseif string(responses.Pre_ET(i)) == "Both" || ...
                            (string(responses.Pre_ET(i)) == "Fixation" && string(responses.Response_ET(i)) == "Both")
                        
                        if contains(string(responses.Result_ET(i)), "anticipated")
                            
                            idx_init_left = find(xGazeBefore>xmin & xGazeBefore<left_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim,1);
                            idx_init_right = find(xGazeBefore>right_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim,1);
                            if idx_init_left < idx_init_right
                                idx_init = idx_init_left;
                            else
                                idx_init = idx_init_right;
                            end
                            tSaccade = get_tSaccade(xGazeBefore,idx_init,tBefore);
                            responses.Reaction_time(i) = round(tSaccade,1);
                        
                        else
                            
                            idx_init_left = find(xGazeResponse>xmin & xGazeResponse<left_lim & yGazeResponse>dist_ylim & yGazeResponse <screenYpixels-dist_ylim,1);
                            idx_init_right = find(xGazeResponse>right_lim & yGazeResponse>dist_ylim & yGazeResponse <screenYpixels-dist_ylim,1);
                            if idx_init_left < idx_init_right
                                idx_init = idx_init_left;
                            else
                                idx_init = idx_init_right;
                            end
                            tSaccade = get_tSaccade(xGazeResponse,idx_init,tResponse);
                            responses.Reaction_time(i) = round(tSaccade,1);
                            
                        end
                        
                    end
                
                % Both actions
                elseif (string(responses.Pre_ET(i)) ~= "Fixation" || string(responses.Response_ET(i)) ~= "Fixation") && ...
                        (string(responses.Pre_KP(i)) ~= "Fixation" || string(responses.Response_KP(i)) ~= "Fixation")
                    
                    if contains(string(responses.Result_KP(i)), "anticipated")
                        tClick = round(triggers(8,i) + triggers(17,i),1);
                    else 
                        tClick = round(triggers(10,i),1);
                    end
                    
                    if contains(string(responses.Result_ET(i)), "anticipated")
                            
                        idx_init_left = find(xGazeBefore>xmin & xGazeBefore<left_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim,1);
                        idx_init_right = find(xGazeBefore>right_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim,1);
                        if length(idx_init_right) == 0 || (length(idx_init_left) ~= 0 && length(idx_init_right) ~= 0 && idx_init_left < idx_init_right)
                            idx_init = idx_init_left;
                        else
                            idx_init = idx_init_right;
                        end
                        tSaccade = get_tSaccade(xGazeBefore,idx_init,tBefore);

                    else

                        idx_init_left = find(xGazeResponse>xmin & xGazeResponse<left_lim & yGazeResponse>dist_ylim & yGazeResponse <screenYpixels-dist_ylim,1);
                        idx_init_right = find(xGazeResponse>right_lim & yGazeResponse>dist_ylim & yGazeResponse <screenYpixels-dist_ylim,1);
                        if length(idx_init_right) == 0 || (length(idx_init_left) ~= 0 && length(idx_init_right) ~= 0 && idx_init_left < idx_init_right)
                            idx_init = idx_init_left;
                        else
                            idx_init = idx_init_right;
                        end
                        tSaccade = get_tSaccade(xGazeResponse,idx_init,tResponse);

                    end
                    
                    if tClick < tSaccade
                        responses.Reaction_time(i) = round(tClick,1);
                    else
                        responses.Reaction_time(i) = round(tSaccade,1);
                    end
                    
                end
            else
                
                % Gaze after response time
                if i < height(responses) && ...
                        sum(ismember(round(noiseTime),[round(gap2Time(i))+1, round(gap2Time(i))+2, round(gap2Time(i))+3])) == 0
                    xGazeAfter = run.Samples.gx(eye,round(gap2Time(i)+start_time,1)*srate:round(instTime(i+1)+start_time,1)*srate-1);
                    yGazeAfter = run.Samples.gy(eye,round(gap2Time(i)+start_time,1)*srate:round(instTime(i+1)+start_time,1)*srate-1);
                    tAfter = round(gap2Time(i),1):1/srate:round(instTime(i+1),1);
                    tAfter = tAfter(1:end-1);
                elseif i == height(responses)
                    xGazeAfter = run.Samples.gx(eye,round(gap2Time(i)+start_time,1)*srate:round(noiseTime(3)+start_time,1)*srate-1);
                    yGazeAfter = run.Samples.gy(eye,round(gap2Time(i)+start_time,1)*srate:round(noiseTime(3)+start_time,1)*srate-1);
                    tAfter = round(gap2Time(i),1):1/srate:round(noiseTime(3),1);
                    tAfter = tAfter(1:end-1);
                elseif isequal(ismember(round(noiseTime), [round(gap2Time(i))+1, round(gap2Time(i))+2, round(gap2Time(i))+3]), [1 0 0])
                    xGazeAfter = run.Samples.gx(eye,round(gap2Time(i)+start_time,1)*srate:round(noiseTime(1)+start_time,1)*srate-1);
                    yGazeAfter = run.Samples.gy(eye,round(gap2Time(i)+start_time,1)*srate:round(noiseTime(1)+start_time,1)*srate-1);
                    tAfter = round(gap2Time(i),1):1/srate:round(noiseTime(1),1);
                    tAfter = tAfter(1:end-1);
                else
                    xGazeAfter = run.Samples.gx(eye,round(gap2Time(i)+start_time,1)*srate:round(noiseTime(2)+start_time,1)*srate-1);
                    yGazeAfter = run.Samples.gy(eye,round(gap2Time(i)+start_time,1)*srate:round(noiseTime(2)+start_time,1)*srate-1);
                    tAfter = round(gap2Time(i),1):1/srate:round(noiseTime(2),1);
                    tAfter = tAfter(1:end-1);
                end
                
                if string(responses.Pos_ET(i)) == "Left" 
                    idx_init = find(xGazeAfter>xmin & xGazeAfter<left_lim & yGazeAfter>dist_ylim & yGazeAfter <screenYpixels-dist_ylim,1);
                    tSaccade = get_tSaccade(xGazeAfter,idx_init,tAfter);
                    responses.Reaction_time(i) = round(tSaccade,1);
                elseif string(responses.Pos_ET(i)) == "Right"
                    idx_init = find(xGazeAfter>right_lim & yGazeAfter>dist_ylim & yGazeAfter <screenYpixels-dist_ylim,1);
                    tSaccade = get_tSaccade(xGazeAfter,idx_init,tAfter);
                    responses.Reaction_time(i) = round(tSaccade,1);
                elseif string(responses.Pos_ET(i)) == "Both"
                    idx_init_left = find(xGazeAfter>xmin & xGazeAfter<left_lim & yGazeAfter>dist_ylim & yGazeAfter <screenYpixels-dist_ylim,1);
                    idx_init_right = find(xGazeAfter>right_lim & yGazeAfter>dist_ylim & yGazeAfter <screenYpixels-dist_ylim,1);
                    if idx_init_left < idx_init_right
                        idx_init = idx_init_left;
                    else
                        idx_init = idx_init_right;
                    end
                    tSaccade = get_tSaccade(xGazeAfter,idx_init,tAfter);
                    responses.Reaction_time(i) = round(tSaccade,1);
                else
                    responses.Reaction_time(i) = "XXXXXX";
                    fprintf("ERROR! <----");
                    disp(sub);
                    disp(nrun);
                end
            end           
        end
        %% Save file
        save(strcat(dir_files,'/protocol/results_RT_', nrun, '.mat'), 'responses')
    end
end