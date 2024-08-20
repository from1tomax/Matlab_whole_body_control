%% This script calculates the matrcies for a forklift
clear all


debug = false;
quiet = false;
optimize = 3;
simplify_act = 1;
des_digit = 4;
static_act = false;
cut_A_act = true;
scale_S_act = true;
C_mat = true;

fileopt_act = true;
filec_act = true;
path = 'forklift';
filename_prefix = 'get_';
save_fct = 'all';
file_pct_act = 0;


%% Input
zero = sym(zeros(1,1));
syms wr wrf wrr  %wheelradius
nw = 3; %number of wheels
wr = [wrf wrr wrr];

% Kinematic / Location of objects
syms wdx wdy phi0

T_V_I = sym(zeros(4,4,4));
% Wheel 1
T_V_I(:,:,1) = sym(eye(4));
T_V_I(1,1,1) = cos(phi0);
T_V_I(1,2,1) = -sin(phi0);
T_V_I(2,1,1) = sin(phi0);
T_V_I(2,2,1) = cos(phi0);
% Wheel 2
T_V_I(:,:,2) = sym(eye(4));
T_V_I(1,4,2) = -wdx;
T_V_I(2,4,2) = wdy;
% Wheel 3
T_V_I(:,:,3) = sym(eye(4));
T_V_I(1,4,3) = -wdx;
T_V_I(2,4,3) = -wdy;
% Vehicle body
T_V_I(:,:,4) = sym(eye(4));

% Dynamics parameters of objects
syms mwf mwr mc
m = [mwf mwr mwr mc];

syms Iwf Imf Iwr Imr Icz
Inertia = sym(zeros(3,3,4));
% Wheel 1
Inertia(1,1,1) = Imf;
Inertia(2,2,1) = Iwf;
Inertia(3,3,1) = Imf;
% Wheel 2
Inertia(1,1,2) = Imr;
Inertia(2,2,2) = Iwr;
Inertia(3,3,2) = Imr;
% Wheel 3
Inertia(1,1,3) = Imr;
Inertia(2,2,3) = Iwr;
Inertia(3,3,3) = Imr;
% Vehicle body
Inertia(1,1,4) = 0;
Inertia(2,2,4) = 0;
Inertia(3,3,4) = Icz;

% Additional Velocities
syms thetad1 thetad2 thetad3 phid0

q_extern = phi0;
qd_extern = phid0;

omega_I = sym(zeros(3,4));
%Wheel 1
omega_I(:,1) = [zero;thetad1;phid0];
%Wheel 2
omega_I(:,2) = [zero;thetad2;zero];
%Wheel 3
omega_I(:,3) = [zero;thetad3;zero];
%body
omega_I(:,4) = [zero;zero;zero];

pd_I = sym(zeros(size(omega_I))); %Actually input; eg fork

%% Call function
out = vehicle_calc(m, T_V_I, Inertia, pd_I, omega_I, wr, ...
        'optimize', optimize, 'static_act', static_act, 'nw', nw, 'q_extern', q_extern, 'qd_extern', qd_extern, 'C_mat', C_mat, ...
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





