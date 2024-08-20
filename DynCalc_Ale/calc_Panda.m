%% This script calculates the matrices for a Panda robot
clear all

t = true;
f = false;

% DH_mod_act = t; %true=mod DH
% CoM_est_act = f; %true= estimate CoMs in middle of Links
Inertia_est_act = f; %true-> forces alt_act true
vehicle_act = t; %activate vehicle
calc = 'all';
C_mat = t;
save_fct = 'all';
save_split = '';
path = 'panda';
filename_prefix = 'get_';
debug = f;
quiet = f;
M_alg = f;
alt_act = f;
des_digit = 4;
optimize = 4;
fileopt_act = t;
filec_act = f;
file_pct_act = 1;
simplify_act = 1; %Never something else!!

% symbolic_para = f; 
% com_variable = f; %true: mod-sta difference due to unknown com=l/2
                    %true: com_up difference in standard DH, same reason

%% Define varibales

syms q1 q2 q3 q4 q5 q6 q7

% if DH_mod_act % Modified !!
DH_mod_act = t;
    % D-H parameters (meters)
    d1 = 0.333; d3 = 0.316; d5 = 0.384; d8 = 0.107;
    a4 = 0.0825; a5 = -0.0825; a7 = 0.088;
    
    a = [0 0 0 a4 a5 0 a7 0];
    alpha = [0 -pi/2 pi/2 pi/2 -pi/2 pi/2 pi/2 0];
    d = [d1 0 d3 0 d5 0 0 d8];   
    theta = [q1 q2 q3 q4 q5 q6 q7 0];
    
    % CoMs
    % Position vector of link CoM expressed in the body frame (FloBaRoID)
    CoM = [ ...
         3.875e-03, -3.141e-03,  2.7518e-02, -5.3170e-02, -1.1953e-02,  6.0149e-02,  1.0517e-02 0
         2.081e-03, -2.872e-02,  3.9252e-02,  1.0442e-01,  4.1065e-02, -1.4117e-02, -4.2520e-03 0 
         0.2500   ,  3.495e-03, -6.6502e-02,  2.7454e-02, -3.8437e-02, -1.0517e-02,  6.1597e-02 0]; 

% masses of the links
m = [4.970684 0.646926 3.228604 3.587895 1.225946 1.666555 0.735522 0];

% Inertia
if Inertia_est_act
    Inertia = [];
else
    %[Ixx Iyy Izz Ixy Ixz Iyz]'
    Inertia = [ ...
         7.0337e-01,  7.9620e-03,  3.7242e-02,  2.5853e-02,  3.5549e-02,  1.9640e-03,  1.2516e-02 0
         7.0661e-01,  2.8110e-02,  3.6155e-02,  1.9552e-02,  2.9474e-02,  4.3540e-03,  1.0027e-02 0
         9.1170e-03,  2.5995e-02,  1.0830e-02,  2.8323e-02,  8.6270e-03,  5.4330e-03,  4.8150e-03 0
        -1.3900e-04, -3.9250e-03, -4.7610e-03,  7.7960e-03, -2.1170e-03,  1.0900e-04, -4.2800e-04 0
         6.7720e-03,  1.0254e-02, -1.1396e-02, -1.3320e-03, -4.0370e-03, -1.1580e-03, -1.1960e-03 0
         1.9169e-02,  7.0400e-04, -1.2805e-02,  8.6410e-03,  2.2900e-04,  3.4100e-04, -7.4100e-04 0];
end

% location of robot base on vehicle in meters
if vehicle_act
%   syms Ab_x Ab_y Ab_z Ab_a
    Ab_x = -0.275; 
    Ab_y = -0.155;
    Ab_z = 0.345;
    Ab_a = pi;
    
    T_V_A = [ ...
        cos(Ab_a), -sin(Ab_a), 0, Ab_x
        sin(Ab_a),  cos(Ab_a), 0, Ab_y
        0,          0,         1, Ab_z
        0,          0,         0, 1   ];
%   syms T_V_A [3,4] 
%   T_V_A(4,:) = sym([0 0 0 1]);

else
    T_V_A = [];
end

%% call function
out = manipulator_calc( ...
    a, alpha, d, theta, DH_mod_act, m, CoM, Inertia, ...
    'TF_veh_arm', T_V_A, ...
    'calc', calc, 'C_mat', C_mat, ...
    'save_fct', save_fct, 'save_split', save_split, ...
    'path', path, 'filename_prefix', filename_prefix, ...
    'debug', debug, 'quiet', quiet, 'M_alg', M_alg, 'alt_act', alt_act, ...
    'desired_digits', des_digit, 'optimize', optimize, 'fileopt_act', fileopt_act, 'filec_act', filec_act,... 
    'file_pct_act', file_pct_act, 'simplify_act', simplify_act ...
     );





