
ind = 1;
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
%% 
for i = 1:size(data,1)
        
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    fprintf(data(i).name);
    
    for j = 1:size(data_func,1)
        
        dir_folder = [data_func(j).folder, '/', data_func(j).name, '/'];
        images = [dir_folder, 'meanra', data_func(j).name, '_topup_4D.nii'];
                    
        matlabbatch{ind}.spm.spatial.preproc.channel.vols = {images};
        matlabbatch{ind}.spm.spatial.preproc.channel.biasreg = 0.001;
        matlabbatch{ind}.spm.spatial.preproc.channel.biasfwhm = 60;
        matlabbatch{ind}.spm.spatial.preproc.channel.write = [1 1];
        matlabbatch{ind}.spm.spatial.preproc.tissue(1).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,1'};
        matlabbatch{ind}.spm.spatial.preproc.tissue(1).ngaus = 1;
        matlabbatch{ind}.spm.spatial.preproc.tissue(1).native = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(1).warped = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(2).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,2'};
        matlabbatch{ind}.spm.spatial.preproc.tissue(2).ngaus = 1;
        matlabbatch{ind}.spm.spatial.preproc.tissue(2).native = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(2).warped = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(3).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,3'};
        matlabbatch{ind}.spm.spatial.preproc.tissue(3).ngaus = 2;
        matlabbatch{ind}.spm.spatial.preproc.tissue(3).native = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(3).warped = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(4).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,4'};
        matlabbatch{ind}.spm.spatial.preproc.tissue(4).ngaus = 3;
        matlabbatch{ind}.spm.spatial.preproc.tissue(4).native = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(4).warped = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(5).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,5'};
        matlabbatch{ind}.spm.spatial.preproc.tissue(5).ngaus = 4;
        matlabbatch{ind}.spm.spatial.preproc.tissue(5).native = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(5).warped = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(6).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,6'};
        matlabbatch{ind}.spm.spatial.preproc.tissue(6).ngaus = 2;
        matlabbatch{ind}.spm.spatial.preproc.tissue(6).native = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.tissue(6).warped = [0 0];
        matlabbatch{ind}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{ind}.spm.spatial.preproc.warp.cleanup = 1;
        matlabbatch{ind}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
        matlabbatch{ind}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{ind}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{ind}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{ind}.spm.spatial.preproc.warp.write = [0 0];
        ind = ind + 1;
     end
 end
   
