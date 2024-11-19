
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
ind=1;

contrasts = ["error-correct", "error-baseline", "correct-baseline", ...
    "instruction-baseline", "response-baseline", "runs2_response", ...
    "runs3_response", "runs2_error", "runs3_error", "runs2_correct", ...
    "runs3_correct", "runs1_response"];
%% 
for c = 1:length(contrasts) 
    
    directory = ['/DATAPOOL/home/cdias/errorMonitoring_fMRI/group_level_analysis/', char(contrasts(c))]; 
    
    scans=[];
    for i = 1:size(data,1)
        
        disp(data(i).name);
        
        if c < 10
            scan{1,1} = [data(i).folder, '/', data(i).name, '/mri/SEM_', ...
                data(i).name, '/nifti/GLM/con_000', num2str(c), '.nii,1']; 
        else
            scan{1,1} = [data(i).folder, '/', data(i).name, '/mri/SEM_', ...
                data(i).name, '/nifti/GLM/con_00', num2str(c), '.nii,1']; 
        end
        scans = [scans; scan];

    end

    matlabbatch{ind}.spm.stats.factorial_design.dir = {directory};
    matlabbatch{ind}.spm.stats.factorial_design.des.t1.scans = scans;
    matlabbatch{ind}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{ind}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{ind}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{ind}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{ind}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{ind}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{ind}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{ind}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    ind = ind+1;
end
