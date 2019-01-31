function Cursor = PredictCursor(Params,Cursor,dt,newpos,targetvec)
% Cursor = PredictCursor(Params,Cursor,dt,newpos,targetvec)
% Updates the state of the cursor using the method in Params.ControlMode
%   1 - position control
%   2 - velocity control
%   3 - kalman filter  velocity
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
    Cursor.State = [x,y,0,0,1];
end
if ~exist('newpos','var'), newpos = []; end
if ~exist('targetvec','var'), targetvec = []; end



% update cursor
if ~isempty(targetvec) && Params.AssistMode==1, % assistance
    % define axis from cursor to target and orthogonal axis
    target_uvec = targetvec / norm(targetvec);
    ortho_uvec = target_uvec * [0 -1; 1 0];
    ortho_uvec = ortho_uvec * (1 - Params.Assistance); % rescale to limit orthogonal cursor movement
    % project dx and dy onto new basis
    dxdy = ([dx,dy] * target_uvec') * target_uvec ...
        + ([dx,dy] * ortho_uvec') * ortho_uvec;
elseif ~isempty(targetvec) && Params.AssistMode==2, % assistance
    Vopt = 10 * dt * targetvec / norm(targetvec); % optimal velocity is scaled targetvec
    Vdec = [dx,dy]; % decoded velocity
    dxdy = Params.Assistance*Vopt + (1-Params.Assistance)*Vdec; % output velocity
else,
    dxdy = [dx,dy];
end
Cursor.State = Cursor.State + dxdy;

% Override cursor control
if ~isempty(newpos),
    Cursor.State = newpos;
end

% bound cursor position to size of screen
Cursor.State(1) = max([Cursor.State(1),Params.ScreenRectangle(1)]); % x-left
Cursor.State(1) = min([Cursor.State(1),Params.ScreenRectangle(3)]); % x-right
Cursor.State(2) = max([Cursor.State(2),Params.ScreenRectangle(2)]); % y-left
Cursor.State(2) = min([Cursor.State(2),Params.ScreenRectangle(4)]); % y-right

end % UpdateCursor