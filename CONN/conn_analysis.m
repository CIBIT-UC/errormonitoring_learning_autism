clear all

addpath '/SCRATCH/software/toolboxes/spm12';
addpath '/SCRATCH/software/toolboxes/conn21a';
%% 
% Parameters 
NSUBJECTS=30;
nsessions=4;
TR=1; % Repetition time

% Files
cd '/DATAPOOL/ERRORMONITORING/CONN_data_between-groups';
conn_dir('s7.5_wrarun1_biasfield_topup_4D.nii');
% Functional files
func_files_run1=cellstr(conn_dir('s7.5_wrarun1_biasfield_topup_4D.nii'));
func_files_run2=cellstr(conn_dir('s7.5_wrarun2_biasfield_topup_4D.nii'));
func_files_run6=cellstr(conn_dir('s7.5_wrarun6_biasfield_topup_4D.nii'));
func_files_run7=cellstr(conn_dir('s7.5_wrarun7_biasfield_topup_4D.nii'));
func_files_run6 = [func_files_run6(1:8); {''}; func_files_run6(9:13); {''}; func_files_run6(14:28)];
func_files_run7 = [func_files_run7(1:8); {''}; func_files_run7(9:13); {''}; func_files_run7(14:28)];
FUNCTIONAL_FILE = [func_files_run1 func_files_run2 func_files_run6 func_files_run7];
% Structural files
STRUCTURAL_FILE=cellstr(conn_dir('wSEM_t1_mprage_sag_p2_iso.nii'));
STRUCTURAL_FILE={STRUCTURAL_FILE{1:NSUBJECTS}};
% Structural files (from segmentation)
greymatter_file = cellstr(conn_dir('wc1SEM_t1_mprage_sag_p2_iso.nii'));
whitematter_file = cellstr(conn_dir('wc2SEM_t1_mprage_sag_p2_iso.nii'));
csf_file = cellstr(conn_dir('wc3SEM_t1_mprage_sag_p2_iso.nii'));
ROI_file = [greymatter_file whitematter_file csf_file];
% Covariates files
cov_files_run1 = cellstr(conn_dir('run1_multiple_regressors.txt'));
cov_files_run2 = cellstr(conn_dir('run2_multiple_regressors.txt'));
cov_files_run6 = cellstr(conn_dir('run6_multiple_regressors.txt'));
cov_files_run7 = cellstr(conn_dir('run7_multiple_regressors.txt'));
cov_files_run6 = [cov_files_run6(1:8); {''}; cov_files_run6(9:13); {''}; cov_files_run6(14:28)];
cov_files_run7 = [cov_files_run7(1:8); {''}; cov_files_run7(9:13); {''}; cov_files_run7(14:28)];
COV_FILE = [cov_files_run1 cov_files_run2 cov_files_run6 cov_files_run7];

disp([num2str(size(FUNCTIONAL_FILE,1)),' subjects']);
disp([num2str(size(FUNCTIONAL_FILE,2)),' sessions']);

%% CONN-SPECIFIC SECTION: RUNS PREPROCESSING/SETUP/DENOISING/ANALYSIS STEPS
%% Prepares batch structure
clear batch;
batch.filename='/DATAPOOL/ERRORMONITORING/CONN_data_between-groups/conn_between-groups.mat';            % New conn_*.mat experiment name

%% SETUP & PREPROCESSING step (using default values for most parameters, see help conn_batch to define non-default values)
% CONN Setup                                            % Default options (uses all ROIs in conn/rois/ directory)
batch.Setup.isnew=1;
batch.Setup.nsubjects=NSUBJECTS;
batch.Setup.RT=TR;                                        % TR (seconds)

batch.Setup.functionals=repmat({{}},[NSUBJECTS,1]);       % Point to functional volumes for each subject/session
for nsub=[1:8,10:14,16:18,20:30] % A09 e A15: runs 1-5, P10 runs 1-6
    for nses=1:nsessions
        batch.Setup.functionals{nsub}{nses}{1}=FUNCTIONAL_FILE{nsub,nses}; 
    end
end %note: each subject's data is defined by two sessions and one single (4d) file per session
for nses=1:nsessions-1
    batch.Setup.functionals{19}{nses}{1}=FUNCTIONAL_FILE{19,nses}; 
end
for nses=1:nsessions-2
    batch.Setup.functionals{9}{nses}{1}=FUNCTIONAL_FILE{9,nses}; 
    batch.Setup.functionals{15}{nses}{1}=FUNCTIONAL_FILE{15,nses}; 
end
batch.Setup.structurals=STRUCTURAL_FILE;                  % Point to anatomical volumes for each subject

batch.Setup.conditions.importfile = '/DATAPOOL/ERRORMONITORING/CONN_data_between-groups/conditions_conn.txt'; 
batch.Setup.conditions.missingdata = 1;

batch.Setup.covariates.names = {'multiple_regressors'};
for nsub=[1:8,10:14,16:18,20:30] % A09 e A15: runs 1-5, P10 runs 1-6
    for nses=1:nsessions
        batch.Setup.covariates.files{1}{nsub}{nses}=COV_FILE{nsub,nses}; 
    end
end
for nses=1:nsessions-1
    batch.Setup.covariates.files{1}{19}{nses}=COV_FILE{19,nses}; 
end
for nses=1:nsessions-2
    batch.Setup.covariates.files{1}{9}{nses}=COV_FILE{9,nses}; 
    batch.Setup.covariates.files{1}{15}{nses}=COV_FILE{15,nses}; 
end

% ROIs
batch.Setup.rois.names{1} = 'Grey Matter';
batch.Setup.rois.names{2} = 'White Matter';
batch.Setup.rois.names{3} = 'CSF';
batch.Setup.rois.names{4} = 'atlas';
batch.Setup.rois.names{5} = 'networks';
batch.Setup.rois.names{6} = 'dACC';
batch.Setup.rois.names{7} = 'rACC';
batch.Setup.rois.names{8} = 'AI_bil';
batch.Setup.rois.names{9} = 'put_bil';

for nsub=1:NSUBJECTS
    batch.Setup.rois.files{1}{nsub} = ROI_file{nsub,1};
    batch.Setup.rois.files{2}{nsub} = ROI_file{nsub,2};
    batch.Setup.rois.files{3}{nsub} = ROI_file{nsub,3};
end
batch.Setup.rois.files{4}='/SCRATCH/software/toolboxes/conn21a/rois/atlas.nii';
batch.Setup.rois.multiplelabels(4) = 1;
batch.Setup.rois.files{5}='/SCRATCH/software/toolboxes/conn21a/rois/networks.nii';
batch.Setup.rois.multiplelabels(5) = 1;

vois_dir = '/DATAPOOL/ERRORMONITORING/group_level_analysis/ROIs/Atlas/AAL3 and Brainnetome/';

batch.Setup.rois.files{6} = [vois_dir, 'ACC/dACC/A32p_BN.nii'];
batch.Setup.rois.multiplelabels(6) = 0;
batch.Setup.rois.files{7} = [vois_dir, 'ACC/rACC_BN.nii'];
batch.Setup.rois.multiplelabels(7) = 0;
batch.Setup.rois.files{8} = [vois_dir, 'bilateral_AI/bilateral_AI_BN.nii'];
batch.Setup.rois.multiplelabels(8) = 0;
batch.Setup.rois.files{9} = [vois_dir, 'putamen/bilateral_putamen_ventromedial_BN.nii'];
batch.Setup.rois.multiplelabels(9) = 0;

batch.Setup.done=1;
batch.Setup.overwrite='Yes';

%% DENOISING step
% CONN Denoising                                    % Default options (uses White Matter+CSF+multiple regressors+conditions as confound regressors); 
batch.Denoising.filter=[0.01, inf];                 % frequency filter (band-pass values, in Hz)
batch.Denoising.done=1;
batch.Denoising.overwrite='Yes';

% %% FIRST-LEVEL ANALYSIS step
% % CONN Analysis                                     % Default options (uses all ROIs in conn/rois/ as connectivity sources); see conn_batch for additional options
% batch.Analysis.modulation=1;                        % gPPI
% batch.Analysis.measure=3;                           % Regression (bivariate)
% batch.Analysis.conditions=
% batch.Analysis.done=1;
% batch.Analysis.overwrite='Yes';

conn_batch(batch);
