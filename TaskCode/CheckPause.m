function out = CheckPause

[~, ~, keyCode, ~] = KbCheck;
if keyCode(KbName('p'))==1, out = true; 
else out = false;
end
