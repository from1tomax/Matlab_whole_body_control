function C = C_calc(M,q,qd,varargin)
    % Calc C vector with Cristoffel symbols
    % See DeLuca: 
    % C_i = 0.5*( diff(M_i,q) + diff(M_i,q).' - diff(M,q_i) )
    % C = qd.' * C_i;       %calculate current row in C matrix
    % c = qd.' * C_i * qd;  %calculate current entry in C vector
    % M,q,qd must NOT be functions of time! no symfun (t)
    % do subs beforehand
    % 
    % Input:
    % M:    Mass/Inertia matrix of rigid body; #q x #q
    % q:    vector of generalized coordinates; length #q
    % qd:   vector of derivative of gen coos;  length #q
    % mat:  (optinal) bool; set true if you want the C matrix. default is
    %       false, which returns the C vector, for direct use in dynamics
    % 
    % Output:
    % C:    Either vector #q x 1 or matrix #q x #q, for the dynmaics of a
    %       rigid body
    
    % make q and qd stand upright
    if size(q,2)>size(q,1)
        q = q.';
    end
    if size(qd,2)>size(qd,1)
        qd = qd.';
    end
    
    % check input a bit
    narginchk(3,4);
    nq = size(q,1); %number of qs
    if ~all(size(q) == [nq 1])
        error('C_calc: wrong size of q vector! Expected length #q');
    end
    if ~all(size(qd) == [nq 1])
        error('C_calc: wrong size of qd vector! Expected length #q');
    end
    if ~all(size(M) == [nq nq])
        error('C_calc: wrong size of M matrix! Expected #q x #q');
    end
    
    %init
    
    c_mat = sym(zeros(nq,nq));
    c_vec = sym(zeros(nq,1));
    half = sym(0.5);
    
%     calc c_vec for each q
    
    for idx=1:nq
        diff_Mi_q = sym(zeros(nq));
        for jdx=1:nq
            diff_Mi_q(:,jdx) = diff(M(:,idx),q(jdx)); %diff current column of M to all qs => matrix
        end
        ci_mat = half*( diff_Mi_q + diff_Mi_q.' - diff(M,q(idx)) ); %calculate C matrix for current entry
        c_mat(idx,:) = qd.' * ci_mat; %calculate current row in C matrix
        c_vec(idx) = c_mat(idx,:) * qd; %calculate current entry in C vector
    end

    % Generate output
    if nargin==4 && varargin{1}
        C = c_mat;
    else
        C = c_vec;
    end

end

