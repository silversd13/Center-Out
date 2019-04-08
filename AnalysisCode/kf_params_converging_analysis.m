%% check if kalman weights are converging
clear, clc, close all

% load data
datadir = uigetdir();
datafiles = dir(fullfile(datadir,'Data*.mat'));
C = [];
Q = [];
alpha = [];
lambda = [];
for i=1:length(datafiles),
    % load data, grab neural features
    load(fullfile(datadir,datafiles(i).name)) %#ok<LOAD>
    C = cat(3,C,TrialData.KalmanFilter.C);
    Q = cat(3,Q,TrialData.KalmanFilter.Q);
    alpha = cat(2,alpha,TrialData.CursorAssist(1));
    lambda = cat(2,lambda,TrialData.KalmanFilter.Lambda);
end

%%

figure;
subplot(511);
plot(1:length(alpha),alpha)
ylabel('cursor assist')
title('convergence of KF params')

subplot(512)
plot(1:length(lambda),lambda)
ylabel('RML Lambda')


subplot(513)
plot(squeeze(C(:,3,:))')
ylabel('KF.C (xvel)')

subplot(514)
plot(squeeze(C(:,4,:))')
ylabel('KF.C (yvel)')

subplot(515)
plot(squeeze(C(:,5,:))')
ylabel('KF.C (const)')
xlabel('trials')

%%

figure;
subplot(411);
plot(1:length(alpha),alpha)
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
plot(1:length(alpha),alpha)
ylabel('cursor assist')
title('convergence of KF params')

subplot(412)
plot((diff(squeeze(C(:,3,:))')))
ylabel('KF.C (xvel)')

subplot(413)
plot((diff(squeeze(C(:,4,:))')))
ylabel('KF.C (yvel)')

subplot(414)
plot((diff(squeeze(C(:,5,:))')))
ylabel('KF.C (const)')
xlabel('trials')

%% 
s = '/Volumes/FLASH/Bravo1/20190403/GangulyServer/Center-Out/20190403';
s2 = {'105510','111944','135357'};
C = [];
Q = [];
feature = 1;
for ii=1:length(s2),
    datafiles = dir(fullfile(s,s2{ii},'BCI_Fixed','Data0001.mat'));
    % load data, grab neural features
    load(fullfile(s,s2{ii},'BCI_Fixed',datafiles(1).name))
    C = cat(3,C,TrialData.KalmanFilter.C(128*(feature-1)+1:128*feature,3:5));
    Q = cat(3,Q,TrialData.KalmanFilter.Q);
end

%%
figure
ax1 = [];
ax2 = [];
ax3 = [];
for i=1:size(C,3),
    ax1(end+1)=subplot(length(s2),3,3*(i-1)+1);
    stem(C(:,1,i));
    if i==1, title('V_x'); end
    ylabel(sprintf('session %i',i))

    ax2(end+1)=subplot(length(s2),3,3*(i-1)+2);
    stem(C(:,2,i));
    if i==1, title('V_y'); end

    ax3(end+1)=subplot(length(s2),3,3*(i-1)+3);
    stem(C(:,3,i));
    if i==1, title('Constant'); end
end
YY = cell2mat(get(ax1,'YLim'));
YY = [min(YY(:)),max(YY(:))];
set(ax1,'YLim',YY)

YY = cell2mat(get(ax2,'YLim'));
YY = [min(YY(:)),max(YY(:))];
set(ax2,'YLim',YY)

YY = cell2mat(get(ax3,'YLim'));
YY = [min(YY(:)),max(YY(:))];
set(ax3,'YLim',YY)

% compute angle btw first and other C mats
for i=1:size(C,3)-1,
    vx_ang(i) = abs(rad2deg(acos(dot(C(:,1,i),C(:,1,i+1)) ...
        / norm(C(:,1,i)) / norm(C(:,1,i+1)))));
    vy_ang(i) = abs(rad2deg(acos(dot(C(:,2,i),C(:,2,i+1)) ...
        / norm(C(:,2,i)) / norm(C(:,2,i+1)))));
end

vx_ang
vy_ang
