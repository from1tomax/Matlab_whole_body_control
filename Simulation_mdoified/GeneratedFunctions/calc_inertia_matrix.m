function M = calc_inertia_matrix(qv, qa)

M_v = get_Mv(qv);
M_a = get_M(qv,qa);

%nw = number of wheels, nv = DOF of chassis, na = DOF of the arm. Wheels are neglected in this
%case
nw = 4;
nv = size(M_v,1)-nw;
na = size(M_a,1)-nv;

Ma_up = M_a(1:nv, 1:nv); 
Mva = M_a(1:nv, nv+1:nv+na);
Mav = M_a(nv+1:nv+na, 1:nv);
Ma = M_a(nv+1:nv+na, nv+1:nv+na);

Mv = M_v(1:nv, 1:nv);
% Mvw = M_v(1:nv, 4:nv+nw);
% Mwv = M_v(4:nv+nw, 1:nv);
% Mw = M_v(nv+1:nv+nw, nv+1:nv+nw);

%output
M = zeros(nv+na, nv+na);

M(1:nv,1:nv) = Mv+Ma_up;
M(1:nv,nv+1:nv+na) = Mva;
M(nv+1:nv+na,1:nv) = Mav;
M(nv+1:nv+na,nv+1:nv+na) = Ma;
end