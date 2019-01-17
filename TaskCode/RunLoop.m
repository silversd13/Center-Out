function RunLoop(Params, BaseNeuralFeatures)
% Defines the structure of collected data on each trial
% Loops through blocks and trials within blocks
global Cursor

%% Start Experiment
DataFields = struct(...
    'Block',NaN,...
    'Trial',NaN,...
    'TrialStartTime',NaN,...
    'TrialEndTime',NaN,...
    'TargetID',NaN,...
    'TargetAngle',NaN,...
    'TargetPosition',NaN,...
    'Time',[],...
    'CursorPosition',[],...
    'NeuralTime',[],...
    'NeuralSamps',[],...
    'NeuralFeatures',zeros(Params.NumFeatures,Params.NumChannels,0),...
    'ProcessedData',{{}},...
    'ErrorID',0,...
    'ErrorStr','',...
    'Events',[]...
    );

%%  Loop Through Blocks of Trials
Trial = 0;
delta_buffer = zeros(Params.BufferSamps,Params.NumChannels);
for Block=1:Params.NumBlocks, % Block Loop
    Cursor = [];
    % random order of reach targets for each block
    TargetOrder = randperm(Params.NumTrialsPerBlock);

    for TrialPerBlock=1:Params.NumTrialsPerBlock, % Trial Loop
        Trial = Trial + 1;
        TrialIdx = TargetOrder(TrialPerBlock);
        
        % set up trial
        TrialData = DataFields;
        TrialData.Block = Block;
        TrialData.Trial = Trial;
        TrialData.TargetID = TrialIdx;
        TrialData.TargetAngle = Params.ReachTargetAngles(TrialIdx);
        TrialData.TargetPosition = Params.ReachTargetPositions(TrialIdx,:);
        
        % Run Trial
        TrialData.TrialStartTime  = GetSecs;
        TrialData = RunTrial(Params,TrialData,delta_buffer,BaseNeuralFeatures);
        TrialData.TrialEndTime    = GetSecs;
                
        % Save Data from Single Trial
        save(fullfile(Params.datadir,sprintf('Data%04i.mat',Trial)),'TrialData');
        
    end % Trial Loop
    
    % Give Feedback for Block
    WaitSecs(Params.InterBlockInterval);
    
end % Block Loop

end % RunLoop



