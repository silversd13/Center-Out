function Cursor = UpdateCursor(Params,Cursor,dt)
switch Params.ControlMode,
    case 1,
        [x,y] = GetMouse();
        Cursor.Position = [x,y];
    case 2,
        dt;
    case 3,
end