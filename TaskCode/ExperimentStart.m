function ExperimentStart(Subject,ControlMode,DEBUG)
% function ExperimentStart(Subject,ControlMode)
% Subject - string for the subject id
% ControlMode - [1,2,3,4] for mouse pos, mouse vel, refit, & open control
% DEBUG - [0,1] if 1, enters DEBUG mode in which screen is small and cursor
%   remains unhidden

%% Clear All and Close All
clearvars -except Subject ControlMode DEBUG
clc
warning off

if ~exist('Subject','var'), Subject = 'Test'; end
if ~exist('ControlMode','var'), ControlMode = 1; end
if ~exist('DEBUG','var'), DEBUG = 0; end

addpath(genpath('/Applications/Psychtoolbox'));
AssertOpenGL;

if strcmpi(Subject,'Test'), Subject = 'Test'; end

%% Initialize Window
Screen('Preference', 'SkipSyncTests', 1);
if DEBUG
    [Params.WPTR, Params.ScreenRectangle] = Screen('OpenWindow', 0, 0, [10 10 500 500]);
else
    [Params.WPTR, Params.ScreenRectangle] = Screen('OpenWindow', 0, 0);
end
Params.Center = [mean(Params.ScreenRectangle([1,3])),mean(Params.ScreenRectangle([2,4]))];
if ~DEBUG, HideCursor; end

%% Font
Screen('TextFont',Params.WPTR, 'Arial');
Screen('TextSize',Params.WPTR, 30);
  
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


