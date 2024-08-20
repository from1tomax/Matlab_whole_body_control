function J_dot = calc_J_derivative(qv,qa,qv_dot,qa_dot)

qa1 = qa(1);
qa2 = qa(2);
qa3 = qa(3);
qa4 = qa(4);
qa5 = qa(5);
qa6 = qa(6);
qv3= qv(3);

% from Ahmed, S. (1992). Issues in the repeatability of redundant manipulator control : pseudoinverse drift and algorithmic singularities
% The following line computes a 3D matrix, each layer k is the derivative of
% the Jacobian w.r.t. the k-eith joint variable

J_grad = J_gradient(qa1,qa2,qa3,qa4,qa5,qa6,qv3);

% Exploiting dJ/dt = grad(J)*dq/dt, we can multiply each layer by the joint
% velocitites to get the derivative of the Jacobian
J_dot = zeros(6,length(qv)+length(qa));
for i = 1:size(J_grad,3)
J_dot(:,i) = J_grad(:,:,i)*[qv_dot;qa_dot];

end
end

J
