%% 
% ================= SACCADE REACTION TIME =================

%% 
function tSaccade = get_tSaccade(xGaze,idx_init,t)

    stop=0;
    saccade = [xGaze(idx_init)];
    idx = idx_init;
    while ~stop & idx <= length(xGaze)
        idx=idx+1;
        saccade = [saccade xGaze(idx)];
        if ~issorted(saccade,'monotonic')
            saccade = saccade(1:end-1);
            tSaccade = t(idx-1);
            stop = 1;
        elseif idx == length(xGaze)
            tSaccade = t(idx);
            stop = 1;
        end
    end
    
end
