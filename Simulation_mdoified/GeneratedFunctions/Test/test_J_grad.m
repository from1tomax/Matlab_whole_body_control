% qa = sym("qa", [7,1]);
% dqa = sym("dqa", [7,1]);
% 
% qv = sym("qv", [3,1]);
% dqv = sym("dqv", [3,1]);
% 
% J = get_J(qv,qa);
% 
% J_grad = teng4fcn_7dofPANDA_dJ_tensor_franka(J);
% 
% matlabFunction(J_grad,'file','J_gradient.m','Optimize', true)
% 
% qa = subs(qa, [0, -0.785, 0, -2.356, 0, 1.57, 0.785]');
% qv = subs(qv, [1,2,0]);

qa = [0, -0.785, 0, -2.356, 0, 1.57, 0.785]';
qv = [1,2,0]';

qa_dot = [1,1,1,1,1,1,1]';
qv_dot = [1,1,1]';

calc_J_derivative(qv,qa,qv_dot,qa_dot);

% qa1 = qa(1);
% qa2 = qa(2);
% qa3 = qa(3);
% qa4 = qa(4);
% qa5 = qa(5);
% qa6 = qa(6);
% qv3= qv(3);
% 
% J_grad = get_J_gradient(qa1,qa2,qa3,qa4,qa5,qa6,qv3);
