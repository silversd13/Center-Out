function KF = AnimateCursor(Params,TaskFlag,KF)
% AnimateCursor(Params,TaskFlag,KF)
% Updates the state of the cursor using the method in Params.ControlMode
%   1 - position control
%   2 - velocity control
%   3 - kalman filter position/velocity
%   4 - kalman filter velocity
%
% Cursor - global structure with state of cursor [px,py,vx,vy,1]
% TaskFlag - 0-imagined mvmts, 1-clda, 2-fixed decoder
% KF - kalman filter struct containing matrices A,W,P,C,Q

global Cursor

if TaskFlag==1, % do nothing during imagined movements
    return;
end

% find vx and vy using control scheme
switch Cursor.ControlMode,
    case 1, % Move to Mouse
        
        vx = Cursor.State(3);
        vy = Cursor.State(4);
        
        % update cursor
        Cursor.State(1) = Cursor.State(1) + vx*Params.ScreenRefreshRate;
        Cursor.State(2) = Cursor.State(2) + vy*Params.ScreenRefreshRate;
        Cursor.State(3) = vx;
        Cursor.State(4) = vy;
        
        % Update Intended Cursor State
        Cursor.IntendedState(1:2) = Cursor.State(1:2); % current true position
        Cursor.IntendedState(3:4) = Vopt; % update vel w/ optimal vel
        
    case 2, % Use Mouse Position as a Velocity Input (Center-Joystick)
        vx = Cursor.State(3);
        vy = Cursor.State(4);
        
        % update cursor
        Cursor.State(1) = Cursor.State(1) + vx*Params.ScreenRefreshRate;
        Cursor.State(2) = Cursor.State(2) + vy*Params.ScreenRefreshRate;
        Cursor.State(3) = vx;
        Cursor.State(4) = vy;
        
        % Update Intended Cursor State
        Cursor.IntendedState(1:2) = Cursor.State(1:2); % current true position
        Cursor.IntendedState(3:4) = Vopt; % update vel w/ optimal vel
        
    case {3,4}, % Kalman Filter Input
        
        % Get Kalman Vars
        X = Cursor.State;
        A = KF.A;
        
        % Integrate Velocity
        X = A*X;
        
        % Update Cursor State
        Cursor.State(1:2) = X(1:2);
        Cursor.IntendedState(1:2) = X(1:2); % current true position
        
end

% update effective velocity command for screen output
try,
    Cursor.Vcommand = Vcom;
catch,
    Cursor.Vcommand = [0,0];
end

% bound cursor position to size of screen
pos = Cursor.State(1:2)' + Params.Center;
pos(1) = max([pos(1),Params.ScreenRectangle(1)+10]); % x-left
pos(1) = min([pos(1),Params.ScreenRectangle(3)-10]); % x-right
pos(2) = max([pos(2),Params.ScreenRectangle(2)+10]); % y-left
pos(2) = min([pos(2),Params.ScreenRectangle(4)-10]); % y-right
Cursor.State(1) = pos(1) - Params.Center(1);
Cursor.State(2) = pos(2) - Params.Center(2);

end % UpdateCursor