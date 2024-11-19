%% 
% ================= SACCADE ANALYSIS =================

%%
clear all; close all; clc;
addpath('C:\toolbox\edfImport1.0.5\')
group = "A";    % P = non-autistic; A = autistic 
ET_details = {};
%% 
for s = 1:15 
    
    if s < 10
        sub = strcat(group,'0',num2str(s));
    else
        sub = strcat(group,num2str(s));
    end
    
    dir_files = strcat('F:\SEM_mri_rawdata\', sub, '\ET\'); % Directoria
    
    ET_details{s,1} = sub;
    col=2;
    
    if sub == "A01" || sub == "A02" || sub == "A09"
        eye = 2; 
    else
        eye = 1;
    end
    
    if sub == "A09" || sub == "A15"
        runs = [1:5];
    else
        runs = [1:7];
    end
    
    for r = runs
        
        nrun = strcat('R',num2str(r));
        edfFile = strcat(sub, '_', nrun, '.edf');
        
        %% PARAMETERS
        
        % Screen dimensions
        screenXpixels = 1920; 
        screenYpixels = 1080; 
        % As some participants moved and their eye-tracker data were not centered, we adjusted the frame 
        if (sub == "P14" && nrun == "R1") || sub == "P18" || (sub == "P21" && (nrun == "R1" || nrun == "R2" || nrun == "R6"))
            screenYpixels = 1080+200; 
        elseif (sub == "P16" && (nrun == "R5" || nrun == "R6")) || (sub == "P21" && (nrun == "R3" || nrun == "R7")) || sub == "A15"
            screenYpixels = 1080+400;
        elseif sub == "P21" || sub == "A11"
            screenYpixels = 1080+550;
        elseif sub == "A09" && nrun == "R1" || sub == "A14"
            screenYpixels = 1080-500;
        elseif sub == "A09" && nrun == "R2"
            screenYpixels = 1080-600;
        end
                
        %Distance to the screen vertical limits up to which a response can be detected
        %(high Ys can be blinks). It depends on the participants because some 
        %have a higher tendency to make vertical eye movements than others
        if sub == "P21" && (nrun == "R4" || nrun == "R5") 
            dist_ylim = -150;
        elseif (sub == "P14" && nrun == "R1") || (sub == "P16" && (nrun == "R5" || nrun == "R6")) ...
                || sub == "P21" || (sub == "A08" && nrun ~= "R6") 
            dist_ylim = 0;
        elseif sub == "P08" || (sub == "P16" && nrun=="R3") || sub == "P18" 
            dist_ylim = 100;
        elseif sub == "P13"
            dist_ylim = 400;
        elseif sub == "P10" || (sub == "A14" && nrun ~= "R5")
            dist_ylim = 50;
        elseif sub == "P20"
            dist_ylim = 300;
        elseif sub == "A03" 
            dist_ylim = 150;
        elseif sub == "A05" 
            dist_ylim = -100;
        elseif sub == "A08" && (nrun == "R6" || nrun == "R7") || (sub == "A09" && nrun == "R1")
            dist_ylim = -200;
        elseif sub == "A09" && nrun == "R2"
            dist_ylim = -500;
        else
            dist_ylim = 200;
        end
        
        %Horizontal (xx) limits from which a saccade to the right or left is detected 
        %(related to the vertical - right and left - lines of the paradigm)´
        left_line = 200; 
        right_line = screenXpixels - 200;
        dist_lim = 320;
        if sub == "P10" 
            left_lim = left_line+dist_lim+200;
            right_lim = right_line-dist_lim+200;
        elseif sub == "P15" || sub == "P17" || ...
                (sub == "A09" && (nrun == "R3" || nrun == "R4" || nrun == "R5")) 
            left_lim = left_line+dist_lim-150;
            right_lim = right_line-dist_lim-150;
        elseif sub == "P19" || sub == "P08" || sub == "P03" || sub == "P24" ...
                || (sub == "P25" && nrun ~= "R5")
            left_lim = left_line+dist_lim-100;
            right_lim = right_line-dist_lim-100;
        elseif sub == "P21" && nrun == "R5"
            left_lim = left_line+dist_lim+5*i;
            right_lim = right_line-dist_lim+5*i;
        elseif sub == "A03" && nrun == "R4"
            left_lim = left_line+dist_lim+140;
            right_lim = right_line-dist_lim+80;
        elseif sub == "A03" && nrun == "R5"
            left_lim = left_line+dist_lim+20;
            right_lim = right_line-dist_lim+20;
        elseif sub == "A03" && nrun == "R6"
            left_lim = left_line+dist_lim+130;
            right_lim = right_line-dist_lim+45;
        elseif sub == "A03" && nrun == "R7"
            left_lim = left_line+dist_lim+175; %+35
            right_lim = right_line-dist_lim-60; %+10
        elseif sub == "A04" && nrun == "R1"
            left_lim = left_line+dist_lim+140;
            right_lim = right_line-dist_lim-140;
        elseif sub == "A12" && nrun == "R3"
            left_lim = left_line+dist_lim+170;
            right_lim = right_line-dist_lim+150;
        elseif (sub == "A08" && nrun == "R1") || sub == "A12" || (sub == "A14" && nrun ~= "R6" && nrun ~= "R7")
            left_lim = left_line+dist_lim+150;
            right_lim = right_line-dist_lim+150;
        elseif sub == "A10" || sub == "A11" || sub == "P26"
            left_lim = left_line+dist_lim-250;
            right_lim = right_line-dist_lim-250;
        elseif sub == "P22" || sub == "P23"
            left_lim = left_line+dist_lim-50;
            right_lim = right_line-dist_lim-50;
        else
            left_lim = left_line+dist_lim;
            right_lim = right_line-dist_lim;
        end
        
        % Sampling Rate
        if sub ~= "P04"
            srate = 500;
        else
            srate = 1000;
        end

        % Minimum number of data points to consider that there was a saccade to the right or left
        if sub ~= "P09" && sub ~= "P11" && sub ~= "P14" && sub~= "P16" && sub ~= "P18" && ...
                sub ~= "P19" && sub ~= "P20" && sub ~= "P21" && ~(sub == "P23" && nrun == "R4") ...
                && sub ~="P26"
            points_min = 5;
        elseif sub == "P11" || sub == "P18" || sub == "P21" || (sub == "P23" && nrun == "R4") || ...
                sub == "P26"
            points_min = 10;
        else
            points_min = 15;
        end
        
        % X coordinates from which we can detect eye movement
        dist_pix = 500;
        if sub == "P13" 
            xmin = 200;
        elseif (sub == "P21" && nrun == "R4") || sub == "P08" || sub == "A09" || sub == "P26"
            xmin = -150;
        elseif sub == "A10"
            xmin = -250;
        else
            xmin = 0;
        end

        %% Triggers

        run = edfImport(char(strcat(dir_files,"\" ,edfFile)), [1 1 1], '');
        triggers = load(strcat('F:\SEM_mri_rawdata\', sub, '\mat_files\', ...
            sub, '_', nrun, '.mat'));
        instTime = triggers.Output.Run.dataMat(6,:);
        responseTime = triggers.Output.Run.dataMat(8,:);
        gap2Time = triggers.Output.Run.dataMat(9,:);
        saccade2make = triggers.Output.Run.dataMat(12,:);
        key2press = triggers.Output.Run.dataMat(2,:);
        noiseTime = triggers.Output.Run.NoiseTime;

        %% Análise das respostas

        Response = {};
        trials = [1:length(triggers.Output.Run.dataMat)]; 
        close all
        figure
        for i = trials 

            %==== Eye movement coordinates ====

            % Gaze during response time
            xGazeResponse = run.Samples.gx(eye,round(responseTime(i),1)*srate:round(gap2Time(i),1)*srate-1);
            yGazeResponse = run.Samples.gy(eye,round(responseTime(i),1)*srate:round(gap2Time(i),1)*srate-1);

            % Gaze before response time
            xGazeBefore = run.Samples.gx(eye,round(instTime(i)+0.05,1)*srate:round(responseTime(i),1)*srate-1);
            yGazeBefore = run.Samples.gy(eye,round(instTime(i)+0.05,1)*srate:round(responseTime(i),1)*srate-1);

            % Gaze after response time
            if i < length(triggers.Output.Run.dataMat) && ...
                    sum(ismember(round(noiseTime),[round(gap2Time(i))+1, round(gap2Time(i))+2, round(gap2Time(i))+3])) == 0
                xGazeAfter = run.Samples.gx(eye,round(gap2Time(i),1)*srate:round(instTime(i+1),1)*srate-1);
                yGazeAfter = run.Samples.gy(eye,round(gap2Time(i),1)*srate:round(instTime(i+1),1)*srate-1);
            elseif i == length(triggers.Output.Run.dataMat)
                xGazeAfter = run.Samples.gx(eye,round(gap2Time(i),1)*srate:round(noiseTime(3),1)*srate-1);
                yGazeAfter = run.Samples.gy(eye,round(gap2Time(i),1)*srate:round(noiseTime(3),1)*srate-1);
            elseif isequal(ismember(round(noiseTime), [round(gap2Time(i))+1, round(gap2Time(i))+2, round(gap2Time(i))+3]), [1 0 0])
                xGazeAfter = run.Samples.gx(eye,round(gap2Time(i),1)*srate:round(noiseTime(1),1)*srate-1);
                yGazeAfter = run.Samples.gy(eye,round(gap2Time(i),1)*srate:round(noiseTime(1),1)*srate-1);
            else
                xGazeAfter = run.Samples.gx(eye,round(gap2Time(i),1)*srate:round(noiseTime(2),1)*srate-1);
                yGazeAfter = run.Samples.gy(eye,round(gap2Time(i),1)*srate:round(noiseTime(2),1)*srate-1);
            end

            outGazeResponse = find(xGazeResponse < -dist_pix | xGazeResponse > screenXpixels + dist_pix | ...
                yGazeResponse < -dist_pix | yGazeResponse > screenYpixels + dist_pix); 
            xGazeResponse(outGazeResponse) = [];
            yGazeResponse(outGazeResponse) = [];

            outGazeBefore = find(xGazeBefore < -dist_pix | xGazeBefore > screenXpixels + dist_pix | ...
                yGazeBefore < -dist_pix | yGazeBefore > screenYpixels + dist_pix); 
            xGazeBefore(outGazeBefore) = [];
            yGazeBefore(outGazeBefore) = [];

            outGazeAfter = find(xGazeAfter < -dist_pix | xGazeAfter > screenXpixels + dist_pix | ...
                yGazeAfter < -dist_pix | yGazeAfter > screenYpixels + dist_pix); 
            xGazeAfter(outGazeAfter) = [];
            yGazeAfter(outGazeAfter) = [];

            %==== Saccade direction ====

            % Response types:
            % - Saccade to the right (before, during, or after the response time);
            % - Saccade to the left (before, during, or after the response time);
            % - Saccades to the right and to the left (before, during, or after the response time);
            % - Fixations.

            % Pre-response time
            if length(find(xGazeBefore>right_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim)) > points_min && ...
                    length(find(xGazeBefore>xmin & xGazeBefore<left_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim)) > points_min
                idx_right = find(xGazeBefore>right_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim);
                idx_left = find(xGazeBefore>xmin & xGazeBefore<left_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim);
                if idx_right(1)==1 && sum(diff(idx_right)~=1) == 0 
                    Response{i,1} = {'Left'};
                elseif idx_left(1)==1 && sum(diff(idx_left)~=1) == 0 
                    Response{i,1} = {'Right'};
                else
                    Response{i,1} = {'Both'};
                end
            elseif length(find(xGazeBefore>right_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim)) > points_min
                % Check if data points on the right side of the screen are not due to the previous response 
                %("coming back" saccade to the fixation cross at the center of the screen)
                idx = find(xGazeBefore>right_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim);
                if idx(1)==1 && sum(diff(idx)~=1) == 0 
                    Response{i,1} = {'Fixation'};
                else
                    Response{i,1} = {'Right'};
                end
            elseif length(find(xGazeBefore>xmin & xGazeBefore<left_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim)) > points_min
                % Check if data points on the left side of the screen are not due to the previous response 
                %("coming back" saccade to the fixation cross at the center of the screen)
                idx = find(xGazeBefore>xmin & xGazeBefore<left_lim & yGazeBefore>dist_ylim & yGazeBefore <screenYpixels-dist_ylim);
                if idx(1)==1 && sum(diff(idx)~=1) == 0 
                    Response{i,1} = {'Fixation'};
                else
                    Response{i,1} = {'Left'};
                end
            else
                Response{i,1} = {'Fixation'};
            end

            % Response time
            if length(find(xGazeResponse>right_lim & yGazeResponse>dist_ylim & yGazeResponse <screenYpixels-dist_ylim)) > points_min && ...
                    length(find(xGazeResponse>xmin & xGazeResponse<left_lim & yGazeResponse>dist_ylim & yGazeResponse <screenYpixels-dist_ylim)) > points_min
                Response{i,2} = {'Both'};
            elseif length(find(xGazeResponse>right_lim & yGazeResponse>dist_ylim & yGazeResponse <screenYpixels-dist_ylim)) > points_min
                Response{i,2} = {'Right'};
            elseif length(find(xGazeResponse>xmin & xGazeResponse<left_lim & yGazeResponse>dist_ylim & yGazeResponse <screenYpixels-dist_ylim)) > points_min
                Response{i,2} = {'Left'};
            else
                Response{i,2} = {'Fixation'};
            end

            % Post-response time
            if length(find(xGazeAfter>right_lim & yGazeAfter>dist_ylim & yGazeAfter <screenYpixels-dist_ylim)) > points_min && ...
                    length(find(xGazeAfter>xmin & xGazeAfter<left_lim & yGazeAfter>dist_ylim & yGazeAfter <screenYpixels-dist_ylim)) > points_min
                Response{i,3} = {'Both'};
            elseif length(find(xGazeAfter>right_lim & yGazeAfter>dist_ylim & yGazeAfter <screenYpixels-dist_ylim)) > points_min
                Response{i,3} = {'Right'};
            elseif length(find(xGazeAfter>xmin & xGazeAfter<left_lim & yGazeAfter>dist_ylim & yGazeAfter <screenYpixels-dist_ylim)) > points_min
                Response{i,3} = {'Left'};
            else
                Response{i,3} = {'Fixation'};
            end

            if saccade2make(i) == 1
                Response{i,4} = {'Left'};
            elseif saccade2make(i) == 2
                Response{i,4} = {'Right'};
            else
                Response{i,4} = {'Fixation'};
            end

            if key2press(i) == 1
                Response{i,5} = {'Left'};
            elseif key2press(i) == 2
                Response{i,5} = {'Right'};
            else
                Response{i,5} = {'Fixation'};
            end

            if Response{i,5} == "Fixation"
                if Response{i,1} == "Fixation" && string(Response{i,2}) == string(Response{i,4}) && ...
                        (Response{i,3} == "Fixation" || string(Response{i,3}) == string(Response{i,4}))
                    Response{i,6} = {'Correct'};
                elseif Response{i,1} == "Fixation" && string(Response{i,2}) ~= string(Response{i,4}) && ...
                        Response{i,2} ~= "Both" && Response{i,2} ~= "Fixation" && ...
                        string(Response{i,3}) ~= string(Response{i,4}) && Response{i,3} ~= "Both"
                    Response{i,6} = {'Error'};
                elseif Response{i,1} == "Fixation" && Response{i,2} == "Fixation" ...
                        && Response{i,3} == "Fixation"
                    Response{i,6} = {'Error (no-go)'};
                elseif Response{i,1} == "Fixation" && (Response{i,2} == "Both" || ...
                        (Response{i,2} ~= "Fixation" && Response{i,3} ~= "Fixation" && ...
                        string(Response{i,2}) ~= string(Response{i,3})))
                    Response{i,6} = {'Error (indecision)'};
                elseif string(Response{i,1}) == string(Response{i,4}) && ...
                        (string(Response{i,2}) == string(Response{i,4}) || Response{i,2} == "Fixation") ...
                        && (string(Response{i,3}) == string(Response{i,4}) || Response{i,3} == "Fixation")
                    Response{i,6} = {'Correct (anticipated)'};
                elseif string(Response{i,1}) ~= string(Response{i,4}) && ...
                        Response{i,1} ~= "Both" && Response{i,1} ~= "Fixation" && ...
                        (string(Response{i,2}) == string(Response{i,1}) || Response{i,2} == "Fixation") ...
                        && (string(Response{i,3}) == string(Response{i,1}) || Response{i,3} == "Fixation")
                    Response{i,6} = {'Error (anticipated)'};
                elseif Response{i,1} == "Both" || (Response{i,1} ~= "Fixation" && ...
                        ((string(Response{i,1}) ~= string(Response{i,2}) && Response{i,2} ~= "Fixation") || ...
                        (string(Response{i,1}) ~= string(Response{i,3}) && Response{i,3} ~= "Fixation")))
                    Response{i,6} = {'Error (anticipated indecision)'};
                elseif Response{i,1} == "Fixation" && Response{i,2} == "Fixation" && ...
                        string(Response{i,3}) == string(Response{i,4})
                    Response{i,6} = {'Correct (late)'};
                elseif Response{i,1} == "Fixation" && Response{i,2} == "Fixation" && ...
                        string(Response{i,3}) ~= string(Response{i,4}) && ...
                        Response{i,3} ~= "Fixation" && Response{i,3} ~= "Both"
                    Response{i,6} = {'Error (late)'};
                elseif Response{i,1} == "Fixation" && Response{i,2} == "Fixation" && ...
                        Response{i,3} == "Both"
                    Response{i,6} = {'Error (late indecision)'};
                else
                    Response{i,6} = {'XXXXXXX'};
                end
            % When the response should be a button press and not a saccade:
            elseif Response{i,1} == "Fixation" && Response{i,2} == "Fixation" ...
                        && Response{i,3} == "Fixation"
                Response{i,6} = {'Correct'};
            elseif Response{i,1} == "Fixation" && string(Response{i,2}) == string(Response{i,5}) && ...
                        (Response{i,3} == "Fixation" || string(Response{i,3}) == string(Response{i,5}))
                Response{i,6} = {'Action error (correct)'};
            elseif Response{i,1} == "Fixation" && string(Response{i,2}) ~= string(Response{i,5}) && ...
                        Response{i,2} ~= "Both" && Response{i,2} ~= "Fixation" && ...
                        string(Response{i,3}) ~= string(Response{i,5}) && Response{i,3} ~= "Both"
                    Response{i,6} = {'Action error (error)'};
            elseif Response{i,1} == "Fixation" && (Response{i,2} == "Both" || ...
                        (Response{i,2} ~= "Fixation" && Response{i,3} ~= "Fixation" && ...
                        string(Response{i,2}) ~= string(Response{i,3})))
                    Response{i,6} = {'Action error (indecision error)'};
            elseif string(Response{i,1}) == string(Response{i,5}) && ...
                        (string(Response{i,2}) == string(Response{i,5}) || Response{i,2} == "Fixation") ...
                        && (string(Response{i,3}) == string(Response{i,5}) || Response{i,3} == "Fixation")
                    Response{i,6} = {'Action error (anticipated correct)'};
            elseif string(Response{i,1}) ~= string(Response{i,5}) && ...
                        Response{i,1} ~= "Both" && Response{i,1} ~= "Fixation" && ...
                        (string(Response{i,2}) == string(Response{i,1}) || Response{i,2} == "Fixation") ...
                        && (string(Response{i,3}) == string(Response{i,1}) || Response{i,3} == "Fixation")
                    Response{i,6} = {'Action error (anticipated error)'};
            elseif Response{i,1} == "Both" || (Response{i,1} ~= "Fixation" && ...
                        ((string(Response{i,1}) ~= string(Response{i,2}) && Response{i,2} ~= "Fixation") || ...
                        (string(Response{i,1}) ~= string(Response{i,3}) && Response{i,3} ~= "Fixation")))
                    Response{i,6} = {'Action error (anticipated indecision)'};
            elseif Response{i,1} == "Fixation" && Response{i,2} == "Fixation" && ...
                        string(Response{i,3}) == string(Response{i,5})
                    Response{i,6} = {'Action error (late correct)'};
            elseif Response{i,1} == "Fixation" && Response{i,2} == "Fixation" && ...
                        string(Response{i,3}) ~= string(Response{i,5}) && ...
                        Response{i,3} ~= "Fixation" && Response{i,3} ~= "Both"
                    Response{i,6} = {'Action error (late error)'}; 
            elseif Response{i,1} == "Fixation" && Response{i,2} == "Fixation" && ...
                        Response{i,3} == "Both"
                    Response{i,6} = {'Action error (late indecision)'}; 
            else
                Response{i,6} = {'XXXXXXX'};
            end
            
            if length(xGazeBefore)==0 && length(xGazeResponse)==0 && length(xGazeAfter)==0
                Response{i,6} = {'Lost data'};
            end

            %% 

            %==== Figures ====

            if sub == "P10"
                xmin_plot = 200;
                xmax_plot = screenXpixels+200;
                ymin_plot = 0;
                ymax_plot = screenYpixels;
            elseif sub == "P15" || sub == "P17"
                xmin_plot = -150;
                xmax_plot = screenXpixels-150;
                ymin_plot = 0;
                ymax_plot = screenYpixels;
            elseif sub == "P19" || sub == "P08" || sub == "P24" ...
                    || (sub == "P25" && nrun ~= "R5")
                xmin_plot = -100;
                xmax_plot = screenXpixels-100;
                ymin_plot = 0;
                ymax_plot = screenYpixels;
            elseif sub == "P22" || sub == "P23"
                xmin_plot = -50;
                xmax_plot = screenXpixels-50;
                ymin_plot = 0;
                ymax_plot = screenYpixels;
            elseif (sub == "P14" && nrun == "R1") || sub == "P18" || ...
                    (sub == "P21" && (nrun == "R1" || nrun == "R2" || nrun == "R6")) || ...
                    (sub == "A08" && (nrun == "R6" || nrun == "R7"))
                xmin_plot = 0;
                xmax_plot = screenXpixels;
                ymin_plot = -200;
                ymax_plot = screenYpixels-200;
            elseif (sub == "P16" && (nrun == "R5" || nrun == "R6")) || ...
                    (sub == "P21" && (nrun == "R3" || nrun == "R7")) 
                xmin_plot = 0;
                xmax_plot = screenXpixels;
                ymin_plot = -400;
                ymax_plot = screenYpixels-400;
            elseif sub == "P21" && nrun == "R5"
                xmin_plot = 100;
                xmax_plot = screenXpixels+100;
                ymin_plot = -550;
                ymax_plot = screenYpixels-550;
            elseif sub == "P21"
                xmin_plot = 0;
                xmax_plot = screenXpixels;
                ymin_plot = -550;
                ymax_plot = screenYpixels-550;
            elseif (sub == "A08" && nrun == "R1") || sub == "A12" || (sub == "A14" && nrun ~= "R6" && nrun ~= "R7")
                xmin_plot = 150;
                xmax_plot = screenXpixels+150;
                ymin_plot = 0;
                ymax_plot = screenYpixels;
            elseif sub == "A09" && nrun == "R1"
                xmin_plot = 0;
                xmax_plot = screenXpixels;
                ymin_plot = 0;
                ymax_plot = screenYpixels+500;
            elseif sub == "A09" && nrun == "R2"
                xmin_plot = 0;
                xmax_plot = screenXpixels;
                ymin_plot = 0;
                ymax_plot = screenYpixels+600;
            elseif sub == "A09" && (nrun == "R3" || nrun == "R4" || nrun == "R5")
                xmin_plot = -150;
                xmax_plot = screenXpixels-150;
                ymin_plot = 0;
                ymax_plot = screenYpixels;
            elseif sub == "A10" || sub == "A11" || sub == "P26"
                xmin_plot = -250;
                xmax_plot = screenXpixels-250;
                ymin_plot = 0;
                ymax_plot = screenYpixels;
            else
                xmin_plot = 0;
                xmax_plot = screenXpixels;
                ymin_plot = 0;
                ymax_plot = screenYpixels;
            end

            plot(xGazeResponse, screenYpixels-yGazeResponse,'.r','LineWidth',2)
            xline(left_lim, '--')
            xline(right_lim, '--')
            xlim([xmin_plot xmax_plot])
            ylim([ymin_plot ymax_plot])
            title('Response', 'fontsize', 18)
            if length(trials)>1
                hold on
            else
                figure
                plot(xGazeBefore, screenYpixels-yGazeBefore,'.r','LineWidth',2)
                xline(left_lim, '--')
                xline(right_lim, '--')
                xlim([xmin_plot xmax_plot])
                ylim([ymin_plot ymax_plot])
                title('Pre-response', 'fontsize', 18)

                figure
                plot(xGazeAfter, screenYpixels-yGazeAfter,'.r','LineWidth',2)
                xline(left_lim, '--')
                xline(right_lim, '--')
                xlim([xmin_plot xmax_plot])
                ylim([ymin_plot ymax_plot])
                title('Post-response', 'fontsize', 18)
            end

            xlim([xmin_plot xmax_plot])
            ylim([ymin_plot ymax_plot])

        end
        %% Save file
        Response_table = array2table(Response, 'VariableNames', {'Pre', ...
            'Response', 'Pos', 'Saccade2make', 'Key2press', 'Result'});

        if ~exist(strcat(dir_files,'ET_responses/'))
           mkdir(strcat(dir_files,'ET_responses/'))
        end

        save(strcat(dir_files,'ET_responses/ET_responses_', nrun, '.mat'), 'Response_table');

        %% Eye tracker details
        
        ET_details{s,col} = screenYpixels;
        ET_details{s,col+1} = left_lim;
        ET_details{s,col+2} = right_lim;
        ET_details{s,col+3} = dist_ylim;
        ET_details{s,col+4} = xmin;
        col = col+5;

    end
end
%% 

% Save eye tracker details file

variables_names = ["Participant"];
for r=1:7
    variables_names = [variables_names, strcat('Screen_Ypixels_R', string(r)), ...
        strcat('Left_lim_R', string(r)), strcat('Right_lim_R', string(r)), ...
        strcat('Dist_ylim_R', string(r)), strcat('Xlim_R', string(r))];
end

variables_names = cellstr(variables_names);
ET_details_table = array2table(ET_details, 'VariableNames', variables_names);
if group == "P"
    save('F:\SEM_mri\MRI\SEM_mri_rawdata\ET_details_non-autistic.mat', 'ET_details_table');
else
    save('F:\SEM_mri\MRI\SEM_mri_rawdata\ET_details_autistic.mat', 'ET_details_table');
end
