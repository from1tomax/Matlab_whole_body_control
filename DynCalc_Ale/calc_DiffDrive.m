%% This script calculates the matrcies for a Differential drive
clear all


debug = false;
quiet = false;
optimize = 3;
simplify_act = 1;
des_digit = 4;
static_act = false;
cut_A_act = true;
scale_S_act = false;
C_mat = true;

fileopt_act = true;
filec_act = true;
path = 'DiffDrive';
filename_prefix = 'get_';
save_fct = 'all';
file_pct_act = 0;


%% Input
zero = sym(zeros(1,1));
syms wr %wheelradius
nw = 2; %number of wheels

% Kinematic / Location of objects
syms R d

T_V_I = sym(zeros(4,4,3));
% Wheel 1
T_V_I(:,:,1) = sym(eye(4));
T_V_I(1,4,1) = -d;
T_V_I(2,4,1) = R;
% Wheel 2
T_V_I(:,:,2) = sym(eye(4));
T_V_I(1,4,2) = -d;
T_V_I(2,4,2) = -R;
% Vehicle body
T_V_I(:,:,3) = sym(eye(4));

% Dynamics parameters of objects
syms mw mc
m = [mw mw mc];

syms Iw Im Icx Icy Icz
Inertia = sym(zeros(3,3,3));
% Wheel 1
Inertia(1,1,1) = Im;
Inertia(2,2,1) = Iw;
Inertia(3,3,1) = Im;
% Wheel 2
Inertia(1,1,2) = Im;
Inertia(2,2,2) = Iw;
Inertia(3,3,2) = Im;
% Vehicle body
Inertia(1,1,3) = Icx;
Inertia(2,2,3) = Icy;
Inertia(3,3,3) = Icz;

% Additional Velocities
syms thetad1 thetad2

% q_extern = [];
% qd_extern = [];

omega_I = sym(zeros(3,3));
%Wheel 1
omega_I(:,1) = [zero;thetad1;zero];
%Wheel 2
omega_I(:,2) = [zero;thetad2;zero];
%body
omega_I(:,3) = [zero;zero;zero];

pd_I = sym(zeros(size(omega_I))); %Actually input; eg fork

%% Call function
out = vehicle_calc(m, T_V_I, Inertia, pd_I, omega_I, wr, ...
        'optimize', optimize, 'static_act', static_act, 'nw', nw, 'C_mat', C_mat, ...
        'debug', debug, 'quiet', quiet, 'desired_digits', des_digit, 'simplify_act', simplify_act, 'cut_A_act', cut_A_act, 'scale_S_act', scale_S_act, ...
        'path', path, 'fileopt_act', fileopt_act, 'filec_act', filec_act, 'filename_prefix', filename_prefix, 'save_fct', save_fct, 'file_pct_act', file_pct_act);

% unzip output
% M = out.M
% C = out.C
% A = out.A
% S = out.S
% Sd = out.Sd
% Sq1 = out.Sq(:,:,1)
% Sq2 = out.Sq(:,:,2)



