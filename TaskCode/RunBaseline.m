function [mu, sigma] = RunBaseline(Params)
% [mu, sigma] = RunBaseline(Params)
% Baseline period - grab neural features to get baseline for z-scoring
% 
% mu - avg neural features [ num_features x num_channels ]
% sigma - std neural features [ num_features x num_channels ]

fprintf('Collecting Baseline\n')

% initialize
NeuralFeatures = zeros(Params.NumFeatures,Params.NumChannels,0);
delta_buffer = zeros(Params.BufferSamps,Params.NumChannels);

tstart  = GetSecs;
tlast = tstart;
done = 0;
while ~done,
    % Update Time & Position
    tim = GetSecs;
    
    % for pausing and quitting expt
    if CheckPause, ExperimentPause(Params); end
    
    % Grab data every Xsecs
    if (tim-tlast) > 1/Params.RefreshRate,
        % time
        tlast = tim;
        
        % grab and process neural data
        if Params.BLACKROCK,
            [~, neural_data, ~] = ReadBR(Params);
            [filtered_data, Params] = ApplyFilterBank(neural_data,Params);
            [delta_buffer, neural_features] = CompNeuralFeatures(delta_buffer, filtered_data, Params);
            NeuralFeatures(:,:,end+1) = neural_features;
        end
        
        % update screen with progress
        tex = sprintf('Computing Baseline: %.1f%% ', 100*(tim-tstart)/Params.BaselineTime);
        DrawFormattedText(Params.WPTR, tex,'center','center',255);
        Screen('Flip', Params.WPTR);
    end
    
    % end if takes too long
    if (tim - tstart) > Params.BaselineTime,
        done = 1;
    end
end

% compute mean and stdev
mu = mean(NeuralFeatures,3);
sigma = std(NeuralFeatures,[],3);

end % RunBaseline