%% check if ch_stats are converging
clear, clc, close all

% load data
datadir = uigetdir();
datafiles = dir(fullfile(datadir,'Data*.mat'));

mu = [];
sigma = [];
mu1 = [];
sigma1 = [];

for i=1:length(datafiles),
    % load data, grab neural features
    load(fullfile(datadir,datafiles(i).name)) %#ok<LOAD>
    mu = cat(1,mu,TrialData.ChStats.mean);
    sigma = cat(1,sigma,sqrt(TrialData.ChStats.var));
    X = cat(1,TrialData.BroadbandData{:});
    mu1 = cat(1,mu1,mean(X));
    sigma1 = cat(1,sigma1,std(X));
end

%%
figure;

subplot(211)
plot(1:120,mu(:,5)')
ylabel('mean')
title('convergence of recorded ch stats')

subplot(212)
plot(1:120,sigma(:,5)')
ylabel('standard dev')
xlabel('trials')

%%
figure;

subplot(211)
plot(1:120,mu1(:,5)')
ylabel('mean')
title('convergence of ch stats')

subplot(212)
plot(1:120,sigma1(:,5)')
ylabel('standard dev')
xlabel('trials')

