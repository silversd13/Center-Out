function Neuro = RunTask(Params,Neuro,TaskFlag)
% Explains the task to the subject, and serves as a reminder for pausing
% and quitting the experiment (w/o killing matlab or something)

global Cursor 

switch TaskFlag,
    case 1, % Imagined Movements
        Instructions = [...
            '\n\nImagined Cursor Control\n\n'...
            'Imagine moving a mouse with your hand to move the\n'...
            'into the targets.\n'...
            '\nAt any time, you can press ''p'' to briefly pause the task.'...
            '\n\nPress the ''Space Bar'' to begin!' ];
        
        InstructionScreen(Params,Instructions);
        Cursor.Assistance = Params.Assistance;
        mkdir(fullfile(Params.Datadir,'Imagined'));
        Neuro = RunLoop(Params,Neuro,TaskFlag,fullfile(Params.Datadir,'Imagined'));
        
    case 2, % Control Mode with Assist & CLDA
        switch Params.ControlMode,
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
            case 3, % Kalman Filter Velocity Decoder
                Instructions = [...
                    '\n\nKalman Brain Control\n\n'...
                    '\nAt any time, you can press ''p'' to briefly pause the task.'...
                    '\n\nPress the ''Space Bar'' to begin!' ];
                
                % Initialize Kalman Filter
                Neuro.KF = InitializeKF(fullfile(Params.Datadir,'Imagined'));
        end
        
        InstructionScreen(Params,Instructions);
        Cursor.Assistance = Params.Assistance;
        mkdir(fullfile(Params.Datadir,'BCI_CLDA'));
        Neuro = RunLoop(Params,Neuro,TaskFlag,fullfile(Params.Datadir,'BCI_CLDA'));
        
    case 3, % Control Mode without Assist and fixed
        switch Params.ControlMode,
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
            case 3, % Kalman Filter Velocity Decoder
                Instructions = [...
                    '\n\nKalman Brain Control\n\n'...
                    '\nAt any time, you can press ''p'' to briefly pause the task.'...
                    '\n\nPress the ''Space Bar'' to begin!' ];
                
        end
        
        InstructionScreen(Params,Instructions);
        Cursor.Assistance = 0;
        mkdir(fullfile(Params.Datadir,'BCI_Fixed'));
        Neuro = RunLoop(Params,Neuro,TaskFlag,fullfile(Params.Datadir,'BCI_Fixed'));
        
end



end % RunTask