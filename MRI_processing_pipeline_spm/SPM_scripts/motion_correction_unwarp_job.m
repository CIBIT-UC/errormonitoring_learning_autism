
ind = 1;
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 
 for i = 1:size(data,1)
        
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    fprintf(data(i).name);

    for j = 1:size(data_func,1)

        images = [data_func(j).folder, '/', data_func(j).name, '/aSEM_', data(i).name, '_R', ...
                data_func(j).name(2:end) , '_AP_SMS3_TR1000_2.nii'];
        images_struct = spm_vol(images);
        volumes = [];

        for l = 1:size(images_struct,1)
             func_struct_n = images_struct(l).n;
             index = num2str(func_struct_n(1));
             volume{1,1} = [images_struct(l).fname, ',', index];
             volumes = [volumes; volume];
        end

        matlabbatch{ind}.spm.spatial.realignunwarp.data.scans = volumes;
        matlabbatch{ind}.spm.spatial.realignunwarp.data.pmscan = '';
        matlabbatch{ind}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
        matlabbatch{ind}.spm.spatial.realignunwarp.eoptions.sep = 4;
        matlabbatch{ind}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
        matlabbatch{ind}.spm.spatial.realignunwarp.eoptions.rtm = 0;
        matlabbatch{ind}.spm.spatial.realignunwarp.eoptions.einterp = 2;
        matlabbatch{ind}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
        matlabbatch{ind}.spm.spatial.realignunwarp.eoptions.weight = '';
        matlabbatch{ind}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12];
        matlabbatch{ind}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
        matlabbatch{ind}.spm.spatial.realignunwarp.uweoptions.lambda = 100000;
        matlabbatch{ind}.spm.spatial.realignunwarp.uweoptions.jm = 0;
        matlabbatch{ind}.spm.spatial.realignunwarp.uweoptions.fot = [4 5];
        matlabbatch{ind}.spm.spatial.realignunwarp.uweoptions.sot = [];
        matlabbatch{ind}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4;
        matlabbatch{ind}.spm.spatial.realignunwarp.uweoptions.rem = 1;
        matlabbatch{ind}.spm.spatial.realignunwarp.uweoptions.noi = 5;
        matlabbatch{ind}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';
        matlabbatch{ind}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
        matlabbatch{ind}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
        matlabbatch{ind}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
        matlabbatch{ind}.spm.spatial.realignunwarp.uwroptions.mask = 1;
        matlabbatch{ind}.spm.spatial.realignunwarp.uwroptions.prefix = 'r';
        ind = ind + 1;

    end

 end
 
