%% 
% =================== BEHAVIORAL ANALYSIS: MIXED MODEL ====================

% Mixed model to study the impact of the group, run, and instruction on the
% error rate.

%% 
clc; clear all; close all
responses_description = ...
    readtable('F:\SEM_mri\MRI\Behavioral analysis\responses_description_both_groups.xls');
qi_data = readtable('F:\SEM_mri\MRI\Beta analysis\Mixed model\between groups\qi.xlsx');
age_data = readtable('F:\SEM_mri\MRI\Beta analysis\Mixed model\between groups\age.xlsx');

%% 

instruction = ["Pro_green", "Pro_red", "Anti_green", "Anti_red"];

idx = 1;
for g=1:2
    
    if g ==1 
        group = "P";
        subs = [2,4,9,10,14,16,19:27];
    else
        group = "A";
        subs = [1:15];
    end
    
    for s=subs
                
        if group == "A" && (s==9 || s==15)
            runs = [1:5];
        else
            runs = [1:7];
        end

        for r=runs          
            for i=1:4       

                mixed_model{idx,1} = g;                         % Group
                mixed_model{idx,2} = strcat(group,mat2str(s));  % Participant
                mixed_model{idx,3} = r;                         % Run
                mixed_model{idx,4} = instruction(i);            % Instruction

                N_errors = sum(responses_description.Group==g & responses_description.Participant==s & ...
                    responses_description.Run==r & responses_description.Instruction==instruction(i) & ...
                    responses_description.Performance=="Error");
                N_correct = sum(responses_description.Group==g & responses_description.Participant==s & ...
                    responses_description.Run==r & responses_description.Instruction==instruction(i) & ...
                    responses_description.Performance=="Correct");
                mixed_model{idx,5} = N_errors/(N_errors+N_correct);
                
                mixed_model{idx,6} = ...
                    age_data.Age(find(string(age_data.Participant_ID) == strcat(group,mat2str(s)) | ...
                    string(age_data.Participant_ID) == strcat(group,'0',mat2str(s))));
                if strcat(group,mat2str(s)) == "P16"
                    mixed_model{idx,7} = "NaN";
                else
                    mixed_model{idx,7} = ...
                        qi_data.QI(find(string(qi_data.Participant_ID) == strcat(group,mat2str(s)) | ...
                        string(qi_data.Participant_ID) == strcat(group,'0',mat2str(s))));
                end

                idx = idx+1;

            end
        end
    end
end
%% Save table

mixed_model(isnan(cell2mat(mixed_model(:,5))),:) = [];  % Remove NaNs
mixed_model_table = array2table(mixed_model, 'VariableNames', ...
    {'Group', 'Participant', 'Run', 'Instruction', 'Error_rate', 'Age' 'IQ'});

writetable(mixed_model_table, ...
    strcat('F:\SEM_mri\MRI\Behavioral analysis\mixed_model_groups.xls'));
