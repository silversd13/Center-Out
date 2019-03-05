function ExperimentStop(fromPause)
if ~exist('fromPause', 'var'), fromPause = 0; end

% Close Screen
Screen('CloseAll');

% Close Serial Port
fclose('all');

% quit
if fromPause, keyboard; end

end % ExperimentStop
