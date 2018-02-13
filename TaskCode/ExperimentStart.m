function ExperimentStart(Subject,ControlMode)
% function ExperimentStart(Subject,ControlMode)
% Subject - string for the subject id
% ControlMode - [1,2,3] for mouse, refit, & open control

%% Clear All and Close All
clearvars -except Subject SessionID
clc
warning off

if ~exist('Subject','var'), Subject = 'Test'; end
if ~exist('ControlMode','var'), ControlMode = 1; end

addpath(genpath('/Applications/Psychtoolbox'));
AssertOpenGL;

if strcmpi(Subject,'Test'),
    Subject = 'Test';
    DEBUG = true;
else,
    DEBUG = false;
end

%% Initialize Window
Screen('Preference', 'SkipSyncTests', 1);
if DEBUG
    [Params.WPTR, rect] = Screen('OpenWindow', 0, 0, [10 10 500 500]);
else
    [Params.WPTR, rect] = Screen('OpenWindow', 0, 0);
end
Params.Center = [mean(rect([1,3])),mean(rect([2,4]))];
if ~DEBUG, HideCursor; end

  
%% Start
try
    % Get Basic Parameters
    Params.Subject = Subject;
    Params.ControlMode = ControlMode;

    % Experiment Loop
    RunTask(Params);
catch ME
    Screen('CloseAll')
    ME.message
end


