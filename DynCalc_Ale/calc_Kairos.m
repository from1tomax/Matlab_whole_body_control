
%% This script calculates the matrices for an omnidirectional vehicle
clear all


debug = false;
quiet = false;
optimize = 3;
simplify_act = 1;
des_digit = 4;
static_act = false;
cut_A_act = false;
scale_S_act = false;
C_mat = true;

fileopt_act = true;
filec_act = false; %true = generate c code
path = 'kairos';
filename_prefix = 'get_';
save_fct = 'all';
file_pct_act = 0;


%% Input
zero = sym(zeros(1,1));
%syms wr %wheelradius
wr = 0.127;%wheel radius (m)
wh = 0.1;  %wheel height (m)
nw = 4; %number of wheels

% Kinematic / Location of objects (meters)
%syms b c d %phi0 phi1 phi2 

x_w = 0.215;
y_w = 0.2675;
z_w = 0.218;

%Since there is no steering in Kairos these lines are commented
% phi1 = atan(((c+d)*tan(phi0))/...
%             ((c+d)-b*tan(phi0))); % steering angle 1 wheel left
% phi2 = atan(((c+d)*tan(phi0))/...
%             ((c+d)+b*tan(phi0))); % steering angle 2 wheel right

T_V_I = zeros(4,4,5);

% Wheels are defined in this way: front left = 1, front right = 2, back
% left = 3, back right = 4.

% Wheel 1
%T_V_I(:,:,1) = sym(eye(4));
T_V_I(1,4,1) = x_w;
T_V_I(2,4,1) = y_w;
T_V_I(3,4,1) = z_w;
T_V_I(1:3,1:3,1) = eye(3);
% Wheel 2
%T_V_I(:,:,2) = sym(eye(4));
T_V_I(1,4,2) = x_w;
T_V_I(2,4,2) = -y_w;
T_V_I(3,4,2) = -z_w;
T_V_I(1:3,1:3,2) = eye(3);
% Wheel 3
%T_V_I(:,:,3) = sym(eye(4));
T_V_I(1,4,3) = -x_w;
T_V_I(2,4,3) = y_w;
T_V_I(3,4,3) = -z_w;
T_V_I(1:3,1:3,3) = eye(3);
% Wheel 4
%T_V_I(:,:,4) = sym(eye(4));
T_V_I(1,4,4) = -x_w;
T_V_I(2,4,4) = -y_w;
T_V_I(3,4,4) = -z_w;
T_V_I(1:3,1:3,4) = eye(3);
% Vehicle body
T_V_I(1,4,5) = -2.49272751e-02;
T_V_I(2,4,5) = 7.716970e-03;
T_V_I(3,4,5) = 8.1139300e-02;
T_V_I(1:3,1:3,5) = eye(3);

% Dynamics parameters of objects (Kg)
%syms mw mc
mw = 6.50; 
mc = 175.65; %chassis + battery (TODO: in the chassis are considered the wheels,is it good?)
m = [mw mw mw mw mc];

%syms Iw Im Ic asdf
Inertia = zeros(3,3,5);

[ixx, iyy, izz] = cylinder_inertia(mw, wr, wh); %computing wheel inertia

% Wheel 1
Inertia(1,1,1) = ixx;
Inertia(2,2,1) = iyy;
Inertia(3,3,1) = izz;
% Wheel 2
Inertia(1,1,2) = ixx;
Inertia(2,2,2) = iyy;
Inertia(3,3,2) = izz;
% Wheel 3
Inertia(1,1,3) = ixx;
Inertia(2,2,3) = iyy;
Inertia(3,3,3) = izz;
% Wheel 3
Inertia(1,1,4) = ixx;
Inertia(2,2,4) = iyy;
Inertia(3,3,4) = izz;
% Vehicle body
Inertia(1,1,5) = 2.75; %TODO: Data coming from Darko simulation, maybe to be changed
Inertia(2,2,5) = 9.71;
Inertia(3,3,5) = 8.79;
Inertia(1,2,5) = 0.17;
Inertia(2,1,5) = 0.17;
Inertia(1,3,5) = -0.12;
Inertia(3,1,5) = -0.12;
Inertia(2,3,5) = 0.01;
Inertia(3,2,5) = 0.01;
% Additional Velocities
syms thetad1 thetad2 thetad3 thetad4 %phid0 phid1 phid2

qd_extern = [];
q_extern = [];
%no steering, those terms do not exist
% qd_extern = [ phid1 phid2]; %?? thetas or phi0 
% q_extern = [ phi1 phi2]; %?? thetas or phi0 
% qd_extern = [ phid0]; %?? thetas or phi0 
% q_extern = [ phi0]; %?? thetas or phi0 

%no steering, those terms do not exist
% phid1 = ... 
% (2*phid0*(c + d)^2)/(4*c*d - b^2*cos(2*phi0) + b^2 + 2*c^2 + 2*d^2 - 2*b*c*sin(2*phi0) - 2*b*d*sin(2*phi0));
% phid2 = ... 
% (2*phid0*(c + d)^2)/(4*c*d - b^2*cos(2*phi0) + b^2 + 2*c^2 + 2*d^2 + 2*b*c*sin(2*phi0) + 2*b*d*sin(2*phi0));

omega_I = sym(zeros(3,5));
%Wheel 1
omega_I(:,1) = [zero;thetad1;zero];
%Wheel 2
omega_I(:,2) = [zero;thetad2;zero];
%Wheel 3
omega_I(:,3) = [zero;thetad3;zero];
%Wheel 4
omega_I(:,4) = [zero;thetad4;zero];
%body
omega_I(:,5) = [zero;zero;zero];

pd_I = sym(zeros(size(omega_I))); %zero because Kairos has no object translating with respect to body frame
%% Call function
out_v = vehicle_calc(m, T_V_I, Inertia, pd_I, omega_I, wr, ...
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

%% Useful functions

function [ixx, iyy, izz] = cylinder_inertia(m, r, h)
%computes the inertia of a cylinder where y is the axis of the cylinder

ixx= m*(3*r*r+h*h)/12;
iyy= m*r*r/2;
izz= m*(3*r*r+h*h)/12;

end

