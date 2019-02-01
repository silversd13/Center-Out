function Neuro = RunLoop(Params,Neuro,TaskFlag,datadir)
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
    'CursorAssist',[],...
    'CursorState',[],...
    'NeuralTime',[],...
    'NeuralTimeBR',[],...
    'NeuralSamps',[],...
    'NeuralFeatures',zeros(Params.NumFeatures,Params.NumChannels,0),...
    'ProcessedData',{{}},...
    'ErrorID',0,...
    'ErrorStr','',...
    'Events',[]...
    );

switch TaskFlag,
    case 1, NumBlocks = Params.NumImaginedBlocks;
    case 2, NumBlocks = Params.NumAdaptBlocks;
    case 3, NumBlocks = Params.NumFixedBlocks;
end

%%  Loop Through Blocks of Trials
Trial = 0;
for Block=1:NumBlocks, % Block Loop

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
        [TrialData,Neuro] = RunTrial(TrialData,Params,Neuro,TaskFlag);
        TrialData.TrialEndTime    = GetSecs;
                
        % Save Data from Single Trial
        save(fullfile(datadir,sprintf('Data%04i.mat',Trial)),'TrialData');
        
    end % Trial Loop
    
    % Give Feedback for Block
    WaitSecs(Params.InterBlockInterval);
    
end % Block Loop

end % RunLoop



