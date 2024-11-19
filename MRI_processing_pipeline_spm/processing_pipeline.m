%===============================Preprocessing_Pipeline for MRI data===============================

% Geometric Distortions Correction - Compute topup
run('extract_vols.m');
run('merge_vols.m');
run('compute_topup.m'); 

% Slice Timing Correction 
run('slice_timing.m'); 

%Motion Correction
run('motion_correction_unwarp.m');
 
% Geometric Distortions Correction - Apply topup
run('apply_topup.m');

% Bias Field Correction 
run('save_bias_field.m');
run('apply_bias_field.m');

% Coregistration 
run('coregistration_func_to_anat.m'); 

% Regression for denoising 
run('regression_physio.m'); % to compute noise regressors, com TAPAS toolbox

% Normalization
run('segmentation_t1.m')
run('normalization_func.m')
run('normalization_anat.m')

% Smoothing
run('smoothing.m');

% GLM 
run('model_spec.m'); 
run('model_est.m'); 
run('define_contrasts.m'); 
run('model_spec_2nd_between.m'); 
run('model_est_2nd.m'); 
