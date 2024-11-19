% Geometric Distortions Correction - compute topup 

% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
datain='/DATAPOOL/ERRORMONITORING/SEM_mri_data/datain.txt';
%% 
for i = 1:size(data,1)
        
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    fprintf(data(i).name);
    
    for j = 1:size(data_func,1)
        
        images_ap_pa = [data_func(j).folder, '/', data_func(j).name, '/', data_func(j).name, '_ap_pa.nii.gz'];
        output_results = [data_func(j).folder, '/', data_func(j).name, '/', data_func(j).name, '_topup_results'];
        output_images = [data_func(j).folder, '/', data_func(j).name, '/', data_func(j).name, '_topup_images'];
                    
        cmd=sprintf(['topup --imain=' images_ap_pa, ' --datain=', datain, ' --config=b02b0.cnf', ' --out=', output_results, ' --iout=', output_images]);
        system(cmd);
    end
end
   