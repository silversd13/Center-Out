function [Data, Neuro] = RunTrial(Data,Params,Neuro,TaskFlag)
% Runs a trial, saves useful data along the way
% Each trial contains the following pieces
% 1) Inter-trial interval
% 2) Get the cursor to the start target (center)
% 3) Hold position during an instructed delay period
% 4) Get the cursor to the reach target (different on each trial)
% 5) Feedback

global Cursor

%% Set up trial
StartTargetPos = Params.StartTargetPosition;
ReachTargetPos = Data.TargetPosition;
tlast = GetSecs;

% Output to Command Line
fprintf('\nTrial: %i\n',Data.Trial)
fprintf('Target: %i\n',Data.TargetAngle)

%% Inter Trial Interval
if ~Data.ErrorID && Params.InterTrialInterval>0,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Inter Trial Interval';

    if TaskFlag==1,
        OptimalCursorTraj = ...
            GenerateCursorTraj(Cursor.State,Cursor.State,Params.InterTrialInterval,Params);
        ct = 1;
    end
    
    done = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, ExperimentPause(Params); end

        % Update Screen Every Xsec
        if (tim-tlast) > 1/Params.ScreenRefreshRate,
            % time
            tlast = tim;
            Data.Time(1,end+1) = tim;
            
            % cursor
            PredictCursor(Params);
            
            % grab and process neural data
            if ((tim-Cursor.LastUpdateTime)>1/Params.UpdateRate),
                Cursor.LastUpdateTime = tim;
                if Params.BLACKROCK,
                    [Neuro,Data] = NeuroPipeline(Neuro,Data);
                    Data.NeuralTime(1,end+1) = tim;
                end
                UpdateCursor(Params,Neuro);
            end
            
            % cursor
            if TaskFlag==1, % imagined movements
                Cursor.State(1:2) = OptimalCursorTraj(ct,:);
                ct = ct + 1;
            end
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.State(1) + Params.Center(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.State(2) + Params.Center(2); % add y-pos
            Data.CursorState(:,end+1) = Cursor.State;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;

            % draw
            Screen('FillOval', Params.WPTR, Params.CursorColor, CursorRect);
            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);
        end

        % end if takes too long
        if (tim - tstart) > Params.InterTrialInterval,
            done = 1;
        end

    end % Inter Trial Interval
end % only complete if no errors

%% Go to Start Target
if ~Data.ErrorID && ~Params.CenterReset,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Start Target';

    if TaskFlag==1,
        OptimalCursorTraj = [...
            GenerateCursorTraj(Cursor.State,StartTargetPos,1.5,Params);
            GenerateCursorTraj(StartTargetPos,StartTargetPos,Params.TargetHoldTime,Params)];
        ct = 1;
    end
    
    done = 0;
    totalTime = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, ExperimentPause(Params); end

        % Update Screen Every Xsec
        if (tim-tlast) > 1/Params.ScreenRefreshRate,
            % time
            dt = tim - tlast;
            tlast = tim;
            Data.Time(1,end+1) = tim;
            
            % cursor
            PredictCursor(Params,StartTargetPos);
            
            % grab and process neural data
            if ((tim-Cursor.LastUpdateTime)>1/Params.UpdateRate),
                Cursor.LastUpdateTime = tim;
                if Params.BLACKROCK,
                    [Neuro,Data] = NeuroPipeline(Neuro,Data);
                    Data.NeuralTime(1,end+1) = tim;
                end
                UpdateCursor(Params,Neuro);
            end
            
            % cursor
            if TaskFlag==1, % imagined movements
                Cursor.State(1:2) = OptimalCursorTraj(ct,:);
                ct = ct + 1;
            end
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.State(1) + Params.Center(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.State(2) + Params.Center(2); % add y-pos
            Data.CursorState(:,end+1) = Cursor.State;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;

            % start target
            StartRect = Params.TargetRect; % centered at (0,0)
            StartRect([1,3]) = StartRect([1,3]) + StartTargetPos(1) + Params.Center(1); % add x-pos
            StartRect([2,4]) = StartRect([2,4]) + StartTargetPos(2) + Params.Center(2); % add y-pos
            inFlag = InTarget(Cursor,StartTargetPos,Params.TargetSize);
            if inFlag, StartCol = Params.InTargetColor;
            else, StartCol = Params.OutTargetColor;
            end
            
            % draw
            Screen('FillOval', Params.WPTR, ...
                cat(1,StartCol,Params.CursorColor)', ...
                cat(1,StartRect,CursorRect)')
            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);
            
            % start counting time if cursor is in target
            if inFlag,
                totalTime = totalTime + dt;
            else
                totalTime = 0;
            end
        end

        % end if takes too long
        if (tim - tstart) > Params.MaxStartTime,
            done = 1;
            Data.ErrorID = 1;
            Data.ErrorStr = 'StartTarget';
            fprintf('ERROR: %s\n',Data.ErrorStr)
        end

        % end if in start target for hold time
        if totalTime > Params.TargetHoldTime,
            done = 1;
        end
    end % Start Target Loop
else % only complete if no errors and no automatic reset to center
    Cursor.State = [0,0,0,0,1]';
end

%% Instructed Delay
if ~Data.ErrorID && Params.InstructedDelayTime>0,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Instructed Delay';
    
    if TaskFlag==1,
        OptimalCursorTraj = ...
            GenerateCursorTraj(StartTargetPos,StartTargetPos,Params.InstructedDelayTime,Params);
        ct = 1;
    end
    
    done = 0;
    totalTime = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, ExperimentPause(Params); end
        
        % Update Screen
        if (tim-tlast) > 1/Params.ScreenRefreshRate,
            % time
            dt = tim - tlast;
            tlast = tim;
            Data.Time(1,end+1) = tim;

            % cursor
            PredictCursor(Params,StartTargetPos);
            
            % grab and process neural data
            if ((tim-Cursor.LastUpdateTime)>1/Params.UpdateRate),
                Cursor.LastUpdateTime = tim;
                if Params.BLACKROCK,
                    [Neuro,Data] = NeuroPipeline(Neuro,Data);
                    Data.NeuralTime(1,end+1) = tim;
                end
                UpdateCursor(Params,Neuro);
            end
            
            % cursor
            if TaskFlag==1, % imagined movements
                Cursor.State(1:2) = OptimalCursorTraj(ct,:);
                ct = ct + 1;
            end
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.State(1) + Params.Center(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.State(2) + Params.Center(2); % add y-pos
            Data.CursorState(:,end+1) = Cursor.State;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;

            % start target
            StartRect = Params.TargetRect; % centered at (0,0)
            StartRect([1,3]) = StartRect([1,3]) + StartTargetPos(1) + Params.Center(1); % add x-pos
            StartRect([2,4]) = StartRect([2,4]) + StartTargetPos(2) + Params.Center(2); % add y-pos
            inFlag = InTarget(Cursor,StartTargetPos,Params.TargetSize);
            if inFlag, StartCol = Params.InTargetColor;
            else, StartCol = Params.OutTargetColor;
            end
            
            % reach target
            ReachRect = Params.TargetRect; % centered at (0,0)
            ReachRect([1,3]) = ReachRect([1,3]) + ReachTargetPos(1) + Params.Center(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + ReachTargetPos(2) + Params.Center(2); % add y-pos
            ReachCol = Params.OutTargetColor;
                        
            % draw
            Screen('FillOval', Params.WPTR, ...
                cat(1,StartCol,ReachCol,Params.CursorColor)', ...
                cat(1,StartRect,ReachRect,CursorRect)')
            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);
            
            % start counting time if cursor is in target
            if inFlag,
                totalTime = totalTime + dt;
            else, % error if they left too early
                done = 1;
                Data.ErrorID = 2;
                Data.ErrorStr = 'InstructedDelayHold';
                fprintf('ERROR: %s\n',Data.ErrorStr)
            end
        end
        
        % end if in start target for hold time
        if totalTime > Params.InstructedDelayTime,
            done = 1;
        end
    end % Instructed Delay Loop
end % only complete if no errors

%% Go to reach target
if ~Data.ErrorID,
    tstart  = GetSecs;
    Data.Events(end+1).Time = tstart;
    Data.Events(end).Str  = 'Reach Target';

    if TaskFlag==1,
        OptimalCursorTraj = [...
            GenerateCursorTraj(StartTargetPos,ReachTargetPos,1.5,Params);
            GenerateCursorTraj(ReachTargetPos,ReachTargetPos,Params.TargetHoldTime,Params)];
        ct = 1;
    end
    
    done = 0;
    totalTime = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, ExperimentPause(Params); end

        % Update Screen
        if (tim-tlast) > 1/Params.ScreenRefreshRate,
            % time
            dt = tim - tlast;
            tlast = tim;
            Data.Time(1,end+1) = tim;

            % cursor
            PredictCursor(Params,ReachTargetPos);
            
            % grab and process neural data
            if ((tim-Cursor.LastUpdateTime)>1/Params.UpdateRate),
                Cursor.LastUpdateTime = tim;
                if Params.BLACKROCK,
                    [Neuro,Data] = NeuroPipeline(Neuro,Data);
                    Data.NeuralTime(1,end+1) = tim;
                end
                UpdateCursor(Params,Neuro);
            end
            
            % cursor
            if TaskFlag==1, % imagined movements
                Cursor.State(1:2) = OptimalCursorTraj(ct,:);
                ct = ct + 1;
            end
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.State(1) + Params.Center(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.State(2) + Params.Center(2); % add y-pos
            Data.CursorState(:,end+1) = Cursor.State;
            Data.CursorAssist(1,end+1) = Cursor.Assistance;

            % reach target
            ReachRect = Params.TargetRect; % centered at (0,0)
            ReachRect([1,3]) = ReachRect([1,3]) + ReachTargetPos(1) + Params.Center(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + ReachTargetPos(2) + Params.Center(2); % add y-pos

            % draw
            inFlag = InTarget(Cursor,ReachTargetPos,Params.TargetSize);            
            if inFlag, ReachCol = Params.InTargetColor;
            else, ReachCol = Params.OutTargetColor;
            end
            Screen('FillOval', Params.WPTR, ...
                cat(1,ReachCol,Params.CursorColor)', ...
                cat(1,ReachRect,CursorRect)')
            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);
            
            % start counting time if cursor is in target
            if inFlag,
                totalTime = totalTime + dt;
            else
                totalTime = 0;
            end
        end

        % end if takes too long
        if (tim - tstart) > Params.MaxReachTime,
            done = 1;
            Data.ErrorID = 3;
            Data.ErrorStr = 'ReachTarget';
            fprintf('ERROR: %s\n',Data.ErrorStr)
        end

        % end if in start target for hold time
        if totalTime > Params.TargetHoldTime,
            done = 1;
        end
    end % Reach Target Loop
end % only complete if no errors


%% Completed Trial - Give Feedback
Screen('Flip', Params.WPTR);
if Data.ErrorID==0,
    fprintf('SUCCESS\n')
    if Params.FeedbackSound,
        sound(Params.RewardSound,Params.RewardSoundFs)
    end
else
    if Params.FeedbackSound,
        sound(Params.ErrorSound,Params.ErrorSoundFs)
    end
    WaitSecs(Params.ErrorWaitTime);
end

end % RunTrial



