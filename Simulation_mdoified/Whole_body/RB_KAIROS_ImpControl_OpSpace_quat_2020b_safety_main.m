clear all;
close all;
clc;

% Include functions generated through dynamics toolbox
addpath("../GeneratedFunctions");
addpath("../utils");

%% LOAD ROBOT

run("../Robot_Models/LoadRB_kairos.m");
config =  homeConfiguration  (RB_Kairos);

% INITIALIZE SIMULATION PARAMETERS

% Initial conditions
q_dot_0 = zeros(10,1);

q_0(1:3)= [0, 0, 0]';
q_0(4:10)= [0, -0.785, 0, -2.356, 0, 1.57, 0.785]';

for i=1:10
config(i).JointPosition = q_0(i);
end
show(RB_Kairos,config)

% Compute initial pose
K = forward_kinematics(q_0(1:3), q_0(4:10))

% Initialize Jacobian and check for singularities in initial configuration
J_init = get_J(q_0(1:3), q_0(4:10));
% External Force
tau_ext = [0 0 0 0 0 0 0 0 0 0 0];

% CONTROLLER PARAMETERS
% Cartesian Controller (Primary Task)
Kc = diag(50*ones(6,1)); %STIFFNESS 150
%K_d = diag([150;180;105;1.5;15;52.5]); % D_d = diag([180;200;80;10;10;6]);

% Null-space Controller (Secondary task)
Kv = [1000;1000;1000;[300;300;300;300;300;300;300]]% [50*ones(2,1); 100; 3*[100; 100; 50; 100; 50; 100; 100]];
Kp = 2*[400;400;400;400;0;0;0]% [400;400*ones(6,1)]; 


% SMU PARAMETERS (NOT USED RIGHT NOW):
in_POI = [1, 0, 0]'; %POI in EE frame, distance in meters
z_POI = [1, 0, 0]'/norm([1,0,0]') %POI normal direction in EE frame coord.
human_position = [0.5, 0.5, 0]'; %Human position in EE frame

%% RUN SIMULATION
t_end = 100;
model_sample_time = 0.001;

% Position and orientation waypoints
T_i = K;
p_i = T_i(1:3,4);

p_f = [-3;p_i(2)+3; p_i(3)];
T_f(1:3,1:3) = eul2rotm([0,0,pi/6], 'XYZ')*T_i(1:3,1:3);
T_f(1:4,4) = [p_f;1];

% Initial velocities
dp_f = zeros(3,1);
dPhi_f = zeros(3,1);

% Dummy safe speed for testing
v_SMU = 10;

%speed limits for cartesian motion on "s"
vm = 0.5;
vm_r = 0.5;

am = 0.3;
am_r = 0.3;
% return; 
open("RB_KAIROS_ImpControl_OpSpace_quat_2020b_safety.slx");
sim("RB_KAIROS_ImpControl_OpSpace_quat_2020b_safety.slx");

%% Animation
t = 0:0.1:t_end;
figure
show(RB_Kairos, config);
set_figure();
zoom on 

q_des = rotm2quat(R_W_D.Data(1:end, 1:end, 1:end));
for i = 1:length(p_des.Data)/1000
    plotTransforms(p_des.Data(1:end, i*1000)', q_des(i*1000,1:end), 'FrameSize', 0.1);
end


for i = 1:length(t)-1
    
    idx = find(qa.Time > t(i),1, 'first');
    q_v = qv.Data(idx, 1:end);
    q_a = qa.Data(idx, 1:end);
    J = get_J(q_v,q_a);

 for j = 1:3
    config(j).JointPosition = q_v(j);
 end
 for j = 4:10
    config(j).JointPosition = q_a(j-3);
 end

    show(RB_Kairos, config, 'PreservePlot', false);
    pause(0.00001)
end

disp("Computed transformation matrix:")
K = forward_kinematics(q_v,q_a)

%% FUNCTIONS
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

function set_figure
xlim([-5 5])
ylim([-5 5])
zlim([0 1.5])
set(gcf, 'WindowState', 'fullscreen'); % Opens figure in full screen
% maximize plot in figure window
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
if abs(ax.Position(1)-left)>1e-6
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3); %0.003 self adjusted, due to box
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
end
pause(0.5)
hold on;
end