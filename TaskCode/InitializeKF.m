function KF = InitializeKF(datadir)
% function KF = InitializeKF(datadir)
% Uses all trials in given data directory to initialize matrices for kalman
% filter. Returns KF structure containing matrices: A,W,C,Q

% identify all trials
datafiles = dir(fullfile(datadir,'Data*.mat'));

time = [];
pos = [];
ntime = [];
nfeat = [];
for i=1:length(datafiles),
    % load data, grab cursor pos and time
    load(fullfile(datadir,datafiles(i).name)) %#ok<LOAD>
    time = cat(1,time,TrialData.Time);
    pos = cat(1,pos,TrialData.CursorPosition);
    N = length(TrialData.NeuralTime);
    ntime = cat(1,ntime,TrialData.NeuralTime);
    nfeat = cat(1,nfeat,reshape(TrialData.NeuralFeatures,[],N)');
end

% compute velocity from cursor gradient wrt. time
xvel = gradient(pos(:,1),time);
yvel = gradient(pos(:,2),time);
vel = [xvel,yvel];

% interpolate to get cursor pos and vel at neural times
npos = interp1(time,pos,ntime);
nvel = interp1(time,vel,ntime);

% full cursor state at neural times
X = [npos,nvel,ones(size(npos,1),1)]';
X1 = X(:,1:end-1);
X2 = X(:,2:end);
Y = nfeat';
state_sz = size(X,1);

% fit kalman matrices
KF.C = (Y*X') / (X*X');
KF.Q = (1/state_sz) * ((Y-KF.C*X) * (Y-KF.C*X)');
KF.A = (X2*X1') / (X1*X1');
KF.W = (1/(state_sz-1)) * ((X2-KF.A*X1) * (X2-KF.A*X1)');

end % InitializeKF