function play_trials(playback_speed,saveFlag)
% playback_speed sets playback speed (default=1, real time)
% saveFlag [0,1], if 1, movie is saved

if ~exist('speed','var'), playback_speed = 1; end
if ~exist('saveFlag','var'), saveFlag = 0; end

% ask user for files
[files,datadir] = uigetfile('*.mat','Select the INPUT DATA FILE(s)','MultiSelect','on');
if ~iscell(files),
    tmp = files;
    clear files;
    files{1} = tmp;
    clear tmp;
end
disp(datadir)
disp(files{1})
disp(files{end})

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
start = plot(0,0,'.','MarkerSize',target_sz,'color',target_col/255);
target = plot(nan,nan,'.','MarkerSize',target_sz,'color',target_col/255);
cursor = plot(nan,nan,'.','MarkerSize',cursor_sz,'color',cursor_col/255);
KFvel = plot([-400,nan],[400,nan],'-r');
OPTvel = plot([-400,nan],[400,nan],'-b');
INTvel = plot([-400,nan],[400,nan],'-g');
txt = text(500,-450,{'',''},...
    'horizontalalignment','right',...
    'verticalalignment','bottom');
axis equal
xlim([-500,+500])
ylim([-500,+500])

% for movie
if saveFlag,
    savefile = input('Movie File Name: ','s');
    vidObj = VideoWriter(sprintf('%s',savefile),'MPEG-4');
    vidObj.FrameRate = playback_speed/.1;
    open(vidObj);
end

% go through each file, load and play movie
for n=1:length(files),
    load(fullfile(datadir,files{n}))
    title(sprintf(files{n}))
    
    % target position
    target.XData = TrialData.TargetPosition(1);
    target.YData = TrialData.TargetPosition(2);
    
    % go through trial
    for t=1:length(TrialData.Time),
        % trial stage
        time = TrialData.Time(t);
        if time < TrialData.Events(2).Time, % ITI
            Flag = 0;
            start.Visible = 'off';
            target.Visible = 'off';
        else, % past ITI
            if length(TrialData.Events)>2, % made it past start target
                if time < TrialData.Events(3).Time, % START
                    Flag = 1;
                    start.Visible = 'on';
                    target.Visible = 'off';
                else, % REACH
                    Flag = 2;
                    start.Visible = 'off';
                    target.Visible = 'on';
                end
            else, % error on start target
                Flag = 1;
                start.Visible = 'on';
                target.Visible = 'off';
            end
        end
        
        % plot cursor, target, pause
        cursor.XData = TrialData.CursorState(1,t);
        cursor.YData = TrialData.CursorState(2,t);
        
        % compute vel from eq. Y = C*X, ie. X = C\Y.
        int_state = TrialData.KalmanFilter.C(:,3:end)\TrialData.NeuralFeatures{t};
        
        % plot KF vel, assist vel, C vel
        if Flag>0,
            KFvel.XData(2)  = (TrialData.CursorState(3,t)/5-400);
            KFvel.YData(2)  = (TrialData.CursorState(4,t)/5+400);
            OPTvel.XData(2) = (TrialData.IntendedCursorState(3,t)/5-400);
            OPTvel.YData(2) = (TrialData.IntendedCursorState(4,t)/5+400);
            INTvel.XData(2) = (int_state(1)/5-400);
            INTvel.YData(2) = (int_state(2)/5+400);
        end
        
        % text
        txt.String = {
            sprintf('Trial: %i',TrialData.Trial)
            sprintf('Assist: %.2f',TrialData.CursorAssist(1))
            sprintf('Lambda: %.2f',log(.5)/(log(TrialData.KalmanFilter.Lambda)*10))
            sprintf('Time: %.1f',time-TrialData.Time(1))
            };
        
        
        % for saving movie
        if saveFlag,
            frame = getframe;
            writeVideo(vidObj,frame)
        else,
            % draw
            drawnow
            pause(.1/playback_speed)
        end
    end
end

if saveFlag,
    close(vidObj);
end
close all


end

