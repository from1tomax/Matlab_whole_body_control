
%% This script calculates the matrices for a car
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
path = 'car';
filename_prefix = 'get_';
save_fct = 'all';
file_pct_act = 0;


%% Input
zero = sym(zeros(1,1));
syms wr %wheelradius
nw = 4; %number of wheels

% Kinematic / Location of objects
syms b c d phi0 phi1 phi2 

phi1 = atan(((c+d)*tan(phi0))/...
            ((c+d)-b*tan(phi0))); % steering angle 1 wheel left
phi2 = atan(((c+d)*tan(phi0))/...
            ((c+d)+b*tan(phi0))); % steering angle 2 wheel right

T_V_I = sym(zeros(4,4,5));
% Wheel 1
T_V_I(:,:,1) = sym(eye(4));
T_V_I(1,4,1) = c;
T_V_I(2,4,1) = b;
% T_V_I(3,4,1) = wr;
% T_V_I(1,1,1) = cos(phi1);
% T_V_I(1,2,1) = -sin(phi1);
% T_V_I(2,1,1) = sin(phi1);
% T_V_I(2,2,1) = cos(phi1);
% Wheel 2
T_V_I(:,:,2) = sym(eye(4));
T_V_I(1,4,2) = c;
T_V_I(2,4,2) = -b;
% T_V_I(3,4,2) = wr;
% T_V_I(1,1,2) = cos(phi2);
% T_V_I(1,2,2) = -sin(phi2);
% T_V_I(2,1,2) = sin(phi2);
% T_V_I(2,2,2) = cos(phi2);
% Wheel 3
T_V_I(:,:,3) = sym(eye(4));
T_V_I(1,4,3) = -d;
T_V_I(2,4,3) = b;
% T_V_I(3,4,3) = wr;
% Wheel 4
T_V_I(:,:,4) = sym(eye(4));
T_V_I(1,4,4) = -d;
T_V_I(2,4,4) = -b;
% T_V_I(3,4,4) = wr;
% Vehicle body
T_V_I(:,:,5) = sym(eye(4));

% Dynamics parameters of objects
syms mw mc
m = [mw mw mw mw mc];

syms Iw Im Ic asdf
Inertia = sym(zeros(3,3,5));
% Wheel 1
Inertia(1,1,1) = Im;
Inertia(2,2,1) = Iw;
Inertia(3,3,1) = Im;
% Wheel 2
Inertia(1,1,2) = Im;
Inertia(2,2,2) = Iw;
Inertia(3,3,2) = Im;
% Wheel 3
Inertia(1,1,3) = Im;
Inertia(2,2,3) = Iw;
Inertia(3,3,3) = Im;
% Wheel 3
Inertia(1,1,4) = Im;
Inertia(2,2,4) = Iw;
Inertia(3,3,4) = Im;
% Vehicle body
Inertia(1,1,5) = asdf;
Inertia(2,2,5) = asdf;
Inertia(3,3,5) = Ic;

% Additional Velocities
syms thetad1 thetad2 thetad3 thetad4 phid0 phid1 phid2

% qd_extern = [];
% q_extern = [];
% qd_extern = [ phid1 phid2]; %?? thetas or phi0 
% q_extern = [ phi1 phi2]; %?? thetas or phi0 
qd_extern = [ phid0]; %?? thetas or phi0 
q_extern = [ phi0]; %?? thetas or phi0 
phid1 = ... 
(2*phid0*(c + d)^2)/(4*c*d - b^2*cos(2*phi0) + b^2 + 2*c^2 + 2*d^2 - 2*b*c*sin(2*phi0) - 2*b*d*sin(2*phi0));
phid2 = ... 
(2*phid0*(c + d)^2)/(4*c*d - b^2*cos(2*phi0) + b^2 + 2*c^2 + 2*d^2 + 2*b*c*sin(2*phi0) + 2*b*d*sin(2*phi0));

omega_I = sym(zeros(3,5));
%Wheel 1
omega_I(:,1) = [zero;thetad1;phid1];
%Wheel 2
omega_I(:,2) = [zero;thetad2;phid2];
%Wheel 3
omega_I(:,3) = [zero;thetad3;zero];
%Wheel 4
omega_I(:,4) = [zero;thetad4;zero];
%body
omega_I(:,5) = [zero;zero;zero];

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







