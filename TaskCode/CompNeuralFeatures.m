function [delta_buffer, neural_features] = CompNeuralFeatures(delta_buffer, filtered_data, bad_channels),
% [delta_buffer, neural_features] = CompNeuralFeatures(delta_buffer, filtered_data, bad_channels)
% computes neural features
% phase in delta band + pwr in all available bands
% sets features on bad channels to 0
%
% delta_buffer - buffer of delta band filtered neural data [ samps x chans ]
% filtered_data - filtered data from last bin [ samps x chans x frqs ]
% bad_channels - vector of bad channels, default=[]
% 
% delta_buffer - adds most recent bin to delta_buffer
% neural_features - matrix of features for decoding [ features x chans ]

% deal with inputs
if ~exist('bad_channels','var'), bad_channels = []; end

% update delta buffer
[samps, ~, bands] = size(filtered_data);
delta_buffer = circshift(delta_buffer,-samps);
delta_buffer((end-samps+1):end,:) = filtered_data(:,:,1);

% first compute phase for first frq band
ang = angle(hilbert(delta_buffer));
phi = angle(sum(exp(1i*ang(end-samps+1:end,:))));

% compute average pwr for all frq bands in last bin
for band=1:bands,
    pwr = mean(filtered_data.^2, 1);
end

% combine feature vectors and remove singleton dimension
neural_features = squeeze(cat(3,phi,pwr))';

% set bad channels to 0
neural_features(:,bad_channels) = 0;

end % CompNeuralFeatures

