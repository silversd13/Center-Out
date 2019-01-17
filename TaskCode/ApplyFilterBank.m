function [filtered_data, Params] = ApplyFilterBank(neural_data,Params)
% [filtered_data, Params] = ApplyFilterBank(neural_data,Params)
% neural_data - everything in buffer [ samples x channels ]
% filtered_data - [ samples x channels x filters ]
% Params - updates filter bank states

% allocate memory [ samples x channels x filters ]
[samps, chans] = size(neural_data);
filtered_data = zeros(samps,chans,length(Params.FilterBank));

% apply each filters and track filter state
for i=1:length(Params.FilterBank),
    [filtered_data(1:samps,1:chans,i), Params.FilterBank(i).state] = ...
        filter(...
        Params.FilterBank(i).b, ...
        Params.FilterBank(i).a, ...
        neural_data, ...
        Params.FilterBank(i).state);
end

end % ApplyFilterBank

