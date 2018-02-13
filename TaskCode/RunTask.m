function RunTask(Params)
switch Params.ControlMode 
    case 1, % Mouse Position
        Instructions = [...
        '\n\nMouse Position Control\n\n'...
        '\nAt any time, you can press ''p'' to briefly pause the task.'...
        '\n\nPress the ''Space Bar'' to begin!' ];
    case 2, % Mouse Velocity
        Instructions = [...
        '\n\nMouse Velocity Control\n\n'...
        '\nAt any time, you can press ''p'' to briefly pause the task.'...
        '\n\nPress the ''Space Bar'' to begin!' ];
    case 3, % Adaptive decode
    case 4, % Open-Loop decode
    
end

Params = GetParams(Params);
InstructionScreen(Params,Instructions);
RunLoop(Params);

% Pause and Finish!
WaitSecs(.5)
ExperimentStop(Params);
