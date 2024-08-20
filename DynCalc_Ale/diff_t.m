function [mat_dot] = diff_t(mat,q,qd,varargin)
%DIFF_T computes the time derivative of a symbolic expression.
% mat is the input expression which should be differentiated with respect
% to time t. However, the mat does not include the time t, actually it must
% not be a function of t (no symfun!). To determine which variables are
% time dependent specify them in the q vector. These also must not be
% explicit functions of time (no symfun!), the code internally replaces
% them with time dependent variables. After computing diff(mat,t) there
% occur for matlab unknown derivatives of the qs. These are then replaced
% by the variables specified by qd. Again qd must not be function of time. 
% The output mat_dot is again not dependent on the time, but on q and qd. 
% One can also use expressions that are already dependent on multiple
% derivatives of q. If this is the case specify all the qs, qds, and so on
% in separated vectors. And finally one extra vector for the unknown 
% highest derivative.

% first check Matlab version due to dynamic syms
if verLessThan('matlab','9.7')
    error('diff_t: At least Matlab 2019B is required.')
end

% check input a bit
narginchk(3,inf);
if ~isa(mat,'sym')
    error('diff_t: mat must be symbolic! (but not symfun)');
end
nd = nargin-1; %number of derivatives
nq = max(size(q,1),size(q,2)); %number of qs
% build q matrix: rows are derivatives; columns are qs
qmat = sym(zeros(nd,nq));
for idx=1:nd
    if idx==1
        qc = q;
    elseif idx==2
        qc = qd;
    else
        qc = varargin{idx-2};
    end
    if ~isa(qc,'sym')
        error('diff_t: q and derivatives must be symbolic! (but not symfun)');
    end
    % make qc lay
    if size(qc,1)>size(qc,2)
        qc = qc.';
    end
    if ~all(size(qc) == [1 nq])
        error('diff_t: wrong size of a q(d...) vector! Expected length #q');
    end
    qmat(idx,:) = qc;
    clear qc
end

% Check if enough derivatives were specified
in_vars = symvar(mat);
nv = max(size(in_vars,1),size(in_vars,2));
for idx=1:nq
    for jdx=1:nv
        if qmat(end,idx) == in_vars(jdx) %Check for highest derivatives if they are already in the matrix
            error('diff_t: found a highest specified derivative in the input mat! please determine more derivatives!');
        end
    end
end

% syms variables
syms t
qinmatt = sym(zeros(0,1)); %init due to code analyser
% This part here is problematic; very new function; 2019B needed
syms qinmatt(t) [nd nq]
qinmatt = formula(qinmatt); % needed, due to symfun as result of syms

% needed for substitute functions
nr_list=cell(1,nq); % List with numbers as strings of internal gen coos
for idx=1:nq
    nr_list{1,idx} = int2str(idx);
end

% change external variables to internal ones AND make time dependent
mat = subs(mat,qmat,qinmatt);

% Diff
mat_dot = diff(mat,t);

% change unknown diffs to qd
for idx=1:nd-1
    not_dot = {int2str(idx)}; % diff( q of current row (t), t) to ...
    dot = {int2str(idx+1)};   % qdot, which is the next row in the qmat
    if nq==1 % if only one q is involved the naming scheme is a bit changed
        not_dot_str = strcat({'diff(qinmatt'},not_dot,{'(t), t)'});
        dot_str     = strcat({'qinmatt'}     ,dot    ,{'(t)'}    );
    else
        not_dot_str = strcat({'diff(qinmatt'},not_dot,{'_'},nr_list,{'(t), t)'});
        dot_str     = strcat({'qinmatt'}     ,dot    ,{'_'},nr_list,{'(t)'}    );
    end
    mat_dot = subs(mat_dot,str2sym(not_dot_str),str2sym(dot_str));
end

% neglect time dependency AND substitute internal q's with requested q's
mat_dot = subs(mat_dot,qinmatt,qmat);

end




