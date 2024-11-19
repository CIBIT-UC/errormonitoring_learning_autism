% Geometric distortions correction - apply topup script

% Participants data
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
directions = '/DATAPOOL/ERRORMONITORING/SEM_mri_data/datain.txt';
%% 
for i = 1:size(data,1)
    
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    fprintf(data(i).name);
    
    for j = 1:size(data_func,1)
        
        % Images after slice timing and motion correction 
        images = [data_func(j).folder, '/', data_func(j).name, '/raSEM_', data(i).name, '_R', ...
                data_func(j).name(2:end) , '_AP_SMS3_TR1000_2.nii'];
        
        topup_results = [data_func(j).folder, '/', data_func(j).name, '/', data_func(j).name, '_topup_results'];
        output_images = [data_func(j).folder, '/', data_func(j).name, '/ra', data_func(j).name, '_topup_4D.nii'];
        
        % Correct mean image to take bias field
        mean_images = [data_func(j).folder, '/', data_func(j).name, '/meanraSEM_', data(i).name, '_R', ...
                data_func(j).name(2:end) , '_AP_SMS3_TR1000_2.nii'];
            
        output_mean_images = [data_func(j).folder, '/', data_func(j).name, '/', 'meanra',data_func(j).name, '_topup_4D.nii'];
                               
        cmd_01=sprintf(['applytopup --imain=', images, ' ', '--datain=', directions, ' ', '--inindex=1 --topup=', topup_results, ' ', '--out=', output_images, ' ', '--method=jac']);
        system(cmd_01);
        gunzip([output_images, '.gz']);
                    
        cmd_02=sprintf(['applytopup --imain=', mean_images, ' ', '--datain=', directions, ' ', '--inindex=1 --topup=', topup_results, ' ', '--out=', output_mean_images, ' ', '--method=jac']);
        system(cmd_02);
        gunzip([output_mean_images, '.gz']);
                    
    end
end
