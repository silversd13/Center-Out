function RunLoop(Params)
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
    'ErrorID',NaN,...
    'ErrorStr','',...
    'Events',[]...
    );

%%  Loop Through Blocks of Trials
Trial = 0;
Cursor = [];
for Block=1:Params.NumBlocks, % Block Loop
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
        TrialData = RunTrial(Params,TrialData);
        TrialData.TrialEndTime    = GetSecs;
                
        % Save Data from Single Trial
        save(fullfile(Params.datadir,sprintf('Data%04i.mat',Trial)),'TrialData');
        
    end % Trial Loop
    
    % Give Feedback for Block
    WaitSecs(Params.InterBlockInterval);
    
end % Block Loop

end



