function out = CheckPause
% function to check if the key 'p' was pressed,
% if so, pause the experiment
[~, ~, keyCode, ~] = KbCheck;
if keyCode(KbName('p'))==1,
    out = true;
    fprintf('\b') % remove input keys from command window
else,
    out = false;
end

end % CheckPause