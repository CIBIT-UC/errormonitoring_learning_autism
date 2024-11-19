%% 
% === Link between behavioural, neurophysiological, demographic data and autistic traits ===

clc;clear all;
data = readtable('C:\toolbox\SEM_mri\MRI\results\between-groups\data_summary_table.xlsx');

%% Link between error rate and neurophysiological results 

data = data(~isnan(data.IQ),:);
x = [data.Error_rate];
y = [data.dACC_diffErrCorr_R3_6 data.AI_diffErrCorr_R3_7 data.Put_R1_3];
z = [data.Age data.IQ];
[c11,p11] = partialcorr(x,y,z,'Type','Spearman');

data_conn = data(~isnan(data.CONN_AI),:);
x = [data_conn.Error_rate];
y = [data_conn.CONN_AI data_conn.CONN_dACC_op data_conn.CONN_dACC_par data_conn.CONN_rACC]; 
z = [data_conn.Age data_conn.IQ];
[c12,p12] = partialcorr(x,y,z,'Type','Spearman');

c1 = [c11 c12];
p1 = [p11 p12].*7; %Bonferroni correction
%% 
figure
scatter(data.Error_rate*100, data.dACC_diffErrCorr_R3_6, "filled")
hold on
lin=lsline
lin.LineWidth = 3;
xlim([0 100])
ylim([-2 3])
ylabel('dACC error-correct (% sc)', 'FontSize', 20)
xlabel('Error rate (%)', 'FontSize', 20)
set(gca,'FontSize', 14);
hold off

figure
scatter(data.Error_rate*100, data.AI_diffErrCorr_R3_7, "filled")
hold on
lin=lsline
lin.LineWidth = 3;
xlim([0 100])
ylim([-2 3])
ylabel('Anterior insula error-correct (% sc)', 'FontSize', 20)
xlabel('Error rate (%)', 'FontSize', 20)
set(gca,'FontSize', 14);
hold off

%% Link between fusiform gyrus ans pSTS activity and behaviour/neurophysiological results

% Fusiform gyrus

x = [data.Fus_gyrus];
y = [data.Error_rate data.dACC_diffErrCorr_R3_6 data.AI_diffErrCorr_R3_7 data.Put_R1_3];
z = [data.Age data.IQ];
[c211,p211] = partialcorr(x,y,z,'Type','Spearman');

x = [data_conn.Fus_gyrus];
y = [data_conn.CONN_AI data_conn.CONN_dACC_op data_conn.CONN_dACC_par data_conn.CONN_rACC];
z = [data_conn.Age data_conn.IQ];
[c212,p12] = partialcorr(x,y,z,'Type','Spearman');

c21 = [c211 c212];
p21 = [p211 p212].*8; %Bonferroni correction

% pSTS

x = [data.pSTS];
y = [data.Error_rate data.dACC_diffErrCorr_R3_6 data.AI_diffErrCorr_R3_7 data.Put_R1_3];
z = [data.Age data.IQ];
[c221,p221] = partialcorr(x,y,z,'Type','Spearman');

x = [data_conn.pSTS];
y = [data_conn.CONN_AI data_conn.CONN_dACC_op data_conn.CONN_dACC_par data_conn.CONN_rACC];
z = [data_conn.Age data_conn.IQ];
[c222,p222] = partialcorr(x,y,z,'Type','Spearman');

c22 = [c221 c222];
p22 = [p221 p222].*8; %Bonferroni correction

%% Link between autistic traits and behavioural/neurophysiological results

x = [data.AQ];
y = [data.Error_rate data.dACC_diffErrCorr_R3_6 data.AI_diffErrCorr_R3_7 data.Put_R1_3];
z = [data.Age data.IQ];
[c311,p311] = partialcorr(x,y,z,'Type','Spearman');

x = [data_conn.AQ];
y = [data_conn.CONN_AI data_conn.CONN_dACC_op data_conn.CONN_dACC_par data_conn.CONN_rACC];
z = [data_conn.Age data_conn.IQ];
[c312,p312] = partialcorr(x,y,z,'Type','Spearman');

c31 = [c311 c312];
p31 = [p311 p312].*8; %Bonferroni correction

data_ADOS = data(~isnan(data.ADOS),:);
x = [data_ADOS.ADOS];
y = [data_ADOS.Error_rate data_ADOS.dACC_diffErrCorr_R3_6 data_ADOS.AI_diffErrCorr_R3_7 data_ADOS.Put_R1_3];
z = [data_ADOS.Age data_ADOS.IQ];
[c321,p321] = partialcorr(x,y,z,'Type','Spearman');

data_conn_ADOS = data_ADOS(~isnan(data_ADOS.CONN_AI),:);
x = [data_conn_ADOS.AQ];
y = [data_conn_ADOS.CONN_AI data_conn_ADOS.CONN_dACC_op data_conn_ADOS.CONN_dACC_par data_conn_ADOS.CONN_rACC];
z = [data_conn_ADOS.Age data_conn_ADOS.IQ];
[c322,p322] = partialcorr(x,y,z,'Type','Spearman');

c32 = [c321 c322];
p32 = [p321 p322].*8; %Bonferroni correction
%% 
figure
scatter(data_ADOS.ADOS, data_ADOS.dACC_diffErrCorr_R3_6, "filled")
hold on
lin=lsline
lin.LineWidth = 3;
ylim([-2 3])
xlim([7 14])
ylabel('dACC error-correct (% sc)', 'FontSize', 20)
xlabel('ADOS', 'FontSize', 20)
set(gca,'FontSize', 14);
hold off

figure
scatter(data_conn.AQ, data_conn.CONN_dACC_op, "filled")
hold on
lin=lsline
lin.LineWidth = 3;
xlim([5 42])
ylabel('Conn. dACC <-> Central opercular cortex', 'FontSize', 20)
xlabel('AQ', 'FontSize', 20)
set(gca,'FontSize', 14);
hold off
