%% 
% ================= RESPONSE ANALYSIS =================

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
        responses = load(strcat(dir_files, 'protocol\responses_', nrun, '.mat'));
        responses = responses.responses;
        
        result = {};
        
        for i=1:height(responses)
            
            if string(responses.Result_ET(i)) == "Correct" && ...
                    string(responses.Result_KP(i)) == "Correct"
                result{i,1} = {'Correct'};
            elseif i>1 && string(result{i-1,1}) == "Error (no-go)" ...
                && string(responses.Pre_KP(i)) == string(responses.Key2press(i-1)) ...
                && string(responses.Pre_KP(i)) ~= string(responses.Key2press(i)) ...
                && string(responses.Key2press(i-1)) ~= "Fixation"
                if string(responses.Saccade2make(i)) == "Fixation"
                    result{i,1} = {'Late response to previous trial'};
                else
                    result{i,1} = char(string(responses.Result_ET(i)));
                end
            elseif string(responses.Result_ET(i)) == "Correct" && ... 
                    string(responses.Saccade2make(i)) == "Fixation" && ...
                    string(responses.Result_KP(i)) ~= "Correct"
                result{i,1} = char(string(responses.Result_KP(i)));
            elseif string(responses.Result_ET(i)) ~= "Correct" && ... 
                    string(responses.Key2press(i)) == "Fixation" && ...
                    string(responses.Result_KP(i)) == "Correct"
                result{i,1} = char(string(responses.Result_ET(i)));
            elseif (string(responses.Result_ET(i)) == "Error" && ...
                ~contains(string(responses.Result_KP(i)), "anticipated")) ...
                || (string(responses.Result_KP(i)) == "Error" && ...
                    ~contains(string(responses.Result_ET(i)), "anticipated"))
                result{i,1} = {'Error'};
            elseif string(responses.Result_ET(i)) == "Error (anticipated)" || ...
                    string(responses.Result_KP(i)) == "Error (anticipated)" || ...
                    string(responses.Result_ET(i)) == "Error" || ...
                    string(responses.Result_KP(i)) == "Error"
                result{i,1} = {'Error (anticipated)'};
            elseif string(responses.Result_ET(i)) == "Error (indecision)" || ...
                    string(responses.Result_KP(i)) == "Error (indecision)"
                result{i,1} = {'Error (indecision)'};
            elseif string(responses.Result_ET(i)) == "Error (anticipated indecision)" || ...
                    string(responses.Result_KP(i)) == "Error (anticipated indecision)"
                result{i,1} = {'Error (anticipated indecision)'};
            elseif (string(responses.Key2press(i)) ~= "Fixation" && ...
                    string(responses.Result_KP(i)) == "Correct" && ...
                    string(responses.Result_ET(i)) == "Action error (correct)") || ...
                    (string(responses.Result_KP(i)) == "Correct" && ...
                    string(responses.Key2press(i)) ~= "Fixation" && ...
                    (string(responses.Result_ET(i)) == "Action error (indecision error)" && ...
                    string(responses.Response_ET(i)) == string(responses.Response_KP(i))))
                result{i,1} = {'Both actions (correct +ET)'};
            elseif (string(responses.Saccade2make(i)) ~= "Fixation" && ...
                    string(responses.Result_ET(i)) == "Correct" && ...
                    string(responses.Result_KP(i)) == "Action error (correct)") || ...
                    (string(responses.Saccade2make(i)) ~= "Fixation" && ...
                    string(responses.Result_ET(i)) == "Correct (late)" && ...
                    string(responses.Result_KP(i)) == "Action error (correct)")
                result{i,1} = {'Both actions (correct +KP)'};
            elseif string(responses.Key2press(i)) ~= "Fixation" && ...
                    string(responses.Result_KP(i)) == "Correct (anticipated)" && ...
                    string(responses.Result_ET(i)) == "Action error (anticipated correct)"
                result{i,1} = {'Both actions (correct anticipated +ET)'};
            elseif string(responses.Key2press(i)) == "Fixation" && ...
                    string(responses.Result_ET(i)) == "Correct (anticipated)" && ...
                    (string(responses.Result_KP(i)) == "Action error (anticipated correct)" || ...
                    string(responses.Result_KP(i)) == "Action error (correct)")
                result{i,1} = {'Both actions (correct anticipated +KP)'};
            elseif string(responses.Result_KP(i)) == "Correct (anticipated)" && ...
                    (string(responses.Result_ET(i)) == "Action error (correct)" ...
                    || string(responses.Result_ET(i)) == "Action error (error)" ...
                    || string(responses.Result_ET(i)) == "Action error (late correct)" ...
                    || string(responses.Result_ET(i)) == "Action error (late error)" ...
                    || string(responses.Result_ET(i)) == "Action error (late indecision)")
                result{i,1} = {'Correct (anticipated)'};
            elseif string(responses.Result_KP(i)) == "Correct" && ...
                    (string(responses.Result_ET(i)) == "Action error (late correct)" ...
                    || string(responses.Result_ET(i)) == "Action error (late error)" ...
                    || string(responses.Result_ET(i)) == "Action error (late indecision)")
                result{i,1} = {'Correct'};
            elseif string(responses.Result_KP(i)) == "Action error (anticipated correct)" ...
                    && (string(responses.Result_ET(i)) == "Correct" || ...
                    string(responses.Result_ET(i)) == "Correct (late)")
                result{i,1} = {'Both actions (correct +KP anticipated)'};
            elseif string(responses.Result_ET(i)) == "Action error (anticipated correct)" ...
                    && (string(responses.Result_KP(i)) == "Correct" || ...
                    string(responses.Result_KP(i)) == "Correct (late)")
                result{i,1} = {'Both actions (correct +ET anticipated)'};
            elseif string(responses.Result_ET(i)) == "Correct" && ...
                    string(responses.Result_KP(i)) == "Action error (anticipated error)"
                result{i,1} = {'Both actions (+KP anticipated error)'};
            elseif string(responses.Result_ET(i)) == "Action error (anticipated indecision)" ...
                    && string(responses.Result_KP(i)) == "Correct (anticipated)"
                result{i,1} = {'Both actions (+ET anticipated indecision)'};
            elseif (string(responses.Result_KP(i)) == "Error (no-go)" || ...
                    string(responses.Result_KP(i)) == "Late response to previous trial") && ...
                    string(responses.Result_ET(i)) ~= "Correct"
                result{i,1} = char(string(responses.Result_ET(i)));
            elseif string(responses.Result_KP(i)) == "Late response to previous trial" && ...
                    string(responses.Result_ET(i)) == "Correct" && ...
                    string(responses.Saccade2make(i)) ~= "Fixation"
                result{i,1} = {'Correct'};
            elseif string(responses.Result_ET(i)) == "Error (no-go)" && ...
                    string(responses.Result_KP(i)) ~= "Correct"
                result{i,1} = char(string(responses.Result_KP(i)));
            elseif (string(responses.Result_ET(i)) == "Action error (anticipated error)" ...
                    && string(responses.Result_KP(i)) == "Correct (anticipated)") || ...
                    (string(responses.Result_KP(i)) == "Action error (anticipated error)" ...
                    && string(responses.Result_ET(i)) == "Correct (anticipated)") || ...
                    (string(responses.Result_ET(i)) == "Action error (anticipated error)" ...
                    && string(responses.Result_KP(i)) == "Correct") || ...
                    (string(responses.Result_ET(i)) == "Action error (anticipated indecision)" ...
                    && string(responses.Result_KP(i)) == "Correct") || ...
                    (string(responses.Result_ET(i)) == "Action error (indecision error)" ...
                    && string(responses.Result_KP(i)) == "Correct") || ...
                    (string(responses.Result_ET(i)) == "Action error (indecision error)" ...
                    && string(responses.Result_KP(i)) == "Correct (anticipated)") ||...
                    (string(responses.Result_ET(i)) == "Correct (late)" ...
                    && string(responses.Result_KP(i)) == "Action error (anticipated error)") || ...
                    (string(responses.Result_ET(i)) == "Correct (anticipated)" ...
                    && string(responses.Result_KP(i)) == "Action error (error)")
                result{i,1} = {'Anticipated error (both actions contradictory)'};
            elseif string(responses.Result_ET(i)) == "Action error (error)" ...
                    && string(responses.Result_KP(i)) == "Correct"
                result{i,1} = {'Error (both actions contradictory)'};
            elseif contains(string(responses.Result_ET(i)), "Error") && ...
                    string(responses.Result_ET(i)) ~= "Error (no-go)" && ...
                    string(responses.Result_KP(i)) == "Action error (error)"
                result{i,1} = {'Both actions (error +KP)'};
            elseif string(responses.Result_ET(i)) == "Error (late)" ...
                    && string(responses.Result_KP(i)) == "Action error (anticipated error)"
                result{i,1} = {'Both actions (late error +KP anticipated error)'};
            elseif string(responses.Result_ET(i)) == "Lost data"
                result{i,1} = {'Lost data'};
            else
                result{i,1} = {'XXXXXXX'};
                fprintf("ERROR!<----") % We need to define a new type of response
                disp(sub);
                disp(nrun);
            end
            
        end
        %% 
        result = array2table(result, 'VariableNames', {'Result'});
        responses = [responses result];
        
        save(strcat(dir_files,'protocol/results_', nrun, '.mat'), 'responses');
        
    end
end