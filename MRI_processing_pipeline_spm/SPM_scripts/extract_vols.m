% Geometric Distortions Correction - Extract volumes to compute topup 

% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*'); 
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*'); 
%% 
for i = 1:size(data,1)
        
     data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
     fprintf(data(i).name);
             
     for j = 1:size(data_func)

         func_nii = dir(fullfile([data_func(j).folder, '/', data_func(j).name], "*.nii.gz"));
         images_ap = func_nii(startsWith(string(char(func_nii.name)), [func_nii(1).name(1:6), '_SpinEchoFieldMap_AP']));
         images_ap = [images_ap.folder, '/', images_ap.name];
         images_pa = func_nii(startsWith(string(char(func_nii.name)), [func_nii(1).name(1:6), '_SpinEchoFieldMap_PA']));
         images_pa = [images_pa.folder, '/', images_pa.name];
         
         output_ap = [data_func(j).folder, '/', data_func(j).name, '/', data_func(j).name, '_first.nii.gz'];
         cmd_ap = sprintf(['fslroi ', images_ap, ' ', output_ap , ' 0', ' 1']);
         system(cmd_ap);
         
         output_pa = [data_func(j).folder, '/', data_func(j).name, '/', data_func(j).name, '_pa_last.nii.gz'];
         cmd_pa = sprintf(['fslroi ', images_pa, ' ', output_pa , ' 0', ' 1']);
         system(cmd_pa); 
         
     end
end
   