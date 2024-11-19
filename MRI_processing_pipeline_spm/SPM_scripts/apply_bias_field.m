
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 
    for i = 1:size(data,1)
        
        data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
        fprintf(data(i).name);
         
        for j = 1:size(data_func,1)
            
            dir_folder = [data_func(j).folder, '/', data_func(j).name];
            
            bias_field_file = [dir_folder, '/BiasField_meanra', data_func(j).name, '_topup_4D.nii'];  
            scans = [dir_folder, '/ra', data_func(j).name, '_topup_4D.nii'];        
            
            %Load nii
            bias_field_struct = load_untouch_nii(bias_field_file);
            scans_struct = load_untouch_nii(scans);

            bias_field = bias_field_struct.img;
            func_images = scans_struct.img;
            dim_func_images = size(func_images);
            dim_bias_field = size(bias_field);
            
            % Vec images
            func_images_vec = reshape(double(func_images), [dim_func_images(1)*dim_func_images(2)*dim_func_images(3), dim_func_images(4)])';
            bias_field_vec = reshape(bias_field, [1, dim_bias_field(1)*dim_bias_field(2)*dim_bias_field(3)]);
            
            % Apply bias field
            new_scans = func_images_vec.*bias_field_vec;

            % Restruct images into 4D 
            bias_corr_imgs = reshape(new_scans', [dim_func_images(1), dim_func_images(2), dim_func_images(3), dim_func_images(4)]);
            bias_corr_imgs = int16(bias_corr_imgs);
            scans_struct_copy = scans_struct; clear scans_struct;
            scans_struct_copy.img = bias_corr_imgs;
            
            % Save new images
            path = [dir_folder, '/ra', data_func(j).name,'_biasfield_topup_4D.nii'];
            save_untouch_nii(scans_struct_copy, path);
        end
     end
       
   
    
