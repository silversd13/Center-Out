%% check if kalman weights are converging
clear, clc, close all

% load data
datadir = uigetdir();
datafiles = dir(fullfile(datadir,'Data*.mat'));
C = [];
alpha = [];
lambda = [];
for i=1:length(datafiles),
    % load data, grab neural features
    load(fullfile(datadir,datafiles(i).name)) %#ok<LOAD>
    C = cat(3,C,TrialData.KalmanFilter.C);
    alpha = cat(2,alpha,TrialData.CursorAssist(1));
    lambda = cat(2,lambda,TrialData.KalmanFilter.CLDA.Lambda);
end

%%

figure;
subplot(411);
plot(1:120,alpha)
ylabel('cursor assist')
title('convergence of KF params')

subplot(412)
plot(squeeze(C(:,3,:))')
ylabel('KF.C (xvel)')

subplot(413)
plot(squeeze(C(:,4,:))')
ylabel('KF.C (yvel)')

subplot(414)
plot(squeeze(C(:,5,:))')
ylabel('KF.C (const)')
xlabel('trials')

%%

figure;
subplot(411);
plot(1:120,alpha)
ylabel('cursor assist')
title('convergence of KF params')

subplot(412)
plot(abs(squeeze(C(:,3,:))'))
ylabel('KF.C (xvel)')

subplot(413)
plot(abs(squeeze(C(:,4,:))'))
ylabel('KF.C (yvel)')

subplot(414)
plot(abs(squeeze(C(:,5,:))'))
ylabel('KF.C (const)')
xlabel('trials')


%%

figure;
subplot(411);
plot(1:120,alpha)
ylabel('cursor assist')
title('convergence of KF params')

subplot(412)
plot(abs(diff(squeeze(C(:,3,:))')))
ylabel('KF.C (xvel)')

subplot(413)
plot(abs(diff(squeeze(C(:,4,:))')))
ylabel('KF.C (yvel)')

subplot(414)
plot(abs(diff(squeeze(C(:,5,:))')))
ylabel('KF.C (const)')
xlabel('trials')




