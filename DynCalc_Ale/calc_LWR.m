%% This script calculates the matrcies for a LWR
clear all

t = true;
f = false;

% DH_mod_act = t; %true=mod DH
% CoM_est_act = f; %true= estimate CoMs in middle of Links
Inertia_est_act = f; %true-> forces alt_act true
vehicle_act = t; %activate vehicle
calc = 'components';
C_mat = t;
save_fct = 'components';
save_split = '';
path = 'LWR';
filename_prefix = 'get_';
debug = f;
quiet = f;
M_alg = f;
alt_act = f;
des_digit = 4;
optimize = 4;
fileopt_act = t;
filec_act = t;
file_pct_act = 1;
simplify_act = 1; %Never something else!!

% symbolic_para = f; 
% com_variable = f; %true: mod-sta difference due to unknown com=l/2
                    %true: com_up difference in standard DH, same reason

%% Define varibales

syms q1 q2 q3 q4 q5 q6 q7

% if DH_mod_act % Modified !!
DH_mod_act = t;
    % D-H parameters
    % Numerical parameters of the DLR Kuka Lightweight Robot (LWR) IV are
    % taken from 'Dynamic Modelling of the Compliant KUKA-DLR Lightweight
    % Robot', Walter A. Galvao da Veiga (2014)

    a = [0 0 0 0 0 0 0];
    alpha = [0 pi/2 -pi/2 -pi/2 pi/2 pi/2 -pi/2];
    d = [0 0 0.4 0 0.39 0 0];   
    theta = [q1 q2 q3 q4 q5 q6 q7];
    
    % CoMs
    % Position vector of link CoM expressed in the body frame (FloBaRoID)
    CoM = [ ...
         0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000 
        -0.1620, 0.1620, 0.1620,-0.1620, 0.0000, 0.0000, 0.0000 
         0.3510, 0.1890, 0.3510, 0.1890, 0.2108, 0.1000, 0.0000]; 
% syms CoM [7,3]

% masses of the links
m = [2.7 2.7 2.7 2.7 1.7 1.6 0.3];
% syms m [7,1]

% Inertia
if Inertia_est_act
    Inertia = [];
else
    Inertia = sym(zeros(3,3,7));
    Inertia(:,:,1) = [...
    0.0738 0.0000 0.0000
    0.0000 0.0497 0.0211
    0.0000 0.0211 0.0257];
    Inertia(:,:,2) = [...
    0.0414 0.0000 0.0000
    0.0000 0.0173 -0.0133
    0.0000 -0.0133 0.0257];
    Inertia(:,:,3) = [...
    0.0738 0.0000 0.0000
    0.0000 0.0497 -0.0211
    0.0000 -0.0211 0.0257];
    Inertia(:,:,4) = [...
    0.0414 0.0000 0.0000
    0.0000 0.0173 0.0133
    0.0000 0.0133 0.0257];
    Inertia(:,:,5) = [...
    0.0369 0.0000 0.0000
    0.0000 0.0287 0.0000
    0.0000 0.0000 0.0092];
    Inertia(:,:,6) = [...
    0.0104 0.0000 0.0000
    0.0000 0.0104 0.0000
    0.0000 0.0000 0.0042];
    Inertia(:,:,7) = [...
    0.0500 0.0000 0.0000
    0.0000 0.0500 0.0000
    0.0000 0.0000 0.0500];
end

% location of robot base on vehicle
if vehicle_act
%     syms Ab_x Ab_y Ab_z Ab_a
%     T_V_A = [ ...
%         cos(Ab_a), -sin(Ab_a), 0, Ab_x
%         sin(Ab_a),  cos(Ab_a), 0, Ab_y
%         0,          0,         1, Ab_z
%         0,          0,         0, 1   ];
    syms T_V_A [3,4] 
    T_V_A(4,:) = sym([0 0 0 1]);

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





