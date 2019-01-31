function Cursor = UpdateCursor(Cursor,Params,Neuro,KF)
% Cursor = PredictCursor(Params,Cursor,dt,newpos,targetvec)
% Updates the state of the cursor using the method in Params.ControlMode
%   1 - position control
%   2 - velocity control
%   3 - kalman filter  velocity
% 
% Cursor - structure with position parameters

% find vx and vy using control scheme
switch Params.ControlMode,
    case 1, % Copy Mouse Position
        [x,y] = GetMouse();
        vx = (x - Cursor.State(1))/dt;
        vy = (y - Cursor.State(2))/dt;
        Cursor.State = [x,y,vx,vy,1];
    case 2, % Use Mouse Position as a Velocity Input (Center-Joystick)
        [x,y] = GetMouse();
        vx = Params.Gain * (x - Params.Center(1));
        vy = Params.Gain * (y - Params.Center(2));
        x = 
        Cursor.State = [
    case 3, % Kalman Filter Velocity Input
        
    case 4,
end



end % DecodeCursor