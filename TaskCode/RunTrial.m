function Data = RunTrial(Params,Data)
global Cursor

%% Set up trial
StartTargetPos = Params.StartTargetPosition;
ReachTargetPos = Data.TargetPosition;

% Output to Command Line
fprintf('\nTrial: %i\n',Data.Trial)
fprintf('Target: %i\n',Data.TargetAngle)

%% Go to start target
if ~Data.ErrorID,
    tstart  = GetSecs;
    Data.Events(1).Time = tstart;
    Data.Events(1).Str  = 'Start Target';

    tim  = GetSecs;
    tlast = tim;
    done = 0;
    totalTime = 0;
    inFlag = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, ExperimentPause(Params); end

        % Update Screen Every 100ms
        if (tim-tlast) > 100e-3,
            % time
            dt = tim - tlast;
            tlast = tim;
            Data.Time(end+1,1) = tim;

            % cursor
            Cursor = UpdateCursor(Params,Cursor,dt);
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.Position(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.Position(2); % add y-pos
            Data.CursorPosition(end+1,:) = Cursor.Position;

            % Display target
            TargetRect = Params.TargetRect; % centered at (0,0)
            TargetRect([1,3]) = TargetRect([1,3]) + StartTargetPos(1); % add x-pos
            TargetRect([2,4]) = TargetRect([2,4]) + StartTargetPos(2); % add y-pos

            % draw
            inFlag = InTarget(Cursor,TargetRect,Params.TargetSize);
            Screen('FillOval', Params.WPTR, Params.CursorColor, CursorRect);
            if inFlag,Screen('FillOval', Params.WPTR, Params.InTargetColor, TargetRect);
            else Screen('FillOval', Params.WPTR, Params.OutTargetColor, TargetRect);
            end
            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);
        end

        % start counting time if cursor is in target
        if inFlag,
            totalTime = totalTime + dt;
        else
            totalTime = 0;
        end

        % end if takes too long
        if (tim - tstart) > Params.MaxStartTime,
            done = 1;
            Data.ErrorID = 1;
            Data.ErrorStr = 'StartTarget';
            fprintf('ERROR: %s',Data.ErrorStr)
        end

        % end if in start target for hold time
        if totalTime > Params.TargetHoldTime,
            done = 1;
        end
    end % Cue Loop
    % Clear Stimulus
    Screen('Flip', Params.WPTR);
end % only complete if no errors

%% Go to reach target
if ~Data.ErrorID,
    tstart  = GetSecs;
    Data.Events(2).Time = tstart;
    Data.Events(2).Str  = 'Reach Target';

    tim  = GetSecs;
    tlast = tim;
    done = 0;
    totalTime = 0;
    inFlag = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, ExperimentPause(Params); end

        % Update Screen Every 100ms
        if (tim-tlast) > 100e-3,
            % time
            dt = tim - tlast;
            tlast = tim;
            Data.Time(end+1,1) = tim;

            % cursor
            Cursor = UpdateCursor(Params,Cursor,dt);
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.Position(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.Position(2); % add y-pos
            Data.CursorPosition(end+1,:) = Cursor.Position;

            % Display target
            TargetRect = Params.TargetRect; % centered at (0,0)
            TargetRect([1,3]) = TargetRect([1,3]) + ReachTargetPos(1); % add x-pos
            TargetRect([2,4]) = TargetRect([2,4]) + ReachTargetPos(2); % add y-pos

            % draw
            inFlag = InTarget(Cursor,TargetRect,Params.TargetSize);
            Screen('FillOval', Params.WPTR, Params.CursorColor, CursorRect);
            if inFlag,Screen('FillOval', Params.WPTR, Params.InTargetColor, TargetRect);
            else Screen('FillOval', Params.WPTR, Params.OutTargetColor, TargetRect);
            end
            Screen('DrawingFinished', Params.WPTR);
            Screen('Flip', Params.WPTR);
        end

        % start counting time if cursor is in target
        if inFlag,
            totalTime = totalTime + dt;
        else
            totalTime = 0;
        end

        % end if takes too long
        if (tim - tstart) > Params.MaxReachTime,
            done = 1;
            Data.ErrorID = 2;
            Data.ErrorStr = 'ReachTarget';
            fprintf('ERROR: %s',Data.ErrorStr)
        end

        % end if in start target for hold time
        if totalTime > Params.TargetHoldTime,
            done = 1;
        end
    end % Cue Loop
    % Clear Stimulus
    Screen('Flip', Params.WPTR);
end % only complete if no errors


%% Completed Trial - Give Feedback
if Data.ErrorID==0,
    fprintf('SUCCESS\n')
    if Params.FeedbackSound,
        sound(Params.RewardSound)
    end
else
    Screen('Flip', Params.WPTR);
    if Params.FeedbackSound,
        sound(Params.ErrorSound)
    end
    WaitSecs(Params.ErrorWaitTime);
    Cursor = [];
end

WaitSecs(Params.InterTrialInterval);





