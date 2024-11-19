
contrasts = ["error-correct", "error-baseline", "correct-baseline", ...
    "instruction-baseline", "response-baseline", "runs2_response", ...
    "runs3_response", "runs2_error", "runs3_error", "runs2_correct", ...
    "runs3_correct", "runs1_response"];
ind=1;
%% 
for c = 1:length(contrasts)
    
    SPM_file = ['/DATAPOOL/ERRORMONITORING/group_level_analysis/', char(contrasts(c)), '/SPM.mat']; 

    matlabbatch{ind}.spm.stats.fmri_est.spmmat = {SPM_file};
    matlabbatch{ind}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{ind}.spm.stats.fmri_est.method.Classical = 1;
    ind = ind+1;
    
end
