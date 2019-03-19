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
plot(1:length(alpha),alpha)
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
plot(abs(diff(squeeze(C(:,3,:))')))
ylabel('KF.C (xvel)')

subplot(413)
plot(abs(diff(squeeze(C(:,4,:))')))
ylabel('KF.C (yvel)')

subplot(414)
plot(abs(diff(squeeze(C(:,5,:))')))
ylabel('KF.C (const)')
xlabel('trials')

%% 
s = '/media/dsilver/FLASH/Bravo1/20190318';
s2 = {'110627','112800','113809','135928'};
C = [];
for ii=1:length(s2),
    datafiles = dir(fullfile(s,s2{ii},'BCI_CLDA','Data*.mat'));
    % load data, grab neural features
    i = 10;
    load(fullfile(s,s2{ii},'BCI_CLDA',datafiles(i).name))
    C = cat(3,C,TrialData.KalmanFilter.C(:,3:4));
end

%%
figure
ax1 = [];
ax2 = [];
ax3 = [];
for i=1:4,
    ax1(end+1)=subplot(4,3,3*(i-1)+1);
    stem(C(:,3,i));

    ax2(end+1)=subplot(4,3,3*(i-1)+2);
    stem(C(:,4,i));

    ax3(end+1)=subplot(4,3,3*(i-1)+3);
    stem(C(:,5,i));
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
for i=1:4,
    vx_ang(i) = abs(rad2deg(acos(dot(C(:,1,1),C(:,1,i)) / norm(C(:,1,1)) / norm(C(:,1,i)))));
    vy_ang(i) = abs(rad2deg(acos(dot(C(:,2,1),C(:,2,i)) / norm(C(:,2,1)) / norm(C(:,2,i)))));
end



