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
        Cursor.DeltaAssistance = 0;
        mkdir(fullfile(Params.Datadir,'Imagined'));
        
        % output to screen
        fprintf('\n\nImagined Movements:\n')
        fprintf('  %i Blocks (%i Total Trials)\n',...
            Params.NumImaginedBlocks,...
            Params.NumImaginedBlocks*Params.NumTrialsPerBlock)
        fprintf('  Saving data to %s\n\n',fullfile(Params.Datadir,'Imagined'))
        
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
                
                % Fit Kalman Filter based on imagined movements
                Neuro.KF = FitKF(fullfile(Params.Datadir,'Imagined'),0);
        end
        
        InstructionScreen(Params,Instructions);
        Cursor.Assistance = Params.Assistance;
        Cursor.DeltaAssistance = ... % linearly decrease assistance
            Cursor.Assistance...
            /(Params.NumAdaptBlocks...
            *Params.NumTrialsPerBlock...
            *Params.UpdateRate...
            *4); % sec/trial
%         Cursor.DeltaAssistance = 0; % no change in assistance
        mkdir(fullfile(Params.Datadir,'BCI_CLDA'));
        
        % output to screen
        fprintf('\n\nAdaptive Control:\n')
        fprintf('  %i Blocks (%i Total Trials)\n',...
            Params.NumAdaptBlocks,...
            Params.NumAdaptBlocks*Params.NumTrialsPerBlock)
        fprintf('  Assistance: %.2f\n', Cursor.Assistance)
        fprintf('  Change in Assistance: %.2f\n', Cursor.DeltaAssistance)
        fprintf('  Saving data to %s\n\n',fullfile(Params.Datadir,'BCI_CLDA'))
        
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
                
                % reFit Kalman Filter based on intended kinematics during
                % adaptive block
                if Neuro.CLDA.Type==1,
                    Neuro.KF = FitKF(fullfile(Params.Datadir,'BCI_CLDA'),1);
                end
        end
        
        InstructionScreen(Params,Instructions);
        Cursor.Assistance = 0;
        Cursor.DeltaAssistance = 0;
        mkdir(fullfile(Params.Datadir,'BCI_Fixed'));
        
        % output to screen
        fprintf('\n\nFixed Control:\n')
        fprintf('  %i Blocks (%i Total Trials)\n',...
            Params.NumFixedBlocks,...
            Params.NumFixedBlocks*Params.NumTrialsPerBlock)
        fprintf('  Saving data to %s\n\n',fullfile(Params.Datadir,'BCI_Fixed'))
        
        Neuro = RunLoop(Params,Neuro,TaskFlag,fullfile(Params.Datadir,'BCI_Fixed'));
        
end

end % RunTask
