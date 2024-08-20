function A = A_calc(v_w_I,qd,wr,varargin)
    % calc constraint matrix A for vehicle
    % Wheels are assumed to rotate around the y-axis and roll in 
    % x-direction. So the constraints are no sideway slipping in
    % y-direction and no wheelspin in x-direction (=pure rolling). 
    % Calc follows Kumar 2008: 
    % A upper half: differantiate velocity in y to qd (no slipping)
    % A lower half: differantiate (velocity in x -wr*thetad) to qd (roll)
    % v_w_I and qd must NOT be functions of time! no symfun (t)
    % do subs beforehand
    %
    % Inputs:
    % v_w_I:    velocities of wheels expressed in their own frame, with 
    %           respect to world frame; 3 x #wheels
    % qd:       vector of generalized coordinates; length #q
    % wr:       wheelradius; if scalar the same radius for all wheels is
    %           assumed, otherwise specify vector with radius of each 
    %           wheel; length #wheels
    % cut:      (optional) bool; set true if identical rows in A should be 
    %           removed; default is false.
    % thetad:   (optional) symbolic vector; determines names of spinning
    %           around y-axis; length #wheels
    % 
    % Output:
    % A:        The constraint matrix A of the vehicle; 2*#wheels x #q, if
    %           not cutted
    
    % make qd stand upright
    if size(qd,2)>size(qd,1)
        qd = qd.';
    end
    % make wr lay
    if size(wr,1)>size(wr,2)
        wr = wr.';
    end
    
    % Check input
    narginchk(3,5);
    cut = false;
    maketheta = true; 
    if nargin==4
        if islogical(varargin{1}) && isscalar(varargin{1})
            cut = varargin{1};
        elseif isa(varargin{1},'sym')
            maketheta = false;
            thetad = varargin{1};
        else
            error('A_calc: unknown optinal input type.');
        end
    elseif nargin==5
        if islogical(varargin{1}) && isscalar(varargin{1}) && isa(varargin{2},'sym')
            cut = varargin{1};
            maketheta = false;
            thetad = varargin{2};
        elseif isa(varargin{1},'sym') && islogical(varargin{2}) && isscalar(varargin{2})
            cut = varargin{2};
            maketheta = false;
            thetad = varargin{1};
        else
            error('A_calc: unknown optinal input type.');
        end      
    end
    
    % number of wheels
    nw = size(v_w_I,2);
    if ~all(size(v_w_I) == [3 nw])
        error('A_calc: wrong size of velocity matrix! Expected 3 x #wheels');
    end
    % number of qs
    nq = size(qd,1);
    if ~all(size(qd) == [nq 1])
        error('A_calc: wrong size of qd vector! Expected length #q');
    end
    
    % wheelradius
    if isscalar(wr)
        wr = ones(1,nw)*wr;
    else
        if ~all(size(wr) == [1 nw])
            error('A_calc: wrong size of wheelradius vector wr! Expected length is #wheels (or scalar)');
        end
    end
    
    % syms thetadx
    if maketheta
        syms thetad [1 nw]
    else
        % make thetad lay
        if size(thetad,1)>size(thetad,2)
            thetad = thetad.';
        end
        if ~all(size(thetad) == [1 nw])
            error('A_calc: wrong size of thetad vector! Expected length #wheels');
        end        
    end
    
    A = sym(zeros(nw*2,nq));
    for idx=1:nw
        for jdx=1:nq
            % v_y = 0 => no sideway slipping
            A(idx,jdx) = diff(v_w_I(2,idx),qd(jdx));
            % v_x = r*thetad => no in motion slipping
            A(idx+nw,jdx) = diff((v_w_I(1,idx)-wr(idx)*thetad(idx)),qd(jdx));
        end
    end

    % cut equal rows
    if cut
        cutter = ones(1,size(A,1)); %=2*nw
        for idx=1:nw-1
            if cutter(idx) == 1
                for jdx=idx+1:nw
                    if isequal(A(idx,:),A(jdx,:))
                        cutter(jdx) = 0;
                    end
                end
            end
            if cutter(idx+nw) == 1
                for jdx=idx+nw+1:nw+nw
                    if isequal(A(idx+nw,:),A(jdx,:))
                        cutter(jdx) = 0;
                    end
                end
            end
        end
        cutter = logical(cutter);
        A = A(cutter,:);
    end
    
end

