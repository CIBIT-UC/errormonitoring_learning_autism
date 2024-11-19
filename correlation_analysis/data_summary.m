%% 
% ================= Participants' data: summary =================

% Create a table with participants' main results (error rate and neural
% activation difference between correct and erroneous responses - dACC and AI -,
% fusiform gyrus mean activity to correlate with the other results), 
% demographic and diagnostic data

clear all;clc;

fmri_results = readtable('C:\toolbox\SEM_mri\MRI\Beta analysis\Mixed model\between groups\signal_change_data.xlsx');
fg_psts_results = readtable('C:\toolbox\SEM_mri\MRI\Beta analysis\fusiformGyrus_psts_instruction_signalChange.xlsx');
conn_results = readtable('C:\toolbox\SEM_mri\MRI\results\between-groups\conn\err-corr_last-first\CONN_betas.xlsx');
behavioural_results = readtable('C:\toolbox\SEM_mri\MRI\Behavioral analysis\responses_description_both_groups.xls');
diagnostic_data = readtable('C:\Users\Camila Dias\Documents\fMRI paradigm - error monitoring\ErrorMonitoring_MRI_new.xlsx',...
    'Sheet', 'Avaliação Neuropsicológica');

%% 
i=1;

for g=1:2
    
    if g ==1 
        group = "P";
        subs = [2,4,9,10,14,16,19:27];
    else
        group = "A";
        subs = [1:15];
    end
    
    for s=subs
                
        % Age, IQ, AQ (total), ADOS (total), WCST (Perseverative errors),
        % error rate, dACC error - correct (runs 3-6), AI error - correct (runs 3-7), 
        % fusiform gyrus, pSTS
        
        if s<10
            sub_name = strcat(group, "0", mat2str(s));
        else
            sub_name = strcat(group, mat2str(s));
        end
        
        data_table{i,1} = sub_name;     % Participant code
        data_table{i,2} = g;            % Group
        data_table{i,3} = ...           % Age
            diagnostic_data.AgeFMRI(find(string(diagnostic_data.ParticipantID) == sub_name));
        data_table{i,4} = ...           % IQ
            diagnostic_data.IQ(find(string(diagnostic_data.ParticipantID) == sub_name));
        data_table{i,5} = ...           % AQ (total)
            diagnostic_data.AQTotalScore(find(string(diagnostic_data.ParticipantID) == sub_name));
        data_table{i,6} = ...           % ADOS (total)
            diagnostic_data.ADOSTOTAL(find(string(diagnostic_data.ParticipantID) == sub_name));
        data_table{i,7} = ...           % WCST (Perseverative errors)
            diagnostic_data.WCST_PerseverativeErrors(find(string(diagnostic_data.ParticipantID) == sub_name));
        
        N_errors = sum(behavioural_results.Group==g & behavioural_results.Participant==s & ...
                    behavioural_results.Performance=="Error");
        N_correct = sum(behavioural_results.Group==g & behavioural_results.Participant==s & ...
                    behavioural_results.Performance=="Correct");
        data_table{i,8} = N_errors/(N_errors+N_correct);    % Error rate
        
        dACC_error = mean(fmri_results.sc_dACC(fmri_results.Participant==sub_name & ...
            fmri_results.Run>2 & fmri_results.Run<7 & fmri_results.Performance == "Error"));
        dACC_correct = mean(fmri_results.sc_dACC(fmri_results.Participant==sub_name & ...
            fmri_results.Run>2 & fmri_results.Run<7 & fmri_results.Performance == "Correct"));
        
        data_table{i,9} = dACC_error - dACC_correct;    % dACC error-correct (runs 3-6)
        
        AI_error = mean(fmri_results.sc_AI(fmri_results.Participant==sub_name & ...
            fmri_results.Run>2 & fmri_results.Performance == "Error"));
        AI_correct = mean(fmri_results.sc_AI(fmri_results.Participant==sub_name & ...
            fmri_results.Run>2 & fmri_results.Performance == "Correct"));

        data_table{i,10} = AI_error - AI_correct;    % AI error-correct (runs 3-7)
        
        put_sc = mean(fmri_results.sc_Put(fmri_results.Participant==sub_name & ...
            (fmri_results.Run==1 | fmri_results.Run==3)));
        
        data_table{i,11} = put_sc;    % Putamen activity (runs 1 and 3)
        
        data_table{i,12} = mean(fg_psts_results.sc_fg(fg_psts_results.Participant == sub_name));  % fus. gyrus
        data_table{i,13} = mean(fg_psts_results.sc_psts(fg_psts_results.Participant == sub_name));  % pSTS
        
        data_table{i,14} = mean(conn_results.CONN_AI(conn_results.Participant == sub_name));  % CONN results: AI
        data_table{i,15} = mean(conn_results.CONN_dACC_op(conn_results.Participant == sub_name));  % CONN results: dACC_op
        data_table{i,16} = mean(conn_results.CONN_dACC_par(conn_results.Participant == sub_name));  % CONN results: dACC_par
        data_table{i,17} = mean(conn_results.CONN_rACC(conn_results.Participant == sub_name));  % CONN results: rACC
        
        i=i+1;
        
    end
end
%% Save file
data_summary_table = cell2table(data_table,'VariableNames',{'Participant';'Group';'Age';'IQ';'AQ';'ADOS';'WCST';...
    'Error_rate';'dACC_diffErrCorr_R3_6';'AI_diffErrCorr_R3_7';'Put_R1_3';'Fus_gyrus';'pSTS';'CONN_AI';'CONN_dACC_op';...
    'CONN_dACC_par';'CONN_rACC'});
writetable(data_summary_table, ...
    'C:\toolbox\SEM_mri\MRI\results\between-groups\data_summary_table.xlsx');
        