function [delta_buffer, neural_features] = CompNeuralFeatures(delta_buffer, filtered_data, Params),
% [delta_buffer, neural_features] = CompNeuralFeatures(delta_buffer, filtered_data, Params)
% computes neural features
% phase in delta band + pwr in all available bands
% sets features on bad channels to 0
%
% delta_buffer - buffer of delta band filtered neural data [ samps x chans ]
% filtered_data - filtered data from last bin [ samps x chans x frqs ]
% 
% delta_buffer - adds most recent bin to delta_buffer
% neural_features - matrix of features for decoding [ features x chans ]

% allocate memory
neural_features = zeros(Params.NumFeatures,Params.NumChannels);

% update delta buffer
[samps, ~, ~] = size(filtered_data);
delta_buffer = circshift(delta_buffer,-samps);
delta_buffer((end-samps+1):end,:) = filtered_data(:,:,1);

% first compute phase for first frq band
ang = angle(hilbert(delta_buffer));
neural_features(1,:) = angle(sum(exp(1i*ang(end-samps+1:end,:))));

% compute average pwr for all frq bands in last bin
pwr = mean(filtered_data.^2, 1);

% combine feature vectors and remove singleton dimension
feature_idx = [Params.FilterBank.feature];
for i=1:Params.NumFeatures-1,
    idx = feature_idx == i;
    neural_features(i+1,:) = mean(pwr(:,:,idx),3);
end

% set bad channels to 0
neural_features(:,Params.BadChannels) = 0;

end % CompNeuralFeatures

