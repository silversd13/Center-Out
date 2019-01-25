function Params = UpdateNeuralStats(lfp,Params)
% function Params = UpdateNeuralStats(lfp,Params)
% update estimate of mean and variance for each channel using Welford Alg
% lfp - [ samples x channels ]
% Params - contains NeuralStats structure, which is updated

w                        = size(lfp,1);
Params.NeuralStats.wSum1 = Params.NeuralStats.wSum1 + w;
Params.NeuralStats.wSum2 = Params.NeuralStats.wSum2 + w*w;
meanOld                  = Params.NeuralStats.mean;
Params.NeuralStats.mean  = meanOld + (w / Params.NeuralStats.wSum1) * mean(lfp - repmat(meanOld,w,1));
Params.NeuralStats.S     = Params.NeuralStats.S + w*mean( (lfp - repmat(meanOld,w,1)).*(lfp - repmat(Params.NeuralStats.mean,w,1)) );
Params.NeuralStats.var   = Params.NeuralStats.S / (Params.NeuralStats.wSum1 - 1);

end % UpdateNeuralStats