%% Dummy inputs

Kv = 0.01*[50*ones(2,1); 100; 3*[100; 100; 100; 100; 100; 100; 100]];
Kp = 0.01*[400;400*ones(6,1)];
qa_des = [0., -0.785, 0., -2.356, 0., 1.57, 0.785]';

qv =  [-0.00351807083641927
-0.000453984325703812
  -0.0067632160721982];
qa = [0.0199185258204704
  -1.06003262557724
-0.0385636015233777
   -2.3846607800211
-0.0322414067215231
   1.31189669012784
   1.08379423988505];
qv_dot = [-0.00148524804911556
-3.59209680347502e-05
 -0.00463658943772316];
qa_dot = [-0.0137733707910391
   -0.22389491287927
  0.0129232570885766
  0.0265369938605409
-0.00168426370637533
   -0.20730151368181
  0.0808848895736439];

R_W_D = [  -0.456357626418055     0.88976258919278  0.00776219576145967
   0.889790560489449    0.456368973843483 0.000343768697486488
-0.00323655278807058  0.00706360998403979   -0.999969814614443]; 

p_des = [-0.582586, -0.154254, 1.277220]';
x_dot_des = [0.000000, 0.000000,0.000000,0.000776,0.000034,-0.099997]'; 
x_ddot_des =[0.000000, 0.000000,0.000000,0.000000,0.000000,-0.000000]'; 

K = forward_kinematics(qv,qa);
R = K(1:3,1:3)

% [ -0.706113   0.707718  0.0232515;
%   0.707909   0.706304  -2.37e-05;
% -0.0164394  0.0164432   -0.99973]; 
p = K(1:3,4)


%% Kinematics and Dynamics
J = get_J(qv,qa);
J = J(1:6,4:10)

M = get_M(qv,qa);
M = M(4:10,4:10)

C = get_C(qv, qa, qv_dot, qa_dot);
C = C(4:10,4:10)

G = get_G(qa);
G = G(4:10)

%% Compute the error

x_dot = J*qa_dot

R_D_W_aug = augment_matrix(R_W_D');
S_omega_d = calc_skewsymm(x_dot_des(4:6));
S_alfa_d = calc_skewsymm(x_ddot_des(4:6));

qt = rotm2quat(R)';
qt_des = rotm2quat(R_W_D)';
qt_des_i = [qt_des(1); -qt_des(2:4)];

qt_err = quat_product(qt_des_i, qt);

x_err = [R_W_D'*(p-p_des); 2*qt_err(2:4)]

x_dot_err = R_D_W_aug*[x_dot(1:3)-x_dot_des(1:3)-S_omega_d*(p-p_des); x_dot(4:6)-x_dot_des(4:6)]


%% Cartesian quantities

a = [x_dot_des(1:3) + S_omega_d*(x_err(1:3));
                x_dot_des(4:6)]

vt = R_D_W_aug*a

vt_dot = R_D_W_aug*(-augment_matrix(S_omega_d)*a + [x_ddot_des(1:3) + S_alfa_d*x_err(1:3) + S_omega_d*x_dot_err(1:3);
                                                                  x_ddot_des(4:6)])

J_x = R_D_W_aug*J
J_x_T = J_x';
J_x_d =  [-0.010630772984771    -0.026263132634069   -0.0164983184788858   0.00679316374416553   -0.0059002320443452  -0.00948413984033086 -9.02410215172517e-20;
   0.0174297200128543   -0.0130329617598068    0.0313119968992914    0.0018503673513276    0.0111289650309432   -0.0050560589392179   1.7303900413497e-19;
                    0                     0                     0                     0                     0                     0                     0;
 0.000706344814461329   -0.0444669504564565    0.0784807109519559    0.0460981874478295   -0.0854951246566649    0.0468408331180115  0.000348110550981405;
 0.000323690596316234    0.0895694687093052    0.0389489092598172   -0.0886757200971311   -0.0454067872249775   -0.0883507614399259  0.000503278719632232;
                    0                     0                     0                     0                     0                     0                     0];
Lambda_i = J_x/M*J_x';

Lambda = pinv(Lambda_i)

%Dynamically consistent pseudo-inverse:
J_x_i = M\J_x'*Lambda; 

%Cartesian Coriolis/Centrifugal Matrix
mu = J_x_i'*(C-M*J_x_i*J_x_d)*J_x_i

%% Compute damping
Kc = diag(6*ones(6,1));
%Generalized eigenvalue decomposition for the pair (Kc,Lambda)
% [eigvecs,eigvals] =  eig(Kc, Lambda);
% eigvals = real(eigvals);
% eigvecs = real(eigvecs);
% %sorting eigs by magnitude
% % [eigvals,sidx] = sort(diag(eigvals),'descend');
% 
% %Finding matrices that satisfy K = Q'K0Q and Lambda = Q'*Q
% K0 = diag(eigvals);
% V = eigvecs(:,:)
% Q_T = Lambda*V
% Q = Q_T';
% 
% %Damping matrix computation
% zeta = 1*ones(6,1); %Imposing an overdamped behaviour
% D0 = diag(zeta).*K0
% Dc = 2*Q_T*D0*Q

A = real(sqrtm(Lambda));
Kc_1 = real(sqrtm(Kc));

zeta = 0.9*ones(6,1);
D0 = diag(zeta);

Dc = A*D0*Kc_1 + Kc_1*D0*A

%% Impedance Controller torque
tau_imp = G+J_x'*(Lambda*(-vt_dot) + mu*(-vt) - Kc*x_err - Dc*x_dot_err)

%% Null space torque

tau_0 = -M*(Kp.*(qa-qa_des)+Kv(4:10).*qa_dot)

tau_n = (eye(size(M,2))-J_x_T*J_x_i')*tau_0

%% Admittance interface
tau = tau_imp+tau_n
qv_cmd = [-0.003518, -0.000454, -0.006763]'; %qv;%[0.002194, -0.000188, 0.007028]';
qa_cmd = [0.018654, -1.080178,-0.040049,-2.342167,-0.031817,1.307604,1.088576]';
qv_dot_cmd = [0.000000, 0.000000, 0.000000]'; qv_dot;%[0.000000, 0.000000, 0.000000]';
qa_dot_cmd = [-0.014202, -0.224559,0.014230,0.029418,-0.000896,-0.209226,0.078712]';
M_command = get_M(qv_cmd,qa_cmd);
M_command = M_command(4:10,4:10)

C_command = get_C(qv_cmd, qa_cmd, qv_dot_cmd, qa_dot_cmd);
C_command = C_command(4:10,4:10)

G_command = get_G(qa_cmd);
G_command = G_command(4:10)

ddq = inv(M_command)*(tau - C_command*qa_dot_cmd-G_command)

function S = calc_skewsymm(v)

S = [0 -v(3) v(2);
    v(3) 0 -v(1);
    -v(2) v(1) 0];
end

function M_aug = augment_matrix(M)

M_aug = [M, zeros(3,3);
             zeros(3,3), M];
end

function qt_prod = quat_product(qt1,qt2)
% Computes the halmiton product

% Inverse of desired quaternion

eta1 = qt1(1);
eta2 = qt2(1);

eps1 = qt1(2:4);
eps2 = qt2(2:4);

% Quaternion product qt1*qt2
qt_prod = [eta1*eta2-dot(eps1,eps2);
    (eta1*eps2+eta2*eps1+cross(eps1,eps2))];
end