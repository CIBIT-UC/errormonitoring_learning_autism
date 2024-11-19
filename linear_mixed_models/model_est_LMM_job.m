
ind = 1;
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*'); 
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*'); 
%% 
for i = 1:size(data,1)
        
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    
    for j = 1:size(data_func,1)
        
        spm_folder = [data_func(j).folder, '/', data_func(j).name, '/GLM_LMM/'];

        if exist([spm_folder, '/SPM.mat'])
            
            file = [spm_folder, '/SPM.mat'];

            matlabbatch{ind}.spm.stats.fmri_est.spmmat = {file};
            matlabbatch{ind}.spm.stats.fmri_est.write_residuals = 0; 
            matlabbatch{ind}.spm.stats.fmri_est.method.Classical = 1;
            ind = ind + 1;

        end
    end

end
