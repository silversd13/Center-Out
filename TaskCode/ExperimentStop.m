function ExperimentStop(fromPause)
if ~exist('fromPause', 'var'), fromPause = 0; end

% Close Screen
Screen('CloseAll');

% Close Serial Port
if Params.SerialSync,
    fclose(Params.SerialPtr);
end

% quit
if fromPause, keyboard; end

end % ExperimentStop
