
ind = 1;
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 
for i = 1:size(data,1)

    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    fprintf(data(i).name);

    for j = 1:size(data_func,1)

        images = [data_func(j).folder, '/', data_func(j).name, '/SEM_', data(i).name, '_R', ...
                data_func(j).name(2:end) , '_AP_SMS3_TR1000_2.nii'];
        images_struct = spm_vol(images);
        volumes = [];

        for l = 1:size(images_struct,1)
            func_struct_n = images_struct(l).n;
            index = num2str(func_struct_n(1));
            volume{1,1} = [images_struct(l).fname, ',', index];
            volumes = [volumes; volume];
        end
        
        matlabbatch{ind}.spm.temporal.st.scans = {volumes};
        matlabbatch{ind}.spm.temporal.st.nslices = 42; 
        matlabbatch{ind}.spm.temporal.st.tr = 1; 
        matlabbatch{ind}.spm.temporal.st.ta = 0; 
        matlabbatch{ind}.spm.temporal.st.so = [0,0.21,0.42,0.63,0.84,0.07,0.28,0.49,...
            0.7,0.91,0.14,0.35,0.56,0.77,0,0.21,0.42,0.63,0.84,0.07,0.28,0.49,0.7,0.91,...
            0.14,0.35,0.56,0.77,0,0.21,0.42,0.63,0.84,0.07,0.28,0.49,0.7,0.91,0.14,0.35,0.56,0.77];
        matlabbatch{ind}.spm.temporal.st.refslice = 0; 
        matlabbatch{ind}.spm.temporal.st.prefix = 'a';
        ind = ind + 1;
    end
end
    
