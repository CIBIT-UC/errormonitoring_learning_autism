%% MAIN 
    clear all; clc; Screen('CloseAll'); 
%     IOPort('CloseAll');
%%
    S= struct();
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    S.SUBJECT = 'P01';
    S.RUN_ID = '_R1';
    dir_path = 'F:\SEM_mri\MRI\SEM_mri_rawdata';        % Alterar!
    filename = [S.SUBJECT S.RUN_ID];
    
    % --- Eyetracker, Trigger, Response box
    S.EYETRACKER = 1;
    S.TRIGGER = 1;
    S.RSPBOX = 1; 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%% Initialize\\
    [S] = initSettings(S);
    
    Output = struct();
    Output.S = S;
    S.output_path = dir_path;  
    Output.Method = 'MRI_Offline';
    
    % RUN
    Output.('Run')= Paradigm_MRI(S);

    %% Save Data
    cd(dir_path);
    save(filename);
    
%% Close COMs
if S.RSPBOX
    IOPort('Close',S.response_box_handle);
end
if S.TRIGGER
    IOPort('Close',S.syncbox_handle);
end

    