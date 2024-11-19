%% 
% ================= PARTICIPANT MEAN REACTION TIME =================

%%
clear all; close all; clc;
group = "A";    % P = non-autistic; A = autistic 
%%
mean_rt = {};
idx=1;
for s = 1:15 
    
    if s < 10
        sub = strcat(group,'0',num2str(s));
    else
        sub = strcat(group,num2str(s));
    end
    
    dir_files = strcat('F:\SEM_mri_rawdata\', sub, '\'); % Directoria
    
    if sub == "A09" || sub == "A15"
        runs = [1:5];
    else
        runs = [1:7];
    end
    
    for r = runs
        
        nrun = strcat('R',num2str(r));
        responses = load(strcat(dir_files, 'protocol\results_RT_', nrun, '.mat'));
        responses = responses.responses;
        triggers = load(strcat(dir_files, 'mat_files\', sub, '_', nrun, '.mat'));
        start_time = triggers.Output.Run.run_initTime;
        triggers = triggers.Output.Run.dataMat;
        triggers(5:10,:) = triggers(5:10,:) - start_time;
        
        reaction_duration = zeros(48,1);
        reaction_duration = array2table(reaction_duration, 'VariableNames', {'Reaction_duration'});
        responses = [responses reaction_duration];
        
        for i=1:height(responses)
            responses.Reaction_duration(i) = round(responses.Reaction_time(i) - triggers(8,i),1);
        end
        
        mean_rt{idx,1} = sub;
        mean_rt{idx,2} = nrun;
        mean_rt{idx,3} = mean(responses.Reaction_duration(find(string(responses.Saccade2make) ~= "Fixation"...
            & string(responses.Result) ~= "Error (no-go)")));
        mean_rt{idx,4} = mean(responses.Reaction_duration(find(string(responses.Key2press) ~= "Fixation"...
            & string(responses.Result) ~= "Error (no-go)")));
        idx=idx+1;
        
    end
end

%% Create table and save file

mean_rt_table = array2table(mean_rt, 'VariableNames', {'Participant'; 'Run';...
    'Mean_rt_sac'; 'Mean_rt_kp'});
if group == "P"
    save('F:\SEM_mri_rawdata\mean_rt.mat', 'mean_rt_table_non-autistic');
else
    save('F:\SEM_mri_rawdata\mean_rt.mat', 'mean_rt_table_autistic');
end