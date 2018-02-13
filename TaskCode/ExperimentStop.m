function ExperimentStop(Params)
% Close Screen, Combine individual trials into datafile
Screen('CloseAll');

% %% Save All Data
i = 1;
while exist(fullfile(Params.datadir,sprintf('Data%04i.mat',i)),'file')
    load(fullfile(Params.datadir,sprintf('Data%04i.mat',i)))
    DATA(i) = TrialData;
    i = i + 1;
end
clear TrialData
TrialData = DATA;
save(fullfile(Params.datadir,sprintf('DATA.mat')),'TrialData');

%% quit
keyboard;

end % ExperimentStop
