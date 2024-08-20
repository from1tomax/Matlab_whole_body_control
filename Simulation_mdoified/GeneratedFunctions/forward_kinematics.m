function K = forward_kinematics(qv,qa)
% Computes the forward kinematics of RB-KAIROS. 
% V = Vehicle
% A = Arm
% W = world
% EE = end effector
% e.g. T_V_A is the transformation matrix between the vehicle and the arm

Ab_x = -0.275;
Ab_y = -0.155;
Ab_z = 0.345;
Ab_a = pi;

T_V_A = [ ...
    cos(Ab_a), -sin(Ab_a), 0, Ab_x;
    sin(Ab_a),  cos(Ab_a), 0, Ab_y;
    0,          0,         1, Ab_z;
    0,          0,         0, 1   ];

T_W_V = [ ...
    cos(qv(3)) -sin(qv(3)), 0, qv(1);
    sin(qv(3)),  cos(qv(3)), 0, qv(2);
    0,          0,         1, 0.345;
    0,          0,         0, 1   ];

K = T_W_V*T_V_A*get_T_A_EE(qv,qa);

end