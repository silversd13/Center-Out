function RunTask(Params)

switch Params.ControlMode 
    case 1,
        % Mouse
        Params = GetParams(Params);
        Instructions = [...
        '\n\nMouse Control\n\n'...
        '\nAt any time, you can press ''p'' to briefly pause the task.'...
        '\n\nPress the ''Space Bar'' to begin!' ];
        InstructionScreen(Params,Instructions);
        RunLoop(Params);

    case 2, % Adaptive decode
    case 3, % Open-Loop decode
    
end

% Pause and Finish!
WaitSecs(.5)
ExperimentStop(Params);
