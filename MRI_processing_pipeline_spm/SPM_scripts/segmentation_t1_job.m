
ind = 1;
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 
for i = 1:size(data,1)
    
    data_anat = [data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/anat'];
    fprintf(data(i).name);
    anat_image = dir(fullfile(data_anat, "*.nii"));
    anat_image = [anat_image.folder, '/', anat_image.name];
    
    matlabbatch{ind}.spm.spatial.preproc.channel.vols = {anat_image};
    matlabbatch{ind}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{ind}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{ind}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{ind}.spm.spatial.preproc.tissue(1).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,1'};
    matlabbatch{ind}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{ind}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(2).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,2'};
    matlabbatch{ind}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{ind}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(3).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,3'};
    matlabbatch{ind}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{ind}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(4).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,4'};
    matlabbatch{ind}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{ind}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(5).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,5'};
    matlabbatch{ind}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{ind}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(6).tpm = {'/SCRATCH/software/toolboxes/spm12/tpm/TPM.nii,6'};
    matlabbatch{ind}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{ind}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{ind}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{ind}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{ind}.spm.spatial.preproc.warp.cleanup = 0;
    matlabbatch{ind}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{ind}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{ind}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{ind}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{ind}.spm.spatial.preproc.warp.write = [0 1];
    matlabbatch{ind}.spm.spatial.preproc.warp.vox = NaN;
    matlabbatch{ind}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];
                                          
    ind = ind + 1;
end