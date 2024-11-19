
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 
sub = 1;
for i = 1:size(data,1)
    
    fprintf(data(i).name);
    
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    data_anat = [data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/anat'];
    
    anat_files = dir(fullfile(data_anat, "*.nii"));
    def_field = anat_files(startsWith(string(char(anat_files.name)), "y_"));
    def_field = [def_field.folder, '/', def_field.name];
    
    scans = [];
    for j =  1:size(data_func,1)
        
        func_imag = [data_func(j).folder, '/', data_func(j).name, '/ra', data_func(j).name, '_biasfield_topup_4D.nii'];
        images = spm_vol(func_imag);
       
        for k = 1:size(images,1)

            images_n = images(k).n;
            index = num2str(images_n(1));
            scan{1,1} = [images(k).fname, ',', index];
            scans = [scans; scan];

        end
    end

    matlabbatch{1}.spm.spatial.normalise.write.subj(sub).def = {def_field};    
    matlabbatch{1}.spm.spatial.normalise.write.subj(sub).resample = scans;
    
    sub = sub+1;
  
end

matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [NaN NaN NaN
                                                          NaN NaN NaN];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [NaN NaN NaN];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
