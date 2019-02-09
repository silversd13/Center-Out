function UpdateCursor(Params,Neuro,TaskFlag,TargetPos)
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
            % Kalman Predict Step
            X0 = Cursor.State; % initial state, useful for assistance
            Cursor.State = Neuro.KF.A*X0;
            Neuro.KF.P = Neuro.KF.A*Neuro.KF.P*Neuro.KF.A' + Neuro.KF.W;
            
            % copy structs to vars for better legibility
            P = Neuro.KF.P;
            Y = Neuro.NeuralFeatures;
            C = Neuro.KF.C;
            Q = Neuro.KF.Q; %#ok<NASGU>
            Qinv = Neuro.KF.Qinv;
            
            % Kalman Update Step
            if Neuro.CLDA.Type==3, % RML
                
                if TaskFlag==2, % Adaptation Block
                    % copy structs to vars for better legibility
                    X = Cursor.IntendedState;
                    R = Neuro.KF.R;
                    S = Neuro.KF.S;
                    T = Neuro.KF.T;
                    Tinv = Neuro.KF.Tinv;
                    ESS = Neuro.KF.ESS;
                    Lambda = Neuro.CLDA.Lambda;
                    
                    % update sufficient stats & half life
                    R  = Lambda*R  + X*X';
                    S  = Lambda*S  + Y*X';
                    T  = Lambda*T  + Y*Y';
                    ESS= Lambda*ESS+ 1;
                    Lambda = Lambda + Neuro.CLDA.DeltaLambda;
                    
                    % update inverses
                    Tinv = Tinv/Lambda + (Tinv*(Y*Y')*Tinv)/(Lambda*(Lambda + Y'*Tinv*Y)); % ~35ms
                    Qinv = ESS * (Tinv - Tinv*S/(S'*Tinv*S - R)*S'*Tinv); % ~15ms
                    
                    % update kalman matrices (neural mapping matrices)
                    C = S/R;
                    Q = (1/ESS) * (T - S/R*S');
                    
                    % store params
                    Neuro.KF.R = R;
                    Neuro.KF.S = S;
                    Neuro.KF.T = T;
                    Neuro.KF.C = C;
                    Neuro.KF.Q = Q;
                    Neuro.KF.Tinv = Tinv;
                    Neuro.KF.ESS = ESS;
                    Neuro.KF.Lambda = Lambda;
                end
                
                % RML Kalman Gain eq (~8ms)
%                 Pinv = inv(P);
%                 K = P*C'*Qinv*(eye(size(Y,1)) - C/(Pinv+C'*Qinv*C)*(C'*Qinv)); % RML Kalman Gain eq (edit by DBS)
                K = P*C'*Qinv*(eye(size(Y,1)) - C/(P + C'*Qinv*C)*(C'*Qinv)); 
                                
            else, % not RML/normal kalman filter (faster since not updating params)
                % K = (P*C') / (C*P*C' + Q); % original Kalman Gain eq
                K = P*C'*Qinv*(eye(size(Y,1)) - C/(P + C'*Qinv*C)*(C'*Qinv)); % RML Method
            end
            
            % Kalman Update Step
            X = Cursor.State; % *note using true cursor state
            Cursor.State = X + K*(Y - C*X);
            Neuro.KF.P = P - K*C*P;
            
            % assisted velocity
            if Cursor.Assistance > 0,
                Vcur = (Cursor.State(1:2) - X0(1:2))*Params.UpdateRate;
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

% update intended state
Cursor.IntendedState = Cursor.State;
Cursor.IntendedState(3:4) = Vopt; % update vel w/ optimal vel
    
% bound cursor position to size of screen
pos = Cursor.State(1:2)' + Params.Center;
pos(1) = max([pos(1),Params.ScreenRectangle(1)]); % x-left
pos(1) = min([pos(1),Params.ScreenRectangle(3)]); % x-right
pos(2) = max([pos(2),Params.ScreenRectangle(2)]); % y-left
pos(2) = min([pos(2),Params.ScreenRectangle(4)]); % y-right
Cursor.State(1) = pos(1) - Params.Center(1);
Cursor.State(2) = pos(2) - Params.Center(2);

end % UpdateCursor