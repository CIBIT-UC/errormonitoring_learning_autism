
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/');
ind=1;

contrasts = ["error-correct", "error-baseline", "correct-baseline", ...
    "instruction-baseline", "response-baseline", "runs2_response", ...
    "runs3_response", "runs2_error", "runs3_error", "runs2_correct", ...
    "runs3_correct", "runs1_response", "err-corr_initial", "err-corr_late-init"];

subs = [3:17,19,21,26,27,31,33,36:size(data,1)-1];
%% 
for c = 1:length(contrasts) 
    
    directory = ['/DATAPOOL/home/cdias/errorMonitoring_fMRI/group_level_analysis/', char(contrasts(c))]; 
    
    scans_non_autistic=[];
    scans_autistic=[];
    
    for i = subs
        
        disp(data(i).name);
        
        if c < 10
            scan{1,1} = [data(i).folder, '/', data(i).name, '/mri/SEM_', ...
                data(i).name, '/nifti/GLM/con_000', num2str(c), '.nii,1']; 
        else
            scan{1,1} = [data(i).folder, '/', data(i).name, '/mri/SEM_', ...
                data(i).name, '/nifti/GLM/con_00', num2str(c), '.nii,1']; 
        end
        
        if ismember(i,[3:17])
            scans_autistic = [scans_autistic; scan];
        else
            scans_non_autistic = [scans_non_autistic; scan];
        end

    end

    matlabbatch{ind}.spm.stats.factorial_design.dir = {directory};
    matlabbatch{ind}.spm.stats.factorial_design.des.t2.scans1 = scans_non_autistic;
    matlabbatch{ind}.spm.stats.factorial_design.des.t2.scans2 = scans_autistic;
    matlabbatch{ind}.spm.stats.factorial_design.des.t2.dept = 0;
    matlabbatch{ind}.spm.stats.factorial_design.des.t2.variance = 1;
    matlabbatch{ind}.spm.stats.factorial_design.des.t2.gmsca = 0;
    matlabbatch{ind}.spm.stats.factorial_design.des.t2.ancova = 0;
    matlabbatch{ind}.spm.stats.factorial_design.cov(1).c = [27 24 37 27 38 38 ...
        23 28 29 35 39 24 25 39 28 30 29 25 50 25 20 25 22 24 28 25 20 36 45 32];
    matlabbatch{ind}.spm.stats.factorial_design.cov(1).cname = 'Age';
    matlabbatch{ind}.spm.stats.factorial_design.cov(1).iCFI = 1;
    matlabbatch{ind}.spm.stats.factorial_design.cov(1).iCC = 1;
    matlabbatch{ind}.spm.stats.factorial_design.cov(2).c = [133 119 153 117 145 ...
        133 139 126 143 135 140 128 124 137 129 117 126 114 117 81 122 121 113 ...
        99 102 137 98 133 113 108];
    matlabbatch{ind}.spm.stats.factorial_design.cov(2).cname = 'IQ';
    matlabbatch{ind}.spm.stats.factorial_design.cov(2).iCFI = 1;
    matlabbatch{ind}.spm.stats.factorial_design.cov(2).iCC = 1;
    matlabbatch{ind}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{ind}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{ind}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{ind}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{ind}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{ind}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{ind}.spm.stats.factorial_design.globalm.glonorm = 1;
    
    ind = ind+1;
end
