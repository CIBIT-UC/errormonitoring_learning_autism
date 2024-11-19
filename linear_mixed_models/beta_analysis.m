clear all; clc
%% 

data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/'); 
vois_dir = '/DATAPOOL/ERRORMONITORING/group_level_analysis/ROIs/Atlas/AAL3 and Brainnetome/';
dACC_voi = [vois_dir, 'ACC/dACC/A32p_BN.nii'];
rACC_voi = [vois_dir, 'ACC/rACC/rACC.nii'];
AI_voi = [vois_dir, 'bilateral_AI/bilateral_AI_BN.nii'];
put_voi = [vois_dir, 'putamen/bilateral_putamen_ventromedial_BN.nii'];

subs = [3:17,19,21,26,27,31,33,36:size(data,1)-1];

mixed_model = {};
idx = 1;
%% 
for i = subs
    
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    disp (data(i).name);
        
    trial_nr=0;
    
    runs = [1:size(data_func,1)];
    
    for j = runs
        
        disp (data_func(j).name);
        spm_folder = [data_func(j).folder, '/', data_func(j).name, '/GLM_LMM'];
        
        if exist(strcat(spm_folder, '/SPM.mat'))
            
            % Load SPM file
            SPM = load(strcat(spm_folder, '/SPM.mat'));
            SPM = SPM.SPM;
            
            % Load protocol
            protocol = load([data(i).folder, '/', data(i).name, '/protocol/protocol_R', ...
                data_func(j).name(end), '.mat']);
            protocol = protocol.protocol;
            
            trials = find(contains(SPM.xX.name, "resp_idx_"));
            
            if length(SPM.xX.name) < 100
                beta_file_base = [spm_folder, '/beta_00', ...
                    num2str(length(SPM.xX.name)), '.nii'];
            else
                beta_file_base = [spm_folder, '/beta_0', ...
                    num2str(length(SPM.xX.name)), '.nii'];
            end
            
            b_base_dACC = mean(spm_summarise(beta_file_base, dACC_voi));
            b_base_rACC = mean(spm_summarise(beta_file_base, rACC_voi));
            b_base_AI = mean(spm_summarise(beta_file_base, AI_voi));
            b_base_put = mean(spm_summarise(beta_file_base, put_voi));

            for t = trials
                
                trial_nr = trial_nr+1;
                
                if contains(data(i).name, 'A')
                    mixed_model{idx,1} = "autistic";        % Group
                else
                    mixed_model{idx,1} = "non-autistic";    % Group
                end
                
                mixed_model{idx,2} = data(i).name;        % Participant
                mixed_model{idx,3} = str2num(data_func(j).name(end));   % Run
                
                cond_name = char(SPM.xX.name(t));
                if length(str2num(cond_name(16:17))) == 0
                    ntrial = str2num(cond_name(16));
                else
                    ntrial = str2num(cond_name(16:17));
                end

                progreen = [1,2,5,6];
                prored = [9,10,13,14];
                antigreen = [3,4,7,8];
                antired = [11,12,15,16];
                if sum(ismember(progreen, protocol{ntrial,5})) == 1
                    mixed_model{idx,4} = "Pro_green";        % Instruction
                elseif sum(ismember(prored, protocol{ntrial,5})) == 1
                    mixed_model{idx,4} = "Pro_red";        % Instruction
                elseif sum(ismember(antigreen, protocol{ntrial,5})) == 1
                    mixed_model{idx,4} = "Anti_green";        % Instruction
                elseif sum(ismember(antired, protocol{ntrial,5})) == 1
                    mixed_model{idx,4} = "Anti_red";        % Instruction
                end

                if protocol{ntrial,1} == "Correct"
                    mixed_model{idx,5} = "Correct";        % Performance
                elseif protocol{ntrial,1} == "Error"
                    mixed_model{idx,5} = "Error";        % Performance
                end
                                
                if t<10
                    beta_file = [spm_folder, '/beta_000', num2str(t), '.nii'];
                else
                    beta_file = [spm_folder, '/beta_00', num2str(t), '.nii'];
                end

                % Signal change dACC
                b_dACC = mean(spm_summarise(beta_file, dACC_voi));
                mixed_model{idx,6} = b_dACC/b_base_dACC*100; % Signal change
                
                % Signal change rACC
                b_rACC = mean(spm_summarise(beta_file, rACC_voi));
                mixed_model{idx,7} = b_rACC/b_base_rACC*100; % Signal change
                
                % Signal change AI
                b_AI = mean(spm_summarise(beta_file, AI_voi));
                mixed_model{idx,8} = b_AI/b_base_AI*100; % Signal change

                % Signal change putamen
                b_put = mean(spm_summarise(beta_file, put_voi));
                mixed_model{idx,9} = b_put/b_base_put*100;  % Signal change
                
                idx = idx+1;
                
            end
        
        end
    end
end

%% Create and save table

mixed_model_table = cell2table(mixed_model, 'VariableNames', ...
    {'Participant'; 'Run'; 'Instruction'; 'Performance'; ...
    'sc_dACC'; 'sc_rACC'; 'sc_AI'; 'sc_put'});

writetable(mixed_model_table, ...
    '/DATAPOOL/ERRORMONITORING/group_level_analysis/signal_change_data.xlsx');
