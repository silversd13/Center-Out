function KF = InitializeKF(datadir)
% function KF = InitializeKF(datadir)
% Uses all trials in given data directory to initialize matrices for kalman
% filter. Returns KF structure containing matrices: A,W,C,Q

% identify all trials
datafiles = dir(fullfile(datadir,'Data*.mat'));

Tfull = [];
Xfull = [];
Y = [];
T = [];
for i=1:length(datafiles),
    % load data, grab cursor pos and time
    load(fullfile(datadir,datafiles(i).name)) %#ok<LOAD>
    Tfull = cat(2,Tfull,TrialData.Time);
    Xfull = cat(2,Xfull,TrialData.CursorState);
    T = cat(2,T,TrialData.NeuralTime);
    Y = cat(2,Y,TrialData.NeuralFeatures);
end

% interpolate to get cursor pos and vel at neural times
X = interp1(Tfull,Xfull,T);

% full cursor state at neural times
D = size(X,1);

% fit kalman matrices
KF.C = (Y*X') / (X*X');
KF.Q = (1/D) * ((Y-KF.C*X) * (Y-KF.C*X)');

end % InitializeKF