
ind = 1;
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 

 for i = 1:size(data,1)
     
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    data_anat = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/anat']);
    fprintf(data(i).name);
    
    anat_image = dir(fullfile(data_anat(1).folder, '*.nii'));
    anat_image = [anat_image.folder, '/', anat_image.name];

    for j = 1:size(data_func,1)
        
        dir_folder = [data_func(j).folder, '/', data_func(j).name];
        func_runs = [dir_folder, '/mmeanra', data_func(j).name, '_topup_4D.nii'];
        func_images = spm_vol([dir_folder, '/ra', data_func(j).name, '_biasfield_topup_4D.nii']);
    
        others = [];
      
        for k = 1:size(func_images,1)
        
            func_images_n = func_images(k).n;
            index = num2str(func_images_n(1));
            other{1,1} = [func_images(k).fname, ',', index];
            others = [others; other];
            
        end
%            
        matlabbatch{ind}.spm.spatial.coreg.estimate.ref = {anat_image};
        matlabbatch{ind}.spm.spatial.coreg.estimate.source = {func_runs};
        matlabbatch{ind}.spm.spatial.coreg.estimate.other = others;
        matlabbatch{ind}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
        matlabbatch{ind}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
        matlabbatch{ind}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{ind}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
        ind = ind + 1;
    end
    
end

