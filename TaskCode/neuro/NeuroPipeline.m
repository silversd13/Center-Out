function varargout = NeuroPipeline(Neuro,Data),
% function Neuro = NeuroPipeline(Neuro)
% function [Neuro,Data] = NeuroPipeline(Neuro,Data)
% Neuro processing pipeline. To change processing, edit this function.

% process neural data
Neuro = ReadBR(Neuro);
Neuro = RefNeuralData(Neuro);
Neuro = ApplyFilterBank(Neuro);
Neuro = UpdateNeuroBuf(Neuro);
tic;
Neuro = CompNeuralFeatures(Neuro);
toc
Neuro = UpdateChStats(Neuro);
varargout{1} = Neuro;

% if Data exists and is not empty, fill structure
if exist('Data','var') && ~isempty(Data),
    Data.NeuralTimeBR(1,end+1) = Neuro.TimeStamp;
    Data.NeuralSamps(1,end+1) = Neuro.NumSamps;
    Data.NeuralFeatures{end+1} = Neuro.NeuralFeatures;
    if Neuro.SaveProcessed,
        Data.ProcessedData{end+1} = Neuro.FilteredData;
    end
    varargout{2} = Data;
end

end % ProcessNeuro