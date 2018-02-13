function Params = GetParams(Params)

%% Experiment
Params.Task = 'Center-Out';
switch Params.ControlMode,
    case 1, Params.ControlModeStr = 'MousePosition';
    case 2, Params.ControlModeStr = 'MouseVelocity';
    case 3, Params.ControlModeStr = 'ReFit';
    case 4, Params.ControlModeStr = 'Open';
end

%% Current Date and Time
% get today's date
now = datetime;
Params.YYYYMMDD = sprintf('%i',yyyymmdd(now));
Params.HHMMSS = sprintf('%02i%02i%02i',now.Hour,now.Minute,round(now.Second));

%% Data Saving

% if Subject is 'Test' or 'test' then can write over previous test
if strcmpi(Params.Subject,'Test'),
    Params.YYYYMMDD = 'YYYYMMDD';
    Params.HHMMSS = 'HHMMSS';
end

projectdir = fullfile('~','Projects','Center-Out');
datadir = fullfile(projectdir,'Data',Params.Subject,Params.YYYYMMDD,Params.HHMMSS);

% create folder for saving
Params.datadir = datadir;
if ~exist(Params.datadir,'dir'), mkdir(Params.datadir); end

%% Targets
Params.TargetSize = 30;
Params.OutTargetColor = [0,255,0];
Params.InTargetColor = [255,0,0];

Params.StartTargetPosition  = Params.Center;
Params.TargetRect = ...
    [-Params.TargetSize -Params.TargetSize +Params.TargetSize +Params.TargetSize];

Params.ReachTargetAngles = (0:45:315)';
Params.ReachTargetRadius = 400;
Params.ReachTargetPositions = ...
    Params.StartTargetPosition ...
    + Params.ReachTargetRadius ...
    * [cosd(Params.ReachTargetAngles) sind(Params.ReachTargetAngles)];


%% Cursor
Params.CursorColor = [0,0,255];
Params.CursorSize = 5;
Params.CursorRect = [-Params.CursorSize -Params.CursorSize ...
    +Params.CursorSize +Params.CursorSize];

%% Trial and Block Types
Params.NumBlocks = 1;
Params.NumTrialsPerBlock = length(Params.ReachTargetAngles);
Params.NumTrials = Params.NumBlocks*Params.NumTrialsPerBlock;

%% Hold Times
Params.TargetHoldTime = 1;
Params.InterTrialInterval = 0;
Params.InstructedDelay = 0;
Params.MaxStartTime = 15;
Params.MaxReachTime = 15;
Params.InterBlockInterval = 0;

%% Reward
Params.RewardFb = 0;

%% Control
Params.Gain = 1;

%% Save Parameters
save(fullfile(Params.datadir,'Params.mat'),'Params');



