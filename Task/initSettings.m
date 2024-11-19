 function [S] = initSettings(S)
%Initialise parameters for the social error monitoring fmri protocol.
% Usage: [S] = initSettings(S);
%
% Inputs:
%   : S - struct containing very important info (subject, trigger, 
%   response box, eyetracker)
% Outputs:
%   : S - same as input, with a lot more info (screen, textures, colors,
%   timings, etc)
%
    PsychDefaultSetup(2);
    Screen('Preference', 'SkipSyncTests', 0);
    screens= Screen('Screens',1);
    S.screenNumber= max(screens);
    S.white=WhiteIndex(S.screenNumber);
    S.black=BlackIndex(S.screenNumber);
    S.grey= white/2;
    [S.window,S.windowRect]= PsychImaging('OpenWindow',S.screenNumber,S.black);
    [S.screenXpixels, S.screenYpixels]= Screen('WindowSize', S.window);
    [S.xCenter, S.yCenter]= RectCenter(S.windowRect);
    Screen('BlendFunction', S.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    S.TR=1;
    S.dist = 156;  % Distance from eye to screen in cm
    S.width = 70; % Width of the screen in cm
    
    % ============== Basic Settings ==============
    S.NrTrials= 48; 
    S.NrReps = Shuffle([15,15,18]);
    S.readyTime= 5*S.TR;
    S.gapTime= 0.5*S.TR;
    S.instructionTime= 0.5*S.TR; 
    S.interCondTime1 = Shuffle(repelem([1,2,3]*S.TR,16)); 
    S.actionTime= 1*S.TR;
    S.interCondTime2 = Shuffle(repelem([1,2,3]*S.TR,16)); 
    S.whiteNoiseTime = Shuffle([10,11,12]*S.TR);
    
    % ============== Import Textures ==============
    dir_fig = 'F:\SEM_mri\Paradigm_fmri\PicsToUse\';
    
    proLeftKP_green = imread(char(dir_fig + "ProLeft_KP_Green.png"));
    proRightKP_green = imread(char(dir_fig + "ProRight_KP_Green.png"));
    antiLeftKP_green = imread(char(dir_fig + "AntiLeft_KP_Green.png"));
    antiRightKP_green = imread(char(dir_fig + "AntiRight_KP_Green.png"));
    
    proLeftS_green = imread(char(dir_fig + "ProLeft_Sac_Green.png"));
    proRightS_green = imread(char(dir_fig + "ProRight_Sac_Green.png"));
    antiLeftS_green = imread(char(dir_fig + "AntiLeft_Sac_Green.png"));
    antiRightS_green = imread(char(dir_fig + "AntiRight_Sac_Green.png"));
    
    proLeftKP_red = imread(char(dir_fig + "ProLeft_KP_Red.png"));
    proRightKP_red = imread(char(dir_fig + "ProRight_KP_Red.png"));
    antiLeftKP_red = imread(char(dir_fig + "AntiLeft_KP_Red.png"));
    antiRightKP_red = imread(char(dir_fig + "AntiRight_KP_Red.png"));
    
    proLeftS_red = imread(char(dir_fig + "ProLeft_Sac_Red.png"));
    proRightS_red = imread(char(dir_fig + "ProRight_Sac_Red.png"));
    antiLeftS_red = imread(char(dir_fig + "AntiLeft_Sac_Red.png"));
    antiRightS_red = imread(char(dir_fig + "AntiRight_Sac_Red.png"));
    
    whiteNoise = imread(char(dir_fig + "white-noise.jpg"));
    
    % ============== Setup Textures ==============
    S.Textures= [];
    S.Textures(1)= Screen('MakeTexture',S.window,proLeftKP_green);
    S.Textures(2)= Screen('MakeTexture',S.window,proRightKP_green);
    S.Textures(3)= Screen('MakeTexture',S.window,antiLeftKP_green);
    S.Textures(4)= Screen('MakeTexture',S.window,antiRightKP_green);
    
    S.Textures(5)= Screen('MakeTexture',S.window,proLeftS_green);
    S.Textures(6)= Screen('MakeTexture',S.window,proRightS_green);
    S.Textures(7)= Screen('MakeTexture',S.window,antiLeftS_green);
    S.Textures(8)= Screen('MakeTexture',S.window,antiRightS_green);

    S.Textures(9)= Screen('MakeTexture',S.window,proLeftKP_red);
    S.Textures(10)= Screen('MakeTexture',S.window,proRightKP_red);
    S.Textures(11)= Screen('MakeTexture',S.window,antiLeftKP_red);
    S.Textures(12)= Screen('MakeTexture',S.window,antiRightKP_red);
    
    S.Textures(13)= Screen('MakeTexture',S.window,proLeftS_red);
    S.Textures(14)= Screen('MakeTexture',S.window,proRightS_red);
    S.Textures(15)= Screen('MakeTexture',S.window,antiLeftS_red);
    S.Textures(16)= Screen('MakeTexture',S.window,antiRightS_red);
    
    S.Textures(17)= Screen('MakeTexture',S.window,whiteNoise);
    
    % ============== Design Image Rect ==============
    S.pixelsY=angle2pix(S,10);
    S.pixelsX=angle2pix(S,8.6);
    S.textureRect= CenterRectOnPointd([0 0 S.pixelsX S.pixelsY ],S.xCenter,S.yCenter); 
    S.textureWhiteNoise = CenterRectOnPointd([0 0 S.screenXpixels S.screenYpixels],S.xCenter,S.yCenter);
    
    % ============== Kb Keys to press ==============
    KbName('UnifyKeyNames');
    S.leftKey= KbName('LeftArrow');
    S.rightKey= KbName('RightArrow');
    S.escKey= KbName('ESCAPE');
    S.cKey= KbName('c');
    S.vKey= KbName('v');
    activeKeys= [S.rightKey S.leftKey S.escKey S.cKey S.vKey];
    RestrictKeysForKbCheck(activeKeys);
    
    % ============== Setup Cross Fixation ==============
    Screen('TextFont', S.window, 'Courier New');
    Screen('TextSize', S.window, 48);
    xCoords= [S.xCenter-S.screenXpixels/40 S.xCenter+S.screenXpixels/40 S.xCenter S.xCenter];
    yCoords= [S.yCenter S.yCenter S.yCenter-S.screenXpixels/40 S.yCenter+S.screenXpixels/40];
    S.allCoords= [xCoords; yCoords];
    S.crossWidthPix = 4;
    S.crossColor = [1 1 1];
    
     % ============== Setup Lines ==============
    S.horizontalLine= [0 S.screenXpixels; S.yCenter S.yCenter];
    S.verticalLine1= [150*S.screenXpixels/1440 150*S.screenXpixels/1440; 0 S.screenYpixels];
    S.verticalLine2= [S.screenXpixels-(150*S.screenXpixels/1440) S.screenXpixels-(150*S.screenXpixels/1440); 0 S.screenYpixels];
    S.lineWidthPix= 1;
    S.lineColor= [.3 .3 .3];
    
    % ============== Setup Frame Rects For Gaze Positions ==============
    fixationBaseFrame = [0 0 S.screenXpixels/4-175 S.screenXpixels];
    saccadeBaseFrame= [0 0 S.screenXpixels/4+125 S.screenXpixels/4];
    microSaccadeBaseFrame= [0 0 S.screenXpixels/4-250 S.screenXpixels/4];
    saccadeFrameXpos= [270 S.screenXpixels-270];
    microSaccadeFrameXpos= [570 S.screenXpixels-570];
    
    S.allFrames= nan(4,5);
    S.allFrames(:,1)= CenterRectOnPoint(saccadeBaseFrame,saccadeFrameXpos(1),S.yCenter);
    S.allFrames(:,2)= CenterRectOnPoint(saccadeBaseFrame,saccadeFrameXpos(2),S.yCenter);
    S.allFrames(:,3)= CenterRectOnPoint(microSaccadeBaseFrame,microSaccadeFrameXpos(1),S.yCenter);
    S.allFrames(:,4)= CenterRectOnPoint(microSaccadeBaseFrame,microSaccadeFrameXpos(2),S.yCenter);
    S.allFrames(:,5)= CenterRectOnPoint(fixationBaseFrame,S.xCenter,S.yCenter);
    
    % ============== Randomise Instructions ==============
    % ======== NoGo, Anti, Pro same nº repetitions =======
    inst = [Shuffle(repelem([1:8],3)); Shuffle(repelem([9:16],3))];
    inst = inst(randperm(size(inst, 1)), :); 
    inst_ord=[];
    for i=1:3:length(inst(1,:))
        inst_ord = [inst_ord, inst(1,i:i+2)];
        inst_ord = [inst_ord, inst(2,i:i+2)];
    end
    S.instMatRand=inst_ord;
    % ============== Create dataMat ==============
    
    S.dataMat= nan(18,S.NrTrials);
    
    % --- Open COM Ports for Response box and Trigger
    if S.RSPBOX
        S.response_box_handle = IOPort('OpenSerialPort','COM4');
        IOPort('Purge',S.response_box_handle);
    end

    if S.TRIGGER
        S.syncbox_handle = IOPort('OpenSerialPort','COM5','BaudRate=57600 DataBits=8 Parity=None StopBits=1 FlowControl=None');
        IOPort('Purge',S.syncbox_handle);
    end
    
end