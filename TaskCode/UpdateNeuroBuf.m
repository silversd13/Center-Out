function Neuro = UpdateNeuroBuf(Neuro)
% Neuro = UpdateNeuroBuf(Neuro)
% efficiently replaces old data in circular buffer with new filtered
% signals

% update filter buffer
[samps, ~, ~] = size(Neuro.FilteredData);
Neuro.FilterDataBuf = circshift(Neuro.FilterDataBuf,-samps);
Neuro.FilterDataBuf((end-samps+1):end,:) = Neuro.FilteredData;

end % UpdateNeuroBuf