function [timestamp, neural_data, num_samps] = ReadBR(Params)
% function [timestamp, neural_data, num_samps] = ReadBR(Params)
% reads in all data in the data buffer. intended to be run at each
% timestep. if data exceeds limit in Params, data is truncated.
% 
% timestamp - returns timestamp of data collection
% neural_data - returns matrix of neural data [ samples x channels ]
% num_samps - number of samples of neural data per channel

% The data looks like { [] [] [ samples x channels ] }
% read data from blackrock
[timestamp, X] = cbmex('trialdata',1); % read buffer
try
neural_data = double(horzcat(X{1:Params.NumChannels,3}));
catch
end

% limit to buffer size
num_samps = size(neural_data,1);
if num_samps > Params.BufferSamps,
    neural_data = neural_data(1:Params.BufferSamps,:);
end

end % ReadBR

