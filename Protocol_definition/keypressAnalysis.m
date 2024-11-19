%% 
% ================= KEYPRESS ANALYSIS =================

%%
clear all; close all; clc;
group = "A";    % P = non-autistic; A = autistic 
%% 
for s = 1:15
    
    if s < 10
        sub = strcat(group,'0',num2str(s));
    else
        sub = strcat(group,num2str(s));
    end
    
    if sub == "A09" || sub == "A15"
        runs = [1:5];
    else
        runs = [1:7];
    end
    
    dir_files = strcat('F:\SEM_mri_rawdata\', sub, '\'); % Path
    
    for r = runs
        
        nrun = strcat('R',num2str(r));
        ET_responses = load(strcat(dir_files, 'ET\ET_responses\ET_responses_', ...
            nrun, '.mat'));
        ET_responses = ET_responses.Response_table;
        triggers = load(strcat(dir_files, 'mat_files\', sub, '_', nrun, '.mat'));
        
        triggers = triggers.Output.Run.dataMat;
        keyPressed = triggers(3,:);
        clickTime = triggers(10,:);
        instTime = triggers(6,:);
        responseTime = triggers(8,:);
        gap2Time = triggers(9,:);
        antClickTime = triggers(8,:) + triggers(17,:); % Antecipated
        
        responses = ET_responses;
        responses.Properties.VariableNames(1) = "Pre_ET";
        responses.Properties.VariableNames(2) = "Response_ET";
        responses.Properties.VariableNames(3) = "Pos_ET";
        responses.Properties.VariableNames(6) = "Result_ET";
        
        responses = responses(:,{'Saccade2make' 'Pre_ET' 'Response_ET' ...
            'Pos_ET' 'Result_ET' 'Key2press'});
        
        clicks = {};
        
        for i=1:length(triggers)

            if keyPressed(i) ~= 0
                if (clickTime(i) > instTime(i) && clickTime(i) < responseTime(i)) ...
                        || keyPressed(i) == 41 || keyPressed(i) == 42
                    if keyPressed(i) == 1 || keyPressed(i) == 41
                        clicks{i,1} = {'Left'};
                        clicks{i,2} = {'Fixation'};
                    elseif keyPressed(i) == 2 || keyPressed(i) == 42
                        clicks{i,1} = {'Right'};
                        clicks{i,2} = {'Fixation'};
                    else
                        clicks{i,1} = {'XXXXX'};
                        clicks{i,2} = {'XXXXX'};
                        fprintf("XXXXX");
                    end
                elseif clickTime(i) > responseTime(i) && clickTime(i) < gap2Time(i)
                    if keyPressed(i) == 1
                        clicks{i,1} = {'Fixation'};
                        clicks{i,2} = {'Left'};
                    elseif keyPressed(i) == 2 
                        clicks{i,1} = {'Fixation'};
                        clicks{i,2} = {'Right'};
                    else
                        clicks{i,1} = {'XXXXX'};
                        clicks{i,2} = {'XXXXX'};
                        fprintf("XXXXX");
                    end
                else
                    clicks{i,1} = {'XXXXX'};
                    clicks{i,2} = {'XXXXX'};
                    fprintf("XXXXX");
                end
            else
                clicks{i,1} = {'Fixation'};
                clicks{i,2} = {'Fixation'};
            end
            
            % Response types:
            % - Correct                       
            % - Error                        
            % - Error (indecision) 
            % - Antecipated (correct)          
            % - Antecipated (error)           
            % - Error (no response)               
            
            % When the response should be a saccade and not a button press:
            % - Action error (correct direction)
            % - Action error (erroneous direction)
            % - Action error (correct direction, antecipated)
            % - Action error (erroneous direction, antecipated)
            
            if string(responses.Key2press(i)) ~= "Fixation"
                if clicks{i,1} == string(responses.Key2press(i)) 
                    if antClickTime(i) < instTime(i)+0.05 % Check if it's a late response to the previous trial
                        clicks{i,3} = {'Late response to previous trial'};
                    else
                        clicks{i,3} = {'Correct (anticipated)'};
                    end
                elseif clicks{i,1} ~= string(responses.Key2press(i)) && ...
                        clicks{i,1} ~= "Fixation"
                    if antClickTime(i) < instTime(i)+0.05
                        clicks{i,3} = {'Late response to previous trial'};
                    else
                        clicks{i,3} = {'Error (anticipated)'};
                    end
                elseif clicks{i,2} == string(responses.Key2press(i))
                    clicks{i,3} = {'Correct'};
                elseif string(clicks{i,1}) == string(clicks{i,2}) && ...
                        clicks{i,1} == "Fixation" && ...
                        string(responses.Key2press(i)) ~= "Fixation"
                    clicks{i,3} = {'Error (no-go)'};
                elseif clicks{i,2} ~= string(responses.Key2press(i))
                    clicks{i,3} = {'Error'};
                else
                    clicks{i,3} = {'XXXXXXX'};
                    fprintf("XXXXXXX");
                end
                
            % When the response should be a saccade and not a button press:
            else
                if string(clicks{i,1}) == string(clicks{i,2}) && ...
                        string(clicks{i,2}) == "Fixation"
                     clicks{i,3} = {'Correct'};
                elseif clicks{i,2} == string(responses.Saccade2make(i))
                    clicks{i,3} = {'Action error (correct)'};
                elseif clicks{i,1} == string(responses.Saccade2make(i)) 
                    if antClickTime(i) < instTime(i)+0.05
                        clicks{i,3} = {'Late response to previous trial'};
                    else
                        clicks{i,3} = {'Action error (anticipated correct)'};
                    end
                elseif clicks{i,2} ~= string(responses.Saccade2make(i)) && ...
                        string(clicks{i,2}) ~= "Fixation"
                    clicks{i,3} = {'Action error (error)'};
                elseif clicks{i,1} ~= string(responses.Saccade2make(i)) && ...
                        string(clicks{i,1}) ~= "Fixation"
                    if antClickTime(i) < instTime(i)+0.05
                        clicks{i,3} = {'Late response to previous trial'};
                    else
                        clicks{i,3} = {'Action error (anticipated error)'};
                    end
                else
                    clicks{i,3} = {'XXXXXXX'};
                    fprintf("XXXXXXX");
                end
            end

        end
        
        clicks = array2table(clicks, 'VariableNames', {'Pre_KP', ...
                'Response_KP', 'Result_KP'});
        responses = [responses clicks];
        
        %% Save file

        if ~exist(strcat(dir_files,'protocol/'))
           mkdir(strcat(dir_files,'protocol/'))
        end

        save(strcat(dir_files,'protocol/responses_', nrun, '.mat'), 'responses');
    end
    
end