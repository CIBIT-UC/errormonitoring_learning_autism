%% 
% ================= Fusiform gyrus and pSTS activation following Instruction =================

clear all; clc
%% 
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/'); 
vois_dir = '/DATAPOOL/ERRORMONITORING/group_level_analysis/ROIs/Atlas/AAL3 and Brainnetome/';
fg_voi = [vois_dir, 'Fusiform_gyrus/FuG_bn.nii'];
psts_voi = [vois_dir, 'pSTS/pSTS.nii'];

subs = [3:17,19,21,26,27,31,33,36:size(data,1)-1];
%%
ii=1;
for i = subs
    
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    disp(data(i).name);

    runs = [1:size(data_func,1)];
    
    for j = runs
        
        disp(data_func(j).name);
        
        spm_folder = [data_func(j).folder, '/', data_func(j).name, '/GLM_LMM'];
        
        if exist(strcat(spm_folder, '/SPM.mat'))
            
            % Load SPM file
            SPM = load(strcat(spm_folder, '/SPM.mat'));
            SPM = SPM.SPM;
            
            if length(SPM.xX.name) < 100
                beta_file_base = [spm_folder, '/beta_00', ...
                    num2str(length(SPM.xX.name)), '.nii'];
            else
                beta_file_base = [spm_folder, '/beta_0', ...
                    num2str(length(SPM.xX.name)), '.nii'];
            end
            
            b_base_fg = mean(spm_summarise(beta_file_base, fg_voi));
            b_base_psts = mean(spm_summarise(beta_file_base, psts_voi));
            
            inst_idx = find(contains(SPM.xX.name, "Instruction"));
            if inst_idx<10
                beta_file = [spm_folder, '/beta_000', num2str(inst_idx), '.nii'];
            else
                beta_file = [spm_folder, '/beta_00', num2str(inst_idx), '.nii'];
            end
            
            b_fg = mean(spm_summarise(beta_file, fg_voi)); % Beta value Instruction (run j)
            sc_fg = b_fg/b_base_fg*100; % Signal change
            
            b_psts = mean(spm_summarise(beta_file, psts_voi)); % Beta value Instruction (run j)
            sc_psts = b_psts/b_base_psts*100; % Signal change

            data_fg{ii,1} = data(i).name;
            data_fg{ii,2} = data_func(j).name;
            data_fg{ii,3} = sc_fg;
            data_fg{ii,4} = sc_psts;
            
            ii=ii+1;

        end
    end
end
%% 
fg_table = cell2table(data_fg, 'VariableNames', ...
    {'Participant'; 'Run'; 'sc_fg'; 'sc_psts'});
writetable(fg_table, ...
    '/DATAPOOL/ERRORMONITORING/group_level_analysis/between-groups/results/fusiformGyrus_psts_instruction_signalChange.xlsx');
