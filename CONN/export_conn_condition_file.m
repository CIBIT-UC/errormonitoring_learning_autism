%% 
% ================= EXPORT CONN CONDITION FILE =================

%% 
clear all; close all; clc;
%% 
part = 1;
idx=1;
for g = 1:2
    
    if g == 1
        group = "A";
        subs = 1:15;
    else
        group = "P";
        subs = [2,4,9,10,14,16,18:27]; 
    end
    
    for s = subs

        if s < 10
            sub = strcat(group,'0',num2str(s));
        else
            sub = strcat(group,num2str(s));
        end

        dir_files = strcat('F:\SEM_mri_rawdata\', sub, '\'); % Directoria

        if sub ~= "A09" && sub ~= "A15" && sub ~= "P10"
            runs = [1,2,6,7];
        elseif sub == "P10"
            runs = [1,2,6];
        else
            runs = [1,2];
        end

        for r = runs

            nrun = strcat('R',num2str(r));
            protocol = load(strcat(dir_files, 'protocol\protocol_', nrun, '.mat')); 
            protocol = protocol.protocol;

            for t=1:length(protocol) 

                if r == 1 || r == 2
                    file{idx,1} = strcat(protocol{t,1}, "_first");
                    file{idx,2} = part;
                    file{idx,3} = r;
                else
                    file{idx,1} = strcat(protocol{t,1}, "_last");
                    file{idx,2} = part;
                    file{idx,3} = r-3;
                end
                file{idx,4} = protocol{t,3};
                file{idx,5} = protocol{t,4};

                idx = idx+1;

                %   condition_name, subject_number, session_number, onsets, durations
                %   task, 1, 1, 0 50 100 150, 25 (ex)
            end
        end
        part = part+1;
    end
end
    %% Save file
file_table = array2table(file, 'VariableNames', {'condition_name', ...
    'subject_number', 'session_number', 'onsets', 'durations'});
writetable(file_table, 'F:\SEM_mri_rawdata\conditions_conn.txt');
