function ref_data = RefNeuralData(neural_data,Params),
% function ref_data = RefNeuralData(neural_data,Params)
% references neural data based on stored Parameters
% 
% neural_data - [ samples x channels ]
% Params

switch Params.ReferenceMode,
    case 0, % no reference
        ref_data = neural_data;
    case 1, % common mean
        channels = setdiff(1:Params.NumChannels,Params.BadChannels);
        mu = mean(neural_data(:,channels),2);
        ref_data = neural_data - mu;
    case 2, % common median
        channels = setdiff(1:Params.NumChannels,Params.BadChannels);
        mu = median(neural_data(:,channels),2);
        ref_data = neural_data - mu;
end % reference mode

end % RefNeuralData