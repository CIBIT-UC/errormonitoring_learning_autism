% List of open inputs
nrun = 1; % enter the number of runs here
jobfile = {'/DATAPOOL/home/cdias/errorMonitoring_fMRI/processing_pipeline_spm/SPM_scripts/smoothing_job_v2.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
