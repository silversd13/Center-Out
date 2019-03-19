function plot_behavior()

% ask user for files
[files,datadir] = uigetfile('*.mat','Select the INPUT DATA FILE(s)','MultiSelect','on');

% get behavior metrics per trial
cursor_assist = [];
target_ang = [];
time_to_target = [];
success = [];
cursor_distance = [];
cursor_dev_from_opt = [];
for n=1:length(files),
    load(fullfile(datadir,files{n})) %#ok<*LOAD>
    
    % trial params
    cursor_assist(n) = TrialData.CursorAssist(1);
    target_ang(n) = TrialData.TargetAngle;

    % performance measures
    time_to_target(n) = TrialData.Time(end) - TrialData.Events(end).Time;
    success(n) = TrialData.ErrorID==0;
    
    tidx = TrialData.Time >= TrialData.Events(end).Time;
    cursor_traj = TrialData.CursorState(1:2,tidx);
    cursor_distance(n) = sum(sqrt(sum(diff(cursor_traj,1,2).^2)));
    cursor_dev_from_opt(n) = ;
end

end