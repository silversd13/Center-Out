function Cursor = UpdateCursor(Params,Cursor,dt)
% Updates the state of the cursor using the method in Params.ControlMode
if isempty(Cursor), % initialize cursor to random position on screen
    x = randi([Params.ScreenRectangle(1),Params.ScreenRectangle(3)],1);
    y = randi([Params.ScreenRectangle(2),Params.ScreenRectangle(4)],1);
    Cursor.Position = [x,y];
end

switch Params.ControlMode, % Update cursor according to control scheme
    case 1, % Copy Mouse Position
        [x,y] = GetMouse();
        Cursor.Position = [x,y];
    case 2, % Use Mouse Position as a Velocity Input
        [x,y] = GetMouse();
        vx = x - Params.Center(1);
        vy = y - Params.Center(2);
        dx = Params.Gain * vx * dt;
        dy = Params.Gain * vy * dt;
        Cursor.Position = Cursor.Position + [dx,dy];
        % bound cursor position to size of screen
        Cursor.Position(1) = max([Cursor.Position(1),Params.ScreenRectangle(1)]); % x-left
        Cursor.Position(1) = min([Cursor.Position(1),Params.ScreenRectangle(3)]); % x-right
        Cursor.Position(2) = max([Cursor.Position(2),Params.ScreenRectangle(2)]); % y-left
        Cursor.Position(2) = min([Cursor.Position(2),Params.ScreenRectangle(4)]); % y-right
    case 3,
    case 4,
end

end % UpdateCursor