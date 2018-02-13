function out = CheckPause

[~, ~, keyCode, ~] = KbCheck;
if keyCode(KbName('p'))==1,
    out = true;
    fprintf('\b') % remove input keys from command window
else,
    out = false;
end
