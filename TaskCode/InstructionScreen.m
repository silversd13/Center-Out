function InstructionScreen(Params,tex)
% Display text then wait for subject to resume experiment

% Pause Screen
DrawFormattedText(Params.WPTR, tex,'center','center',255);
Screen('Flip', Params.WPTR);

WaitSecs(.1);

while (1) % pause until subject presses spacebar to continue
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    if keyCode(KbName('space'))==1,
        keyCode(KbName('space'))=0;
        fprintf('\b') % remove input keys
        break;
    end
end

Screen('Flip', Params.WPTR);
WaitSecs(.1);

end % InstructionScreen