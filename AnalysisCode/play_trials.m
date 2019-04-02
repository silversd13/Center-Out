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

% type of trials
block_str = strsplit(datadir,'/');
block_str = block_str{end-1};
switch block_str,
    case 'BCI_Imagined',
        block_flag = 1;
    case 'BCI_CLDA',
        block_flag = 2;
    case 'BCI_Fixed',
        block_flag = 3;
end

% for movie
if saveFlag,
    savefile = input('Movie File Name: ','s');
    vidObj = VideoWriter(sprintf('%s',savefile),'MPEG-4');
    vidObj.FrameRate = playback_speed/.1;
    vidObj.Quality = 100;
    open(vidObj);
end

% get params
load(fullfile(datadir,files{1}))
screen_sz = TrialData.Params.ScreenRectangle(3:4);
cursor_sz = 4*TrialData.Params.CursorSize;
cursor_col = TrialData.Params.CursorColor;
target_sz = 4*TrialData.Params.TargetSize;
target_col = TrialData.Params.OutTargetColor;

% set up figure
fig = figure('units','normalized','position',[.1,.1,.8,.8]);

% screen output
% subplot(1,5,3:5)
hold on
start = plot(0,0,'.','MarkerSize',target_sz,'color',target_col/255);
target = plot(nan,nan,'.','MarkerSize',target_sz,'color',target_col/255);
cursor = plot(nan,nan,'.','MarkerSize',cursor_sz,'color',cursor_col/255);
INTvel = plot([-400,nan],[-400,nan],'-g');
OPTvel = plot([-400,nan],[-400,nan],'-b');
KFvel = plot([-400,nan],[-400,nan],'-r','linewidth',1.8);
AvgIntVel = plot([-400,nan],[-400,nan],'-c','linewidth',1.8);
AvgKFVel = plot([-400,nan],[-400,nan],'-m','linewidth',1.8);
txt = text(300,400,{'',''},...
    'horizontalalignment','left',...
    'verticalalignment','bottom',...
    'fontsize',12);
axis equal
xlim([-500,+500])
ylim([-500,+500])
set(gca,'YDir','reverse')
legend(gca,[INTvel,OPTvel,KFvel,AvgIntVel,AvgKFVel],...
    'Intended Vel', 'Optimal Vel', 'KF Vel (x5)', 'Avg Intended Vel (4 bins)', 'Avg KF Vel (4 bins; x5)', ...
    'location','southwest','fontsize',12)

% % track angle btw velocities
% subplot(1,5,1:2)
% hold on
% err_kg_vel = plot(0,0,'.r');
% err_kf_vel = plot(0,0,'.c');
% xlabel('# bins')
% ylabel('avg error (|degrees|)')
% legend(gca,'KF vel', 'KG vel (10 bins)', 'location','southwest','fontsize',12)
        
% go through each file, load and play movie
int_vel_buf = nan(4,2);
kf_vel_buf = nan(4,2);
ct = 1;
for n=1:length(files),
    load(fullfile(datadir,files{n}))
    %title(subplot(1,5,3:5),sprintf(files{n}))
    
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
                start.Visible = 'off';
                target.Visible = 'on';
            end
        end
        
        % plot cursor, target, pause
        cursor.XData = TrialData.CursorState(1,t);
        cursor.YData = TrialData.CursorState(2,t);
        
        % compute vel from eq. Y = C*X, ie. X = C\Y.
        int_state = TrialData.KalmanFilter.C(:,3:end)\TrialData.NeuralFeatures{t};
        opt_vel = TrialData.IntendedCursorState(3:4,t)';
        kf_vel = TrialData.CursorState(3:4,t)';
        
        % implement kg's idea for denoising
        int_vel_buf          = circshift(int_vel_buf,-1);
        int_vel_buf(end,:)   = int_state(1:2);
        int_vel_den          = nanmean(int_vel_buf);
        kf_vel_buf          = circshift(kf_vel_buf,-1);
        kf_vel_buf(end,:)   = kf_vel;
        kf_vel_den          = nanmean(kf_vel_buf);
        
        % plot KF vel, assist vel, C vel
        if Flag>0,
            KFvel.XData(2)  = (TrialData.CursorState(3,t)-400);
            KFvel.YData(2)  = (TrialData.CursorState(4,t)-400);
            AvgIntVel.XData(2)  = (int_vel_den(1)/5-400);
            AvgIntVel.YData(2)  = (int_vel_den(2)/5-400);
            AvgKFVel.XData(2)  = (kf_vel_den(1)-400);
            AvgKFVel.YData(2)  = (kf_vel_den(2)-400);
            OPTvel.XData(2) = (TrialData.IntendedCursorState(3,t)/5-400);
            OPTvel.YData(2) = (TrialData.IntendedCursorState(4,t)/5-400);
            INTvel.XData(2) = (int_state(1)/5-400);
            INTvel.YData(2) = (int_state(2)/5-400);
%             err_kg_vel_buf(ct) = ...
%                 atan2(sm_vel(1)*opt_vel(2)-opt_vel(1)*sm_vel(2),sm_vel(1)*sm_vel(2)+opt_vel(1)*opt_vel(2));
%             err_kg_vel.XData(ct) = ct;
%             err_kg_vel.YData(ct) = err_kg_vel_buf(ct);%circ_mean(err_kg_vel_buf')*180/pi;
%             err_kf_vel_buf(ct) = ...
%                 atan2(kf_vel(1)*opt_vel(2)-opt_vel(1)*kf_vel(2),kf_vel(1)*kf_vel(2)+opt_vel(1)*opt_vel(2));
%             err_kf_vel.XData(ct) = ct;
%             err_kf_vel.YData(ct) = err_kf_vel_buf(ct);%circ_mean(err_kf_vel_buf')*180/pi;
%             ct = ct + 1;
        end
        
        % text
        switch block_flag,
            case 1,
                txt.String = {
                    sprintf('Visual Feedback')
                    sprintf('Trial: %i',TrialData.Trial)
                    sprintf('Time: %.1f',time-TrialData.Time(1))
                    };
            case 2,
                txt.String = {
                    sprintf('Adaptation')
                    sprintf('Trial: %i',TrialData.Trial)
                    sprintf('Assist: %.2f',TrialData.CursorAssist(1))
                    sprintf('Lambda: %.2f',TrialData.KalmanFilter.Lambda)
                    sprintf('Time: %.1f',time-TrialData.Time(1))
                    };
            case 3,
                txt.String = {
                    sprintf('Fixed')
                    sprintf('Trial: %i',TrialData.Trial)
                    sprintf('Time: %.1f',time-TrialData.Time(1))
                    };
        end
        
        % for saving movie
        if saveFlag,
            frame = getframe(fig);
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

