function ExperimentPause(Params)
% Display text then wait for subject to resume experiment

% Pause Screen
tex = 'Paused... Press ''p'' to continue or ''escape'' to quit';
DrawFormattedText(Params.WPTR, tex,'center','center',255);
Screen('Flip', Params.WPTR);

[~, ~, keyCode, ~] = KbCheck;
WaitSecs(.1);
while (1) % pause until subject presses p again
    [~, ~, keyCode, ~] = KbCheck;
    if keyCode(KbName('p'))==1,
        keyCode(KbName('p'))=0;
        fprintf('\b') % remove input keys
        break;
    end
    if keyCode(KbName('escape'))==1,
        ExperimentStop(Params);
        break;
    end
end

Screen('Flip', Params.WPTR);
WaitSecs(.1);