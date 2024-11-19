
ind = 1;
% data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/P*');
data = dir('/DATAPOOL/ERRORMONITORING/SEM_mri_data/A*');
%% 
for i = 1:size(data,1)
    
    if data(i).name ~= "A09" && data(i).name ~= "A15" 
        runs = [1:7];
     else
         runs = [1:5];
     end
     
     SPM_file = [data(i).folder, '/', data(i).name, '/mri/SEM_', data(i).name,  '/nifti/GLM/SPM.mat']; 
     SPM = load(SPM_file);
     SPM = SPM.SPM;

     errorCorr_conWeights = zeros(1,length(SPM.xX.name));
     corr_idx = find(contains(SPM.xX.name, "Correct"));
     corr = [];
     for j = runs
        if SPM.Sess(j).U(1).ons~=500
            errorCorr_conWeights(corr_idx(j)) = -1;
            corr = [corr corr_idx(j)];
        end
     end
     err_idx = find(contains(SPM.xX.name, "Error")); 
     err = [];
     for j = runs
        if SPM.Sess(j).U(2).ons~=500
            errorCorr_conWeights(err_idx(j)) = 1;
            err = [err err_idx(j)];
        end
     end
     
     inst_conWeights = zeros(1,length(SPM.xX.name));
     inst_conWeights(find(contains(SPM.xX.name, "Instruction"))) = 1;
    
     resp_conWeights = zeros(1,length(SPM.xX.name));
     resp_conWeights(corr) = 1;
     resp_conWeights(err) = 1;

     error_conWeights = zeros(1,length(SPM.xX.name));
     error_conWeights(err) = 1;

     corr_conWeights = zeros(1,length(SPM.xX.name));
     corr_conWeights(corr) = 1;

     runs2_resp_conWeights = resp_conWeights;
     for run_idx = find(contains(SPM.xX.name, ["Sn(1)", "Sn(2)"]))
         runs2_resp_conWeights(run_idx) = -runs2_resp_conWeights(run_idx); 
     end
     for run_idx = find(contains(SPM.xX.name, ["Sn(3)", "Sn(4)", "Sn(5)"]))
         runs2_resp_conWeights(run_idx) = 0; 
     end

     runs3_resp_conWeights = resp_conWeights;
     for run_idx = find(contains(SPM.xX.name, ["Sn(1)", "Sn(2)", "Sn(3)"]))
         runs3_resp_conWeights(run_idx) = -runs3_resp_conWeights(run_idx); 
     end
     for run_idx = find(contains(SPM.xX.name, ["Sn(4)"]))
         runs3_resp_conWeights(run_idx) = 0; 
     end
     
     runs2_error_conWeights = error_conWeights;
     for run_idx = find(contains(SPM.xX.name, ["Sn(1)", "Sn(2)"]))
         runs2_error_conWeights(run_idx) = -runs2_error_conWeights(run_idx); 
     end
     for run_idx = find(contains(SPM.xX.name, ["Sn(3)", "Sn(4)", "Sn(5)"]))
         runs2_error_conWeights(run_idx) = 0; 
     end

     runs3_error_conWeights = error_conWeights;
     for run_idx = find(contains(SPM.xX.name, ["Sn(1)", "Sn(2)", "Sn(3)"]))
         runs3_error_conWeights(run_idx) = -runs3_error_conWeights(run_idx); 
     end
     for run_idx = find(contains(SPM.xX.name, ["Sn(4)"]))
         runs3_error_conWeights(run_idx) = 0; 
     end
     
     runs2_corr_conWeights = corr_conWeights;
     for run_idx = find(contains(SPM.xX.name, ["Sn(1)", "Sn(2)"]))
         runs2_corr_conWeights(run_idx) = -runs2_corr_conWeights(run_idx); 
     end
     for run_idx = find(contains(SPM.xX.name, ["Sn(3)", "Sn(4)", "Sn(5)"]))
         runs2_corr_conWeights(run_idx) = 0; 
     end

     runs3_corr_conWeights = corr_conWeights;
     for run_idx = find(contains(SPM.xX.name, ["Sn(1)", "Sn(2)", "Sn(3)"]))
         runs3_corr_conWeights(run_idx) = -runs3_corr_conWeights(run_idx); 
     end
     for run_idx = find(contains(SPM.xX.name, ["Sn(4)"]))
         runs3_corr_conWeights(run_idx) = 0; 
     end
     
     runs1_resp_conWeights = resp_conWeights;
     for run_idx = find(contains(SPM.xX.name, ["Sn(1)"]))
         runs1_resp_conWeights(run_idx) = -runs1_resp_conWeights(run_idx); 
     end
     for run_idx = find(contains(SPM.xX.name, ["Sn(2)", "Sn(3)", "Sn(4)", "Sn(5)", "Sn(6)"]))
         runs1_resp_conWeights(run_idx) = 0; 
     end

     matlabbatch{ind}.spm.stats.con.spmmat = {SPM_file};

     matlabbatch{ind}.spm.stats.con.consess{1}.tcon.name = 'Error>Correct';
     matlabbatch{ind}.spm.stats.con.consess{1}.tcon.weights = errorCorr_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
     
     matlabbatch{ind}.spm.stats.con.consess{2}.tcon.name = 'Error>Baseline';
     matlabbatch{ind}.spm.stats.con.consess{2}.tcon.weights = error_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

     matlabbatch{ind}.spm.stats.con.consess{3}.tcon.name = 'Correct>Baseline';
     matlabbatch{ind}.spm.stats.con.consess{3}.tcon.weights = corr_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

     matlabbatch{ind}.spm.stats.con.consess{4}.tcon.name = 'Instruction>Baseline';
     matlabbatch{ind}.spm.stats.con.consess{4}.tcon.weights = inst_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

     matlabbatch{ind}.spm.stats.con.consess{5}.tcon.name = 'Response>Baseline';
     matlabbatch{ind}.spm.stats.con.consess{5}.tcon.weights = resp_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{5}.tcon.sessrep = 'none';

     matlabbatch{ind}.spm.stats.con.consess{6}.tcon.name = 'Runs2_responses';
     matlabbatch{ind}.spm.stats.con.consess{6}.tcon.weights = runs2_resp_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{6}.tcon.sessrep = 'none';

     matlabbatch{ind}.spm.stats.con.consess{7}.tcon.name = 'Runs3_responses';
     matlabbatch{ind}.spm.stats.con.consess{7}.tcon.weights = runs3_resp_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
     
     matlabbatch{ind}.spm.stats.con.consess{8}.tcon.name = 'Runs2_error';
     matlabbatch{ind}.spm.stats.con.consess{8}.tcon.weights = runs2_error_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{8}.tcon.sessrep = 'none';

     matlabbatch{ind}.spm.stats.con.consess{9}.tcon.name = 'Runs3_error';
     matlabbatch{ind}.spm.stats.con.consess{9}.tcon.weights = runs3_error_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{9}.tcon.sessrep = 'none';

     matlabbatch{ind}.spm.stats.con.consess{10}.tcon.name = 'Runs2_correct';
     matlabbatch{ind}.spm.stats.con.consess{10}.tcon.weights = runs2_corr_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{10}.tcon.sessrep = 'none';

     matlabbatch{ind}.spm.stats.con.consess{11}.tcon.name = 'Runs3_correct';
     matlabbatch{ind}.spm.stats.con.consess{11}.tcon.weights = runs3_corr_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
     
     matlabbatch{ind}.spm.stats.con.consess{12}.tcon.name = 'Runs1_responses';
     matlabbatch{ind}.spm.stats.con.consess{12}.tcon.weights = runs1_resp_conWeights;
     matlabbatch{ind}.spm.stats.con.consess{12}.tcon.sessrep = 'none';

     matlabbatch{ind}.spm.stats.con.delete = 1;
     ind = ind + 1;    
end
