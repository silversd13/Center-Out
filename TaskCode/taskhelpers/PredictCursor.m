function PredictCursor(Params,targetpos)
% PredictCursor(Params)
% Updates the state of the cursor using the method in Cursor.ControlMode
%   1 - position control
%   2 - velocity control
%   3 - kalman filter  velocity
% 
% Cursor - structure with position parameters

% inputs
global Cursor

% Assistance
if ~exist('targetpos','var'), evec = [0;0];
else, evec = targetpos(:) - Cursor.State(1:2); % error vector
end
norm_evec = norm(evec);
if norm_evec==0,
    norm_evec = 1;
end

State = Cursor.State;
dist = norm(evec);

% current velocity
Vcur = State(3:4);

% optimal velocity
if dist<=Params.TargetSize*.75, % in target
    Vopt = 20 * evec(:) / norm_evec; % slow
else,
    Vopt = 200 * evec(:) / norm_evec; % fast
end
Cursor.IntendedState = State;
Cursor.IntendedState(3:4) = Vopt;

% assisted velocity
if Cursor.Assistance > 0,
    Vass = Cursor.Assistance * Vopt + (1-Cursor.Assistance)*Vcur;
    State(3:4) = Vass;
end

% predict cursor based on previous state
Cursor.State = Cursor.A*State;
switch Cursor.ControlMode,
    case 1,
    case 2,
    case 3, % kalman filter, update uncertainty
        Cursor.P = Cursor.A*Cursor.P*Cursor.A' + Cursor.W;
end

% bound cursor position to size of screen
pos = Cursor.State(1:2)' + Params.Center;
pos(1) = max([pos(1),Params.ScreenRectangle(1)]); % x-left
pos(1) = min([pos(1),Params.ScreenRectangle(3)]); % x-right
pos(2) = max([pos(2),Params.ScreenRectangle(2)]); % y-left
pos(2) = min([pos(2),Params.ScreenRectangle(4)]); % y-right
Cursor.State(1) = pos(1) - Params.Center(1);
Cursor.State(2) = pos(2) - Params.Center(2);

end % UpdateCursor