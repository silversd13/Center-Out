function ExperimentStart(Subject,ControlMode,BLACKROCK,DEBUG)
% function ExperimentStart(Subject,ControlMode)
% Subject - string for the subject id
% ControlMode - [1,2,3,4] for mouse pos, mouse vel, refit, & open control
% BLACKROCK - [0,1] if 1, collects, processes, and saves neural data
% DEBUG - [0,1] if 1, enters DEBUG mode in which screen is small and cursor
%   remains unhidden

%% Clear All and Close All
clearvars -global -except Subject ControlMode BLACKROCK DEBUG
clc
warning off

if ~exist('Subject','var'), Subject = 'Test'; DEBUG = 1; end
if ~exist('ControlMode','var'), ControlMode = 1; end
if ~exist('BLACKROCK','var'), BLACKROCK = 0; end
if ~exist('DEBUG','var'), DEBUG = 0; end

% addpath(genpath('/Applications/Psychtoolbox'));
AssertOpenGL;
KbName('UnifyKeyNames');

if strcmpi(Subject,'Test'), Subject = 'Test'; end

%% Initialize Window
% Screen('Preference', 'SkipSyncTests', 0);
if DEBUG
    [Params.WPTR, Params.ScreenRectangle] = Screen('OpenWindow', 0, 0, [50 50 1000 1000]);
else
    [Params.WPTR, Params.ScreenRectangle] = Screen('OpenWindow', 0, 0, [10 30 1900 1000]);
end
Params.Center = [mean(Params.ScreenRectangle([1,3])),mean(Params.ScreenRectangle([2,4]))];
if ~DEBUG, HideCursor; end

%% Font
Screen('TextFont',Params.WPTR, 'Arial');
Screen('TextSize',Params.WPTR, 28);

%% Retrieve Parameters from Params File
Params.Subject = Subject;
Params.ControlMode = ControlMode;
Params.BLACKROCK = BLACKROCK;
Params.DEBUG = DEBUG;
Params = GetParams(Params);

%% Initialize Blackrock System
if BLACKROCK,
    addpath('C:\Program Files (x86)\Blackrock Microsystems\NeuroPort Windows Suite')
    cbmex('close'); % always close
    cbmex('open'); % open library
    cbmex('trialconfig', 1); % empty the buffer
end

%% Neural Signal Processing
% create neuro structure for keeping track of all neuro updates/state
% changes
Neuro.FilterBank    = Params.FilterBank;
Neuro.NumChannels   = Params.NumChannels;
Neuro.BufferSamps   = Params.BufferSamps;
Neuro.BadChannels   = Params.BadChannels;
Neuro.ReferenceMode = Params.ReferenceMode;
Neuro.NumFeatures   = Params.NumFeatures;
Neuro.LastUpdateTime= GetSecs;

% initialize filter bank state
for i=1:length(Params.FilterBank),
    Neuro.FilterBank(i).state = [];
end

% initialize stats for each channel for z-scoring
Neuro.ChStats.wSum1  = 0; % count
Neuro.ChStats.wSum2  = 0; % squared count
Neuro.ChStats.mean   = zeros(1,Params.NumChannels); % estimate of mean for each channel
Neuro.ChStats.S      = zeros(1,Params.NumChannels); % aggregate deviation from estimated mean for each channel
Neuro.ChStats.var    = zeros(1,Params.NumChannels); % estimate of variance for each channel

% create delta buffer
Neuro.FilterDataBuf = zeros(Neuro.BufferSamps,Neuro.NumChannels,3);

%% Cursor Object
global Cursor
Cursor.ControlMode = Params.ControlMode;
Cursor.LastUpdateTime = GetSecs;
Cursor.State = [0,0,0,0,1]';
dt = 1/Params.ScreenRefreshRate;
switch Cursor.ControlMode,
    case 1,
        Cursor.A = [...
            1   0   dt  0   0;
            0   1   0   dt  0;
            0   0   1   0   0;
            0   0   0   1   0;
            0   0   0   0   1];
    case 2,
        Cursor.A = [...
            1   0   dt  0   0;
            0   1   0   dt  0;
            0   0   1   0   0;
            0   0   0   1   0;
            0   0   0   0   1];
    case 3,
        Cursor.A = [...
            1       0       dt      0       0;
            0       1       0       dt      0;
            0       0       .90     .01     0;
            0       0       .01     .90     0;
            0       0       0       0       1];
        Cursor.W = [...
            0       0       0       0       0;
            0       0       0       0       0;
            0       0       175     -1.2    0;
            0       0       -1.2    175     0;
            0       0       0       0       0];
        Cursor.P = zeros(5);
end

%% Start
try
    % Baseline 
    if Params.BaselineTime>0,
        Cursor.DeltaAssistance = 0;
        Neuro = RunBaseline(Params,Neuro);
    end
    
    % Imagined Cursor Movements Loop
    if Params.NumImaginedBlocks>0,
        Neuro = RunTask(Params,Neuro,1);
    end
    
    % Adaptation Loop
    if Params.NumAdaptBlocks>0,
        Neuro = RunTask(Params,Neuro,2);
    end
    
    % Fixed Decoder Loop
    if Params.NumFixedBlocks>0,
        Neuro = RunTask(Params,Neuro,3);
    end
    
    % Pause and Finish!
    ExperimentStop();
    
catch ME, % handle errors gracefully
    Screen('CloseAll')
    errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
        ME.stack(1).name, ME.stack(1).line, ME.message);
    fprintf(1,'\n%s\n', errorMessage);
end

end % ExperimentStart
