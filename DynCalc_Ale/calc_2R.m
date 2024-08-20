%% This script calculates the matrcies for a 2R robot
clear all

t = true;
f = false;

DH_mod_act = f; %true=mod DH
CoM_est_act = f; %true= estimate CoMs in middle of Links
Inertia_est_act = f; %true-> forces alt_act true
vehicle_act = t; %activate vehicle
calc = 'components';
% update_only = t;
C_mat = t;
% save_fct = 'out';
save_fct = 'components';
% save_fct = 'all';
save_split = '';
path = '2R';
filename_prefix = 'get_';
debug = f;
quiet = f;
M_alg = f;
alt_act = f;
des_digit = 4;
optimize = 4;
fileopt_act = t;
filec_act = t;
file_pct_act = 0;
simplify_act = 3;

symbolic_para = f; 
com_variable = f; %true: mod-sta difference due to unknown com=l/2
                  %true: com_up difference in standard DH, same reason

%% Define varibales

% D-H parameters
syms q1 q2 
if symbolic_para
    syms l1 l2 
else
    l1 = 0.3; l2 = 0.2;
end
syms com1 com2

if DH_mod_act % Modified !!
    a = [0 l1];
    alpha1 = [0 0];
    d = [0 0];    
    theta = [q1 q2];
    
    if com_variable
        CoM = [ com1 com2
                0    0
                0    0    ];
    else
        CoM = [ l1/2 l2/2
                0    0
                0    0    ];
    end
else
    % Standard !!
    a = [l1 l2];
    alpha1 = [0 0];
    d = [0 0];    
    theta = [q1 q2];
    
    if com_variable
        CoM = [ -com1 -com2
                0    0
                0    0    ];
    else
        CoM = [ -l1/2 -l2/2
                0    0
                0    0    ];
    end
end

if CoM_est_act
    CoM = [];
end

% masses of the links
if symbolic_para
    syms m1 m2
    m = [m1 m2];
else
    m = [10 4];
end

% Inertia
if Inertia_est_act
    Inertia = [];
else
    if symbolic_para
        syms I1 I2
        syms asdf
    else
        I1 = 0.5; I2 = 0.5; asdf = 0.0;
    end
%     Inertia = sym(zeros(3,3,2));
    Inertia(:,:,1) = [ asdf 0    0
                       0    asdf 0
                       0    0    I1];
    Inertia(:,:,2) = [ asdf 0    0
                       0    asdf 0
                       0    0    I2];
end

% location of robot base on vehicle
if vehicle_act
%     syms c_ab b_ab alpha
%     T_V_A = [ ...
%         cos(alpha), -sin(alpha), 0, c_ab
%         sin(alpha),  cos(alpha), 0, b_ab
%         0,          0,           1, 0
%         0,          0,           0, 1   ];
%     syms x_va y_va z_va alpha
%     T_V_A = [ ...
%                 cos(alpha), -sin(alpha), 0, x_va
%                 sin(alpha),  cos(alpha), 0, y_va
%                 0         ,  0         , 1, z_va
%                 0         ,  0         , 0, 1   ];
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

% define names for platform gen coo
syms x y phi
vq = [x y phi];
aq = [q1 q2];
syms xd yd phid qd1 qd2
vqd = [xd yd phid];
aqd = [qd1 qd2];

%% call function 'update_only', update_only,
out = manipulator_calc( ...
    a, alpha1, d, theta, DH_mod_act, m, CoM, Inertia, ...
    'TF_veh_arm', T_V_A, 'vq', vq, 'vqd', vqd, 'aq', aq, 'aqd', aqd, ...
    'calc', calc, 'C_mat', C_mat, ...
    'save_fct', save_fct, 'save_split', save_split, ...
    'path', path, 'filename_prefix', filename_prefix, ...
    'debug', debug, 'quiet', quiet, 'M_alg', M_alg, 'alt_act', alt_act, ...
    'desired_digits', des_digit, 'optimize', optimize, 'fileopt_act', fileopt_act, 'filec_act', filec_act, ... 
    'file_pct_act', file_pct_act, 'simplify_act', simplify_act ...
     );



