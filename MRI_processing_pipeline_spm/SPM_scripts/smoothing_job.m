
ind = 1;
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 

for i = 1:size(data,1)
        
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);

    for j = 1:size(data_func,1)

        images = [data_func(j).folder, '/', data_func(j).name, '/wra', data_func(j).name, '_biasfield_topup_4D.nii'];

        if exist(images)

            images_struct = spm_vol(images);

            volumes = [];

            for l = 1:size(images_struct,1)

                func_struct_n = images_struct(l).n;
                index = num2str(func_struct_n(1));
                volume{1,1} = [images_struct(l).fname, ',', index];
                volumes = [volumes; volume];
            end

            matlabbatch{ind}.spm.spatial.smooth.data = volumes;
            matlabbatch{ind}.spm.spatial.smooth.fwhm = [7.5 7.5 7.5];
            matlabbatch{ind}.spm.spatial.smooth.dtype = 0;
            matlabbatch{ind}.spm.spatial.smooth.im = 0;
            matlabbatch{ind}.spm.spatial.smooth.prefix = 's7.5_';
            ind = ind + 1;

        else
            fprintf([data(i).name, ', ', data_func(j).name, '\n']);
        end
    end
end
   