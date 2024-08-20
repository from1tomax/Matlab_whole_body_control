function varargout = G_calc(q,m,CoM,varargin)
    % Calc G vector
    % See DeLuca: U= -m*g.'*CoM and G= diff(U,q)
    % q and CoM must NOT be functions of time! no symfun (t)
    % do subs beforehand
    %
    % Inputs:
    % q:    vector containing generalized coordinates
    % m:    vector with masses of objects
    % CoM:  (3D)-Matrix with locations of Center of Masses in choosen
    %       reference frame. Matrix: each column a position vector of an 
    %       object; either homogenous (with trailing 1) or not. 
    %       3D-Array: 3D-Transformation matricies concated in 3. dimension,
    %       so dimension is 4 x 4 x #objects
    % g:    (Optional) a three element vector specifying the gravity;
    %       default is [0;0;-g]
    % 
    % Outputs:
    % G:    Gravity vector for dynamics calculation; #q x 1
    % U_i:  (Optional) a vector containing the potential energies of the
    %       objects; 1 x #objects
    
    % make q stand upright
    if size(q,2)>size(q,1)
        q = q.';
    end
    % make m lay
    if size(m,1)>size(m,2)
        m = m.';
    end
    
    % check input a bit
    narginchk(3,4);
    nq = size(q,1); %number of qs
    no = size(m,2); %number of qs
    if ~all(size(q) == [nq 1])
        error('G_calc: wrong size of q vector! Expected length #q');
    end
    if ~all(size(m) == [1 no])
        error('G_calc: wrong size of m_i vector! Expected length #objects');
    end
    
    % Check CoM
    if size(CoM,3)==1
        % Matrix: only positions 
        if ~(all(size(CoM) == [3 no]) || all(size(CoM) == [4 no]))
            error('G_calc: wrong size of CoM matrix! Expected 3or4 x #objects (or 3D-Array)');
        end
        CoM_S = CoM(1:3,:);  %cut homogenous ones maybe
    else
        % 3D: full TFs  
        if ~all(size(CoM) == [4 4 no])
            error('G_calc: wrong size of CoM! Expected 4 x 4 x #objects (or Matrix)');
        end
        CoM_S = sym(zeros(3,no));
        for idx=1:no
            CoM_S(:,idx) = CoM(1:3,4,idx); %take positions
        end
    end
    
    % build/check g
    if nargin==4
        g_vec = varargin{1};
        % make g stand upright
        if size(g_vec,2)>size(g_vec,1)
            g_vec = g_vec.';
        end
        if ~all(size(g_vec) == [3 1])
            error('G_calc: wrong size of g vector! Expected length 3');
        end
    else
        syms g
        g_vec = [0;0;-g];
    end
    
    % U pot energy
    U_i = sym(zeros(1,no));
    for idx=1:no
        U_i(idx) = -m(idx)*(g_vec.')*CoM_S(:,idx);
    end
    U = sum(U_i,2);
    
    % G vector for dynamics
    G = sym(zeros(nq,1));
    for idx=1:nq
        G(idx) = diff(U,q(idx));
    end
    
    % generate output
    if nargout == 1 || nargout == 0
        varargout{1} = G;
    elseif nargout == 2
        varargout{1} = G;
        varargout{2} = U_i;
    else
        error('G_calc: Wrong number of outputs! Either 1 for G vector or 2 for G vector and U vector.')     
    end
    
end
