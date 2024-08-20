%% Dummy inputs

qa = [0, -0.785, 0, -2.356, 0, 1.57, 0.785]';
qv =  zeros(3,1);
qa_dot = [0.1, 0.2, 0.3, 0.4, 0.3, 0.2, 0.1]';
qv_dot = [0.1, 0.2, 0.1]';
qa_des = [2, -2.785, 0, -2.356, 2, 1.57, 0.785]';

R_W_D = eye(3);
p_des = [1,1,0]';
x_dot_des = ones(6,1); 
x_ddot_des = ones(6,1); 

R = eye(3);
p = [0.9,0.9,0]';
x_dot = 0.9*ones(6,1); 
x_ddot = 0.9*ones(6,1); 


%% Kinematics and Dynamics
J = get_J(qv,qa)
Jv = get_Jv(qv,qa)

M_temp = get_M(qv,qa);
Mv = get_Mv(qv)

M = M_temp;
M(1:3,1:3) = M_temp(1:3,1:3)+Mv(1:3,1:3);

C_temp = get_C(qv, qa, qv_dot, qa_dot);
Cv = get_Cv(qv, qv_dot);
C = C_temp;
C(1:3,1:3) = C_temp(1:3,1:3)+Cv(1:3,1:3);

G = get_G(qa);

%% NUll space control
Kv = [50*ones(2,1); 100; 3*[100; 100; 50; 100; 50; 100; 100]];
Kp = [400;400*ones(6,1)]; 

J_x_T = J';
J_x_i = pinv(J)

tau_0 = [Kv(1:3).*qv_dot;
         Kp.*(qa-qa_des)+Kv(4:10).*qa_dot]


tau_n = (eye(size(M,2))-J_x_T*J_x_i')*(-M*tau_0)

%% Compute the error
R_D_W_aug = augment_matrix(R_W_D');
S_omega_d = calc_skewsymm(x_dot_des(4:6));
S_alfa_d = calc_skewsymm(x_ddot_des(4:6));

qt = rotm2quat(R)';
qt_des = rotm2quat(R_W_D)';
qt_des_i = [qt_des(1); -qt_des(2:4)];

qt_err = quat_product(qt_des_i, qt);

x_err = [R_W_D'*(p-p_des); 2*qt_err(2:4)];

x_dot_err = R_D_W_aug*[x_dot(1:3)-x_dot_des(1:3)-S_omega_d*(p-p_des); x_dot(4:6)-x_dot_des(4:6)];

%% Cartesian quantities

a = [x_dot_des(1:3) + S_omega_d*(x_err(1:3));
                x_dot_des(4:6)]

vt = R_D_W_aug*a
vt_temp = [x_ddot_des(1:3) + S_alfa_d*x_err(1:3) + S_omega_d*x_dot_err(1:3);
                                                               x_ddot_des(4:6)]
R_D_W_aug*(-augment_matrix(S_omega_d)*a+vt_temp)
augment_matrix(S_omega_d)*a
vt_dot = R_D_W_aug*(-augment_matrix(S_omega_d)*a + [x_ddot_des(1:3) + S_alfa_d*x_err(1:3) + S_omega_d*x_dot_err(1:3);
                                                                  x_ddot_des(4:6)])

J_x = R_D_W_aug*J;
J_x_d = 0.01*J_x;
Lambda_i = J_x/M*J_x';

Lambda = inv(Lambda_i)

%Dynamically consistent pseudo-inverse:
J_x_i = M\J_x'*Lambda; 

%Cartesian Coriolis/Centrifugal Matrix
mu = J_x_i'*(C-M*J_x_i*J_x_d)*J_x_i


%% Compute Damping
Kc = diag(150*ones(6,1)); 
[eigvecs,eigvals] = eig(Kc, Lambda);
eigvals = real(eigvals);
eigvecs = real(eigvecs);
%sorting eigs by magnitude
%[eigvals,sidx] = sort(diag(eigvals),'descend');

%Finding matrices that satisfy K = Q'K0Q and Lambda = Q'*Q
K0 = eigvals;
%V = eigvecs(:,sidx);
Q_T = Lambda*eigvecs;
Q = Q_T';

%Damping matrix computation
zeta = 0.9*ones(6,1); %Imposing an overdamped behaviour
D0 = diag(zeta).*K0;
Dc = 2*Q_T*D0*Q;

%% Impedance Controller torque
tau_imp = G+J_x'*(Lambda*(-vt_dot) + mu*(-vt) - Kc*x_err - Dc*x_dot_err)

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