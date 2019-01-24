function Cursor = UpdateCursor(Params,Cursor,dt,newpos,targetvec)
% Cursor = UpdateCursor(Params,Cursor,dt,newpos,targetvec)
% Updates the state of the cursor using the method in Params.ControlMode
%   1 - position control
%   2 - velocity control
% 
% Cursor - structure with position parameters
% dt - elapsed time
% newpos - newpos is given, cursor control is overridden
% targetvec - used if assistance is on. tagetvec is axis optimal axis.
%   assistance limits movement off that axis

% deal with inputs
if isempty(Cursor), % initialize cursor to random position on screen
    x = randi([Params.ScreenRectangle(1),Params.ScreenRectangle(3)],1);
    y = randi([Params.ScreenRectangle(2),Params.ScreenRectangle(4)],1);
    Cursor.Position = [x,y];
end
if ~exist('newpos','var'), newpos = []; end
if ~exist('targetvec','var'), targetvec = []; end

% find dx and dy using control scheme
switch Params.ControlMode, 
    case 1, % Copy Mouse Position
        [x,y] = GetMouse();
        dx = x - Cursor.Position(1);
        dy = y - Cursor.Position(2);
    case 2, % Use Mouse Position as a Velocity Input (Center-Joystick)
        [x,y] = GetMouse();
        vx = x - Params.Center(1);
        vy = y - Params.Center(2);
        dx = Params.Gain * vx * dt;
        dy = Params.Gain * vy * dt;
    case 3,
    case 4,
end

% update cursor
if ~isempty(targetvec), % assistance
    % define axis from cursor to target and orthogonal axis
    target_uvec = targetvec / norm(targetvec);
    ortho_uvec = target_uvec * [0 -1; 1 0];
    ortho_uvec = ortho_uvec * (1 - Params.Assistance); % rescale to limit orthogonal cursor movement
    % project dx and dy onto new basis
    dxdy = [dx,dy] * target_uvec' * target_uvec ...
        + [dx,dy] * ortho_uvec' * ortho_uvec;
else,
    dxdy = [dx,dy];
end
Cursor.Position = Cursor.Position + dxdy;

% Override cursor control
if ~isempty(newpos),
    Cursor.Position = newpos;
end

% bound cursor position to size of screen
Cursor.Position(1) = max([Cursor.Position(1),Params.ScreenRectangle(1)]); % x-left
Cursor.Position(1) = min([Cursor.Position(1),Params.ScreenRectangle(3)]); % x-right
Cursor.Position(2) = max([Cursor.Position(2),Params.ScreenRectangle(2)]); % y-left
Cursor.Position(2) = min([Cursor.Position(2),Params.ScreenRectangle(4)]); % y-right

end % UpdateCursor