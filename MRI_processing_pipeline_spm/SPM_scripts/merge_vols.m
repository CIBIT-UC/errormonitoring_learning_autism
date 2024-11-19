% Geometric Distortions Correction - merge volumes to compute topup 

% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*'); 
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*'); 
%% 
for i = 1:size(data,1)
    
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    fprintf(data(i).name);
        
    for j = 1:size(data_func, 1)
                    
        images_ap = [data_func(j).folder, '/', data_func(j).name, '/', data_func(j).name, '_first.nii.gz'];
        images_pa = [data_func(j).folder, '/', data_func(j).name, '/', data_func(j).name, '_pa_last.nii.gz'];
        output_folder = [data_func(j).folder, '/', data_func(j).name, '/', data_func(j).name, '_ap_pa.nii.gz'];
                    
        cmd=sprintf(['fslmerge -t ' output_folder, ' ',  images_ap, ' ', images_pa]);
        system(cmd);
        
    end
end
    
   
                    