
ind = 1;
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 
for i = 1:size(data,1)
    
    data_func = dir([data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/func/run*']);
    fprintf(data(i).name);
    
    dir_folder = [data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/GLM']; 
    
    if ~exist(dir_folder)
        mkdir(dir_folder)
    end
        
    TR=1;
    hpf= 128; 

    matlabbatch{ind}.spm.stats.fmri_spec.dir = {dir_folder};
    matlabbatch{ind}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{ind}.spm.stats.fmri_spec.timing.RT = 1;
    matlabbatch{ind}.spm.stats.fmri_spec.timing.fmri_t = 16; 
    matlabbatch{ind}.spm.stats.fmri_spec.timing.fmri_t0 = 8; 
    
    for j = 1:size(data_func,1)
        
        images = spm_vol([data_func(j).folder, '/', data_func(j).name, '/s7.5_wra', data_func(j).name, '_biasfield_topup_4D.nii']);
        multi_reg = [data_func(j).folder, '/', data_func(j).name, '/regression_6MPs/multiple_regressors.txt'];
        
        scans = [];
        for k = 1:size(images,1)
            images_n = images(k).n;
            index = num2str(images_n(1));
            scan{1,1} = [images(k).fname, ',', index];
            scans = [scans; scan];
        end
        
        protocol = load([data(i).folder, '/', data(i).name, '/protocol/protocol_R', ...
            data_func(j).name(end), '.mat']);
        protocol = protocol.protocol;
        protocol_table = array2table(protocol, 'VariableNames', ...
            {'names', 'onsets', 'onsets2', 'durations', 'image'}); 
        names = ["Correct", "Error", "Instruction", "Other"];   
        
        matlabbatch{ind}.spm.stats.fmri_spec.sess(j).scans = scans;
        
        for c=1:length(names)
            matlabbatch{ind}.spm.stats.fmri_spec.sess(j).cond(c).name = char(names(c));
            if sum(strcmp(unique(string(protocol_table.names)), char(names(c))))~=0
                matlabbatch{ind}.spm.stats.fmri_spec.sess(j).cond(c).onset = ...
                    cell2mat(protocol_table.onsets2(find(string(protocol_table.names) == names(c)))).'; 
                matlabbatch{ind}.spm.stats.fmri_spec.sess(j).cond(c).duration = ...
                    cell2mat(protocol_table.durations(find(string(protocol_table.names) == names(c)))).';  
            else
                matlabbatch{ind}.spm.stats.fmri_spec.sess(j).cond(c).onset = 500;   
                matlabbatch{ind}.spm.stats.fmri_spec.sess(j).cond(c).duration = 0;
            end
            matlabbatch{ind}.spm.stats.fmri_spec.sess(j).cond(c).tmod = 0;
            matlabbatch{ind}.spm.stats.fmri_spec.sess(j).cond(c).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{ind}.spm.stats.fmri_spec.sess(j).cond(c).orth = 1;

        end

        matlabbatch{ind}.spm.stats.fmri_spec.sess(j).multi = {''};
        matlabbatch{ind}.spm.stats.fmri_spec.sess(j).regress = struct('name', {}, 'val', {});
        matlabbatch{ind}.spm.stats.fmri_spec.sess(j).multi_reg = {multi_reg};
        matlabbatch{ind}.spm.stats.fmri_spec.sess(j).hpf = hpf;

    end

    matlabbatch{ind}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{ind}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{ind}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{ind}.spm.stats.fmri_spec.global = 'None'; 
    matlabbatch{ind}.spm.stats.fmri_spec.mthresh = 0.8; 
    matlabbatch{ind}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{ind}.spm.stats.fmri_spec.cvi = 'AR(1)';
    ind = ind + 1;

end
