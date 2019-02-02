function zneural_data = ZscoreNeuralData(neural_data,Params),
% function zneural_data = ZscoreNeuralData(neural_data,Params)
% zscores neural data based on stored Parameters
% 
% neural_data - [ samples x channels ]
% Params

mu = Params.NeuralStats.mean;
sigma = sqrt(Params.NeuralStats.var);
sigma(sigma==0) = 1;

zneural_data = bsxfun(@minus,neural_data,mu);
zneural_data = bsxfun(@rdivide,zneural_data,sigma);

end % ZscoreNeuralData