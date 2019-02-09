function Data = ExperimentPause(Params,Data)
% Display text then wait for subject to resume experiment

% Pause Screen
tex = 'Paused... Press ''p'' to continue, ''escape'' to quit, or ''d'' to debug';
DrawFormattedText(Params.WPTR, tex,'center','center',255);
Screen('Flip', Params.WPTR);

% add event to data structure
Data.Events(end+1).Time = GetSecs;
Data.Events(end).Str  = 'Pause';

KbCheck;
WaitSecs(.1);
while 1, % pause until subject presses p again or quits
    [~, ~, keyCode, ~] = KbCheck;
    if keyCode(KbName('p'))==1,
        keyCode(KbName('p'))=0; % set to 0 to avoid multiple pauses in a row
        fprintf('\b') % remove input keys
        break;
    end
    if keyCode(KbName('escape'))==1 || keyCode(KbName('q'))==1,
        ExperimentStop(1); % quit experiment
    end
    if keyCode(KbName('d'))==1,
        keyboard; % quit experiment
    end
end

Screen('Flip', Params.WPTR);
WaitSecs(.1);

end % ExperimentPause