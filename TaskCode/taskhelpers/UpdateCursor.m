function KF = UpdateCursor(Params,Neuro,TaskFlag,TargetPos,KF)
% UpdateCursor(Params,Neuro)
% Updates the state of the cursor using the method in Params.ControlMode
%   1 - position control
%   2 - velocity control
%   3 - kalman filter  velocity
% 
% Cursor - global structure with state of cursor [px,py,vx,vy,1]
% TaskFlag - 0-imagined mvmts, 1-clda, 2-fixed decoder
% TargetPos - x- and y- coordinates of target position. used to assist
%   cursor to target
% KF - kalman filter struct containing matrices A,W,P,C,Q

global Cursor

if TaskFlag>1, % do nothing during imagined movements
    
    % optimal velocity calc (used for cursor assistance, and for intended
    % kinematics)
    if ~exist('TargetPos','var'),
        err_vec = [0;0];
        norm_evec = 0;
    else,
        err_vec = TargetPos(:) - Cursor.State(1:2); % error vector
        norm_evec = norm(err_vec);
    end
    
    if norm_evec==0, % none given, set opt vel to [0,0]
        Vopt = [0;0];
    elseif norm_evec<=Params.TargetSize*.75, % in target
        Vopt = 20 * err_vec(:) / norm_evec; % slow
    else,
        Vopt = 200 * err_vec(:) / norm_evec; % fast
    end
    % update intended state
    Cursor.IntendedState = Cursor.State;
    Cursor.IntendedState(3:4) = Vopt; % update vel w/ optimal vel

    
    % find vx and vy using control scheme
    switch Cursor.ControlMode,
        case 1, % Move to Mouse
            [x,y] = GetMouse();
            vx = ((x-Params.Center(1)) - Cursor.State(1))*Params.UpdateRate;
            vy = ((y-Params.Center(2)) - Cursor.State(2))*Params.UpdateRate;
            
            % update cursor
            Cursor.State(1) = x - Params.Center(1);
            Cursor.State(2) = y - Params.Center(2);
            Cursor.State(3) = vx;
            Cursor.State(4) = vy;
            
        case 2, % Use Mouse Position as a Velocity Input (Center-Joystick)
            [x,y] = GetMouse();
            vx = Params.Gain * (x - Params.Center(1));
            vy = Params.Gain * (y - Params.Center(2));
            
            % assisted velocity
            if Cursor.Assistance > 0,
                Vcur = [vx;vy];
                Vass = Cursor.Assistance*Vopt + (1-Cursor.Assistance)*Vcur;
            else,
                Vass = [vx;vy];
            end
            
            % update cursor state
            Cursor.State(1) = Cursor.State(1) + Vass(1)/Params.UpdateRate;
            Cursor.State(2) = Cursor.State(2) + Vass(2)/Params.UpdateRate;
            Cursor.State(3) = Vass(1);
            Cursor.State(4) = Vass(2);
            
        case 3, % Kalman Filter Velocity Input
            X = Cursor.State;
            X0 = X; % initial state, useful for assistance
            Y = Neuro.NeuralFeatures;
            A = KF.A;
            W = KF.W;
            P = KF.P;
            C = KF.C;
            Q = KF.Q; %#ok<NASGU>
            
            % Update KF Params (RML & Adaptation Block)
            if KF.CLDA.Type==3 && TaskFlag==2, 
                KF = UpdateRmlKF(KF,Cursor.IntendedState,Y);
            end
            
            % Kalman Predict Step
            X = A*X;
            P = A*P*A' + W;
             
            % Kalman Update Step
            Qinv = KF.Qinv;
            %K = P*C'/(C*P*C' + Q);
            K = P*C'*Qinv*(eye(size(Y,1)) - C/(P + C'*Qinv*C)*(C'*Qinv)); % RML Kalman Gain eq (~8ms)
            X = X + K*(Y - C*X);
            P = P - K*C*P;
            
            % Store Params
            Cursor.State = X;
            KF.P = P;
            
            % assisted velocity
            if Cursor.Assistance > 0,
                Vcur = (X(1:2) - X0(1:2))*Params.UpdateRate;
                Vass = Cursor.Assistance*Vopt + (1-Cursor.Assistance)*Vcur;
            
                % update cursor state
                Cursor.State(1) = X0(1) + Vass(1)/Params.UpdateRate;
                Cursor.State(2) = X0(2) + Vass(2)/Params.UpdateRate;
                Cursor.State(3) = Vass(1);
                Cursor.State(4) = Vass(2);
            end
            
    end
    
    % decrease assistance during adaptation block
    if Cursor.Assistance>0,
        Cursor.Assistance = Cursor.Assistance - Cursor.DeltaAssistance;
        Cursor.Assistance = max([Cursor.Assistance,0]);
    end
    
end % TaskFlag
    
% bound cursor position to size of screen
pos = Cursor.State(1:2)' + Params.Center;
pos(1) = max([pos(1),Params.ScreenRectangle(1)]); % x-left
pos(1) = min([pos(1),Params.ScreenRectangle(3)]); % x-right
pos(2) = max([pos(2),Params.ScreenRectangle(2)]); % y-left
pos(2) = min([pos(2),Params.ScreenRectangle(4)]); % y-right
Cursor.State(1) = pos(1) - Params.Center(1);
Cursor.State(2) = pos(2) - Params.Center(2);

end % UpdateCursor