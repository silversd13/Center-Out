function play_trials(playback_speed)
% speed sets playback speed (default=1, real time)

if ~exist('speed','var'), playback_speed = 1; end

% ask user for files
[files,datadir] = uigetfile('*.mat','Select the INPUT DATA FILE(s)','MultiSelect','on');
if ~iscell(files),
    tmp = files;
    clear files;
    files{1} = tmp;
    clear tmp;
end

% get params
load(fullfile(datadir,files{1}))
screen_sz = TrialData.Params.ScreenRectangle(3:4);
cursor_sz = 4*TrialData.Params.CursorSize;
cursor_col = TrialData.Params.CursorColor;
target_sz = 4*TrialData.Params.TargetSize;
target_col = TrialData.Params.OutTargetColor;

% set up figure
figure('units','normalized','position',[.1,.1,.8,.8])
hold on
cursor = plot(nan,nan,'.','MarkerSize',cursor_sz,'color',cursor_col/255);
target = plot(nan,nan,'.','MarkerSize',target_sz,'color',target_col/255);
txt = text(500,-450,{'st','art'},...
    'horizontalalignment','right',...
    'verticalalignment','bottom');
axis equal
xlim([-500,+500])
ylim([-500,+500])

% go through each file, load and play movie
for n=1:length(files),
    load(fullfile(datadir,files{n}))
    title(sprintf(files{n}))
    
    target.XData = TrialData.TargetPosition(1);
    target.YData = TrialData.TargetPosition(2);

    % go through trial
    for t=1:length(TrialData.Time),
        % plot cursor, target, pause
        cursor.XData = TrialData.CursorState(1,t);
        cursor.YData = TrialData.CursorState(2,t);
        
        % text
        txt.String = {
            sprintf('Assist: %.2f',TrialData.CursorAssist(1))
            sprintf('Time: %.1f',TrialData.Time(t)-TrialData.Time(1))
            };
        
        % draw
        drawnow
        pause(.1/playback_speed)
    end
end


end