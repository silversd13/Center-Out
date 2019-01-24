function [Data, delta_buffer] = RunTrial(Params,Data,delta_buffer,BaseNeuralFeatures)
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

% Output to Command Line
fprintf('\nTrial: %i\n',Data.Trial)
fprintf('Target: %i\n',Data.TargetAngle)

%% Begin Recording Neural Data
if Params.BLACKROCK,
    [~, neural_data] = ReadBR(Params);
    [filtered_data, Params] = ApplyFilterBank(neural_data,Params);
    [delta_buffer, ~] = CompNeuralFeatures(delta_buffer, filtered_data, Params);
end

%% Inter Trial Interval
if ~Data.ErrorID,
    tstart  = GetSecs;
    Data.Events(1).Time = tstart;
    Data.Events(1).Str  = 'Inter Trial Interval';

    tim  = GetSecs;
    tlast = tim;
    done = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, ExperimentPause(Params); end

        % Update Screen Every Xsec
        if (tim-tlast) > 1/Params.RefreshRate,
            % time
            dt = tim - tlast;
            tlast = tim;
            Data.Time(end+1,1) = tim;
            
            % grab and process neural data
            if Params.BLACKROCK,
                [timestamp, neural_data, num_samps] = ReadBR(Params);
                [filtered_data, Params] = ApplyFilterBank(neural_data,Params);
                [delta_buffer, neural_features] = CompNeuralFeatures(delta_buffer, filtered_data, Params);
                [neural_features] = ZScoreNeuralFeatures(neural_features, BaseNeuralFeatures);
                Data.NeuralTime(end+1,1) = timestamp;
                Data.NeuralSamps(end+1,1) = num_samps;
                Data.NeuralFeatures(:,:,end+1) = neural_features;
                Data.ProcessedData{end+1} = filtered_data;
            end
            
            % cursor
            if ~Params.CenterReset, Cursor = UpdateCursor(Params,Cursor,dt);
            else, Cursor = UpdateCursor(Params,Cursor,dt,StartTargetPos);
            end
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.Position(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.Position(2); % add y-pos
            Data.CursorPosition(end+1,:) = Cursor.Position;

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
if ~Data.ErrorID,
    tstart  = GetSecs;
    Data.Events(2).Time = tstart;
    Data.Events(2).Str  = 'Start Target';

    tim  = GetSecs;
    tlast = tim;
    if ~Params.CenterReset, done = 0;
    else, done = 1; % skip reach to center
    end
    totalTime = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, ExperimentPause(Params); end

        % Update Screen Every Xsec
        if (tim-tlast) > 1/Params.RefreshRate,
            % time
            dt = tim - tlast;
            tlast = tim;
            Data.Time(end+1,1) = tim;
            
            % grab and process neural data
            if Params.BLACKROCK,
                [timestamp, neural_data, num_samps] = ReadBR(Params);
                [filtered_data, Params] = ApplyFilterBank(neural_data,Params);
                [delta_buffer, neural_features] = CompNeuralFeatures(delta_buffer, filtered_data, Params);
                [neural_features] = ZScoreNeuralFeatures(neural_features, BaseNeuralFeatures);
                Data.NeuralTime(end+1,1) = timestamp;
                Data.NeuralSamps(end+1,1) = num_samps;
                Data.NeuralFeatures(:,:,end+1) = neural_features;
                Data.ProcessedData{end+1} = filtered_data;
            end
            
            % cursor
            Cursor = UpdateCursor(Params,Cursor,dt);
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.Position(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.Position(2); % add y-pos
            Data.CursorPosition(end+1,:) = Cursor.Position;

            % start target
            StartRect = Params.TargetRect; % centered at (0,0)
            StartRect([1,3]) = StartRect([1,3]) + StartTargetPos(1); % add x-pos
            StartRect([2,4]) = StartRect([2,4]) + StartTargetPos(2); % add y-pos
            inFlag = InTarget(Cursor,StartRect,Params.TargetSize);
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
end % only complete if no errors

%% Instructed Delay
if ~Data.ErrorID,
    tstart  = GetSecs;
    Data.Events(3).Time = tstart;
    Data.Events(3).Str  = 'Instructed Delay';
    
    tim  = GetSecs;
    tlast = tim;
    done = 0;
    totalTime = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, ExperimentPause(Params); end
        
        % Update Screen
        if (tim-tlast) > 1/Params.RefreshRate,
            % time
            dt = tim - tlast;
            tlast = tim;
            Data.Time(end+1,1) = tim;

            % grab and process neural data
            if Params.BLACKROCK,
                [timestamp, neural_data, num_samps] = ReadBR(Params);
                [filtered_data, Params] = ApplyFilterBank(neural_data,Params);
                [delta_buffer, neural_features] = CompNeuralFeatures(delta_buffer, filtered_data, Params);
                [neural_features] = ZScoreNeuralFeatures(neural_features, BaseNeuralFeatures);
                Data.NeuralTime(end+1,1) = timestamp;
                Data.NeuralSamps(end+1,1) = num_samps;
                Data.NeuralFeatures(:,:,end+1) = neural_features;
                Data.ProcessedData{end+1} = filtered_data;
            end
            
            % cursor
            Cursor = UpdateCursor(Params,Cursor,dt);
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.Position(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.Position(2); % add y-pos
            Data.CursorPosition(end+1,:) = Cursor.Position;
            
            % start target
            StartRect = Params.TargetRect; % centered at (0,0)
            StartRect([1,3]) = StartRect([1,3]) + StartTargetPos(1); % add x-pos
            StartRect([2,4]) = StartRect([2,4]) + StartTargetPos(2); % add y-pos
            inFlag = InTarget(Cursor,StartRect,Params.TargetSize);
            if inFlag, StartCol = Params.InTargetColor;
            else, StartCol = Params.OutTargetColor;
            end
            
            % reach target
            ReachRect = Params.TargetRect; % centered at (0,0)
            ReachRect([1,3]) = ReachRect([1,3]) + ReachTargetPos(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + ReachTargetPos(2); % add y-pos
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
    Data.Events(4).Time = tstart;
    Data.Events(4).Str  = 'Reach Target';

    tim  = GetSecs;
    tlast = tim;
    done = 0;
    totalTime = 0;
    while ~done,
        % Update Time & Position
        tim = GetSecs;

        % for pausing and quitting expt
        if CheckPause, ExperimentPause(Params); end

        % Update Screen
        if (tim-tlast) > 1/Params.RefreshRate,
            % time
            dt = tim - tlast;
            tlast = tim;
            Data.Time(end+1,1) = tim;

            % grab and process neural data
            if Params.BLACKROCK,
                [timestamp, neural_data, num_samps] = ReadBR(Params);
                [filtered_data, Params] = ApplyFilterBank(neural_data,Params);
                [delta_buffer, neural_features] = CompNeuralFeatures(delta_buffer, filtered_data, Params);
                [neural_features] = ZScoreNeuralFeatures(neural_features, BaseNeuralFeatures);
                Data.NeuralTime(end+1,1) = timestamp;
                Data.NeuralSamps(end+1,1) = num_samps;
                Data.NeuralFeatures(:,:,end+1) = neural_features;
                Data.ProcessedData{end+1} = filtered_data;
            end
            
            % cursor
            Cursor = UpdateCursor(Params,Cursor,dt);
            CursorRect = Params.CursorRect;
            CursorRect([1,3]) = CursorRect([1,3]) + Cursor.Position(1); % add x-pos
            CursorRect([2,4]) = CursorRect([2,4]) + Cursor.Position(2); % add y-pos
            Data.CursorPosition(end+1,:) = Cursor.Position;

            % reach target
            ReachRect = Params.TargetRect; % centered at (0,0)
            ReachRect([1,3]) = ReachRect([1,3]) + ReachTargetPos(1); % add x-pos
            ReachRect([2,4]) = ReachRect([2,4]) + ReachTargetPos(2); % add y-pos

            % draw
            inFlag = InTarget(Cursor,ReachRect,Params.TargetSize);            
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
        sound(Params.RewardSound)
    end
else
    if Params.FeedbackSound,
        sound(Params.ErrorSound)
    end
    WaitSecs(Params.ErrorWaitTime);
    Cursor = [];
end

end % RunTrial



