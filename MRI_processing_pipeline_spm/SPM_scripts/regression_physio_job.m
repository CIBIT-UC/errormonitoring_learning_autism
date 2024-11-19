
ind = 1;
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 
for i = 1:size(data,1)
    
    fprintf(data(i).name);
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    
    for j = 1:size(data_func,1) 
        
        fprintf(data_func(j).name);
    
        directory = [data_func(j).folder, '/', data_func(j).name, '/regression_6MPs'];
        cardiac_file = [data_func(j).folder, '/', data_func(j).name, '/physio_logs/', data_func(j).name, '_PULS.log'];
        respiration_file = [data_func(j).folder, '/', data_func(j).name, '/physio_logs/', data_func(j).name, '_RESP.log'];
        timing_file = [data_func(j).folder, '/', data_func(j).name, '/physio_logs/', data_func(j).name, '_Info.log'];
        
        if ~exist(cardiac_file, 'file')
            
            cardiac_file = '';
        
        elseif ~exist(respiration_file, 'file')
            
            respiration_file = '';
            
        elseif ~exist(timing_file, 'file')
            
            timing_file = '';
        end
            
        func_files = dir([data_func(j).folder, '/', data_func(j).name]);
        realignment_parameters = func_files(startsWith(string(char(func_files.name)), "rp_a"));
        realignment_parameters = [realignment_parameters.folder, '/', realignment_parameters.name];
        
        TR = 1;
        
        fmri_files = [data_func(j).folder, '/', data_func(j).name, '/ra', data_func(j).name, '_biasfield_topup_4D.nii'];
        images_struct = spm_vol(fmri_files);
        Nscans = size(images_struct,1);  
        
        matlabbatch{ind}.spm.tools.physio.save_dir = {directory};
        matlabbatch{ind}.spm.tools.physio.log_files.vendor = 'Siemens_Tics';
        matlabbatch{ind}.spm.tools.physio.log_files.cardiac = {cardiac_file};
        matlabbatch{ind}.spm.tools.physio.log_files.respiration = {respiration_file};
        matlabbatch{ind}.spm.tools.physio.log_files.scan_timing = {timing_file};
        matlabbatch{ind}.spm.tools.physio.log_files.sampling_interval = [];
        matlabbatch{ind}.spm.tools.physio.log_files.relative_start_acquisition = 0; 
        matlabbatch{ind}.spm.tools.physio.log_files.align_scan = 'last'; 
        matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.Nslices = 42; 
        matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.NslicesPerBeat = [];
        matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.TR = TR;
        matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.Ndummies = 0;
        matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.Nscans = Nscans; 
        matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.onset_slice = 1;
        matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.time_slice_to_slice = [];
        matlabbatch{ind}.spm.tools.physio.scan_timing.sqpar.Nprep = [];
        matlabbatch{ind}.spm.tools.physio.scan_timing.sync.scan_timing_log = struct([]);
        matlabbatch{ind}.spm.tools.physio.preproc.cardiac.modality = 'PPU';
        matlabbatch{ind}.spm.tools.physio.preproc.cardiac.filter.yes.type = 'cheby2';
        matlabbatch{ind}.spm.tools.physio.preproc.cardiac.filter.yes.passband = [0.3 9];
        matlabbatch{ind}.spm.tools.physio.preproc.cardiac.filter.yes.stopband = [];
        matlabbatch{ind}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.min = 0.4;
        matlabbatch{ind}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.file = 'initial_cpulse_kRpeakfile.mat';
        matlabbatch{ind}.spm.tools.physio.preproc.cardiac.initial_cpulse_select.auto_matched.max_heart_rate_bpm = 90;
        matlabbatch{ind}.spm.tools.physio.preproc.cardiac.posthoc_cpulse_select.off = struct([]);
        matlabbatch{ind}.spm.tools.physio.preproc.respiratory.filter.passband = [0.01 2]; 
        matlabbatch{ind}.spm.tools.physio.preproc.respiratory.despike = false; 
        matlabbatch{ind}.spm.tools.physio.model.output_multiple_regressors = 'multiple_regressors.txt';
        matlabbatch{ind}.spm.tools.physio.model.output_physio = 'physio.mat';
        matlabbatch{ind}.spm.tools.physio.model.orthogonalise = 'none';
        matlabbatch{ind}.spm.tools.physio.model.censor_unreliable_recording_intervals = false;
        matlabbatch{ind}.spm.tools.physio.model.retroicor.yes.order.c = 3;
        matlabbatch{ind}.spm.tools.physio.model.retroicor.yes.order.r = 4;
        matlabbatch{ind}.spm.tools.physio.model.retroicor.yes.order.cr = 1;
        matlabbatch{ind}.spm.tools.physio.model.rvt.yes.method = 'hilbert'; 
        matlabbatch{ind}.spm.tools.physio.model.hrv.yes.delays = 0;
        matlabbatch{ind}.spm.tools.physio.model.noise_rois.no = struct([]);
        matlabbatch{ind}.spm.tools.physio.model.movement.yes.file_realignment_parameters = {realignment_parameters};
        matlabbatch{ind}.spm.tools.physio.model.movement.yes.order = 6;
        matlabbatch{ind}.spm.tools.physio.model.movement.yes.censoring_method = 'FD'; 
        matlabbatch{ind}.spm.tools.physio.model.movement.yes.censoring_threshold = 0.5;
        matlabbatch{ind}.spm.tools.physio.model.other.no = struct([]);
        matlabbatch{ind}.spm.tools.physio.verbose.level = 0; 
        matlabbatch{ind}.spm.tools.physio.verbose.fig_output_file = '';
        matlabbatch{ind}.spm.tools.physio.verbose.use_tabs = false;
        ind = ind + 1;
    end
end
