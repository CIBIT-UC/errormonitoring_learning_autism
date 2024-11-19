
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 
sub = 1;
for i = 1:size(data,1)
    
    data_anat = [data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/anat'];
    anat_files = dir(fullfile(data_anat, "*.nii"));
    
    def_field = anat_files(startsWith(string(char(anat_files.name)), "y_"));
    def_field = [def_field.folder, '/', def_field.name];
    
    anat_image = anat_files(startsWith(string(char(anat_files.name)), "SEM_") | ...
        startsWith(string(char(anat_files.name)), "A") | startsWith(string(char(anat_files.name)), "t1"));
    anat_image = [anat_image.folder, '/', anat_image.name];
    
    c1 = anat_files(startsWith(string(char(anat_files.name)), "c1"));
    c1 = [c1.folder, '/', c1.name];
    
    c2 = anat_files(startsWith(string(char(anat_files.name)), "c2"));
    c2 = [c2.folder, '/', c2.name];
    
    c3 = anat_files(startsWith(string(char(anat_files.name)), "c3"));
    c3 = [c3.folder, '/', c3.name];
    
    images = {anat_image; c1; c2; c3};
    
    matlabbatch{1}.spm.spatial.normalise.write.subj(sub).def = {def_field};     
    matlabbatch{1}.spm.spatial.normalise.write.subj(sub).resample = images;
    
    sub = sub+1;
  
end

matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
