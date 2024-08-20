function out = manipulator_calc(a, alpha, d, theta, DH_mod_act, m, CoM, Inertia, varargin) 
%This function calculates the symbolic matrices of a robot manipulator arm 
%based on the DH-Parameters and the inertia parameters. A vehicle can be 
%specified and the function is then also calculating the update for this 
%due to the manipulator on top. 
%
% Inputs:
%
% a, alpha, d, theta = DH-Parameter of robot arm; if modified DH set
%   DH_mod_act to true; Input in [1 x nal] (nal = Number of all links).
%   d and theta contain symbolic variables, e.g. d= [0 d2 0]; theta= [q1 0 q3];
%   The algorithm searches these and uses them as generalized coordinates.
%   But you can also specify a vector of generalized coordinates with 'aq'
%   option, if a static link has a symbolic variable.
% DH_mod_act = Bool set to true if modified DH-parameter
% m = array with link masses of robot arm; size [1 x nal]
% CoM = matrix with columns are position vectors of center of masses in
%   Link frame; Make sure that this fits to your DH-parameter!!; [3 x nal]
%   If this is empty the CoMs are estimated in the middle of the links;
%   except if modified DH-Parameters are used, there the last CoM is put in
%   the joint.
% Inertia = Inertias of the links; rotation is assumed to be the same as 
%   link frame! Make sure this fits your DH-Parameter. Input is either in 
%   3. dimension concated inertia matricies; so size=[3,3,nal] or a matrix
%   with [Ixx Iyy Izz Ixy Ixz Iyz]' as columns and size [6 x nal]. If
%   inertia is empty, the code 'estimates' the inertia (old style, actually
%   wrong, I think). Only usable if vehicle is active, so TF_veh_arm option is
%   set and this forces alt_act option true.
%
% varargin in options:
% use in function call like: ..., 'option name', value, ...
% TF_veh_arm = Transformation matrix from vehicle frame to robot arm base frame.
%   So location of robot base expressed in vehicle frame. Use this to
%   activate the vehicle, otherwise the code just computes the manipulator
%   matrices.
% vq = array with symbolic variables which are the names of the generalized
%   coordinates of the vehicle e.g. [x_vehicle y_vehicle angle_of_vehicle]
%   default is [x y phi]
% vqd = array with symbolic variables which are the names of the 
%   derivatives of the generalized coordinates of the vehicle e.g. 
%   [x_vehicle_dot y_vehicle_dot angle_of_vehicle_dot]; if vq is specified
%   also vqd must be there; default is [xd yd phid]
% aq = array with symbolic variables which are the names of the generalized
%   coordinates of the arm e.g. [link_q1 d2 EE_link]; These symbolic 
%   variables need to appear in the theta or d vector. However the order of 
%   the output mass matrix is always specified by the link order, so DH-para.
%   It is internally necessary that the variables in aq have the same order
%   as the links. Default are the collected symbolic variables in d and 
%   theta, in link order, e.g. [d1 q2 d3 q4]
% aqd = array with symbolic variables which are the names of the 
%   derivatives of the generalized coordinates of the arm e.g. 
%   [link_q1_dot d2_dot EE_link_d]; if aq is specified also aqd must be
%   there; default is the collected symbolic variables with a trailing 'd',
%   e.g. [d1d q2d d3d q4d]
% calc = char array determining what to calculate, e.g. 'M C'. Default is 
%   'all' = 'T_A_EE M C G J'. With the vehicle active these matrices are 
%   the extended ones. If one wants the components please set 'components',
%   which means 'T_A_EE Mu Mav Ma Jv Ja Vv Va'. One can also choose some
%   from these two lists, or 'all components', which calculates all from 
%   both lists. T_A_EE is the forward kinematics and always calculated, 
%   however if not included in the list it does not appear in the output 
%   struct. C automatically enables M. Currently with the vehicle the
%   components of C and G cannot be calculated, only full C and G.
%   Furthermore, 'T_S_I' can be specified which outputs T_A_I or 
%   T_W_I = T_W_A.*T_A_I, depending on the vehicle. This is the 3D 
%   stacked matrix of the transformations from the individual link frames
%   to the world frame. So all the frames along the TF chain, incl. static
%   ones. Similar 'J_S_I' can be set, which are the 3D stacked Jacobians to
%   the link frames. Whereas, here for the vehicle x, y and phi are three
%   individual Jacobians and static frames are removed.
% C_mat = If true the Coriolis part is calculated as matrix (default), set
%   false to calculate the vector.
% save_fct = char array determining which matrix to save as matlab 
%   function, e.g. 'M C'. Default is empty, but you can again choose from 
%   'T_A_EE M C G J' = 'all', 'T_A_EE Mu Mav Ma Jv Ja Vv Va' = 'components',
%   'T_S_I' or 'J_S_I'
% (save_split = DEPRECIATED char array determining which matrix to save in elementwise
%   matlab functions, e.g. 'M C'. Default is empty, but you can again 
%   choose from 'T_A_EE M C G J' = 'all'. If update only is enabled it 
%   saves Mu and Mav instead of M, and V_v and V_a instead of J. Matrices
%   specified in this array override save_fct. So you can set save_fct =
%   'all' and save_split = 'C', to save all matricies as functions, except
%   C is saved elementwise. The elementwise matlab functions are saved in a
%   folder named 'filename_prefix MATRIX_NAME'.)
% path = char array used as path to the location where to write the output.
% filename_prefix = char array used as prefix for filenames while saving  
%   output, e.g. 'get_' results in filenames 'get_M.m'.
% debug = Set to true if you want some not understandable debug output
%   (default is false) and the parallel pool stays alive!
% quiet = Set to true if you don't want to see all the printed information.
%   default is false; Errors and Warnings are always displayed; debug
%   forces true;
% M_alg = if true another algorithm for calculating the Mass matrix is
%   used:
%   False is default, which means calculate all the energies and
%   then differentiate twice with respect to the velocities to get mass 
%   matrix (E=1/2 m v^2). This is Euler-Lagrange approach in moving frames.
%   With this also the inertia_estimate and the alt_act option are usable.
%   It seems that this approach is better for large robots.
%   True means use Euler-Lagrange approach in fixed frame with calculating 
%   the partial Jacobians and then directly the mass matrix with 
%   M = m*J^T*J + J^T*I*J
% alt_act = set to true if you want to use an alternative way for calculating
%   the translatory energy (slower?); Is forced true if no inertia specified;
%   and is forced false if M_alg is true.
% (desired_digits = DEPRECIATED specifiy the desired digits for the calculations;
%   default is 4, because this is really heavy calculations for big robots)
des_digits_default = 4;
% optimize = default is 4; higher values include what lower values do: 
%   0 = no optimization all elements are calculated
%   1 = only the lower left corner of the mass matrix is calculated, the 
%       upper half is generated by using the symmetry of mass matricies
%   2 = start from 2. row, since M(1,1) = M(2,2) (for vehicle active only)
%   3 = start from 3. row, since translatory mass is sum of robot arm 
%       masses (for vehicle active only)
%   4 = determine highest usable level automatically
% fileopt_act = bool, default is false. Determine if save to .m file should
%   optimize the function. Takes longer, but can also help to generate C
%   code, there its always active.
% filec_act = bool, default is false. Output C code function additionally
%   to mat file if true. fileopt_act has no influence, so might not terminate!
% file_pct_act = use Parallel Computing Toolbox (PCT) for output code 
%   generation. This uses the PC better with big robots, if code generation
%   is active. Default is 2.
%   0 = no PCT used
%   1 = always use PCT
%   2 = determine automatically: (na = number of generalized coordinates)
%       - only use if file output is also active and ...
%       - don't use PCT for na<=parallel_low
%       - don't use PCT for na<=parallel_high and no parallel pool already
%         generated
%       - if na>parallel_high always use parallel toolbox and try to start
%         own parallel pool
parallel_low = 4;  %if na lower than this value never use parallel computing
parallel_high = 6; %if na lower than this value use parallel computing if a pool is running already
% simplify_act = use of simplify(). If you use it for the output be aware 
%       of that it is nearly unsolvable for big systems; default is 3
%   0 = Very few simplifies used and only easily terms
%   1 = simplify also some things at beginning, e.g. TFs
%   2 = simplify outout, too, which can take very long
%   3 = determine automatically: (na = number of generalized coordinates)
%       - use simplify==2 for na<=simplify_th; =small robot
%       - use simplify==1 for na>simplify_th;  =big robot
%   (-1 = Use PCT for M, forces level 2; DEPRECIATED)
simplify_th = 4; %if na lower than this value use simplify

% Output: 
%
% Output is a struct called out, where the calculated matrices are included
% like e.g. out.M . 
%
% The forward kinematics is added as T_A_EE if calculation of it is 
% requested (see calc option). 
%
% M is a mass matrix. If no vehicle specified then the M matrix is always a
% full standard mass matrix of the robot arm. If vehicle is specified 
% (TF_veh_arm option set) then the calculated mass matrix can be decomposed like:
% M = [Mu  Mva]
%     [Mav Ma ]
% Where Mu is the update of the vehicle mass matrix due to the robot arm;
% size 3x3 with [x y phi] order. Mav=Mva' is the coupeling matrix between
% vehicle and arm, and Ma is the standard full robot arm mass matrix
% (except if inertias are not specified, then these are missing of course).
%
% C can either be vector or matrix of Coriolis part, depending on C_mat
% option. If update only is true it is calculated with 
% M = [Mu  Mva]
%     [Mav 0  ]
% Meaning again that it is only the update parts, but concatinated in one
% matrix or vector.
%
% J is the geometric Jacobian matrix. If the vehicle is enabled it is the
% full Jacobian calculated like J = [V_v*J_v  V_a*J_a], which means both
% parts are already updated. The update only option returns V_v and V_a
% only.
%
% Future work:
%
% aq: Sorting of output gen coos, still not possible (due to link_type is
%   carriing the info and looped through always, so order is dependent on
%   DH parameter order. ??
% Check if matlab 2018 and previous can do the job; dynamic syms ??
% Extend with multi robot feature !!! wrapper function, that calls this multiple times
% Allow other vehicle frame system (not z upwards) ??
%   -> calc internally with 3d and cut finally; -not effcient/possible
%   -> orientation problems with three angles!
% Add vehicle energy with vehicle mass, CoM and Inertia? -> "If no update"
%   -> lot of input issues !!
%   -> can calculate CoM update due to robot !?
%   -> can calc new inertia due to robot ?!
%   -> watch out at optimizer!!
% (Repair the CoM estimate; currently only working for mod DH?)
% GUI??!!
%
%
% Internal used frame naming scheme:
%
% T_1_2 = TF from 1 to 2
% _W = Worldframe
% _V = Vehicle frame (= CoM vehicle, actually not neccessarily, I think)
% _A = Robot arm (base) frame
% _I = Parts of arm frames = link frames
% _I1= Part i-1 of arm frames = last link in loops
% _S = Start frame for energy calculations; specified in comments (mostly A or V)
% gen coo = generalized coordinates

%% IO Check and init
%Start stopwatch
tic;

% first check Matlab version due to dynamic syms
if verLessThan('matlab','9.7')
    error('At least Matlab 2019B is required.')
end

% Check basic inputs
idx = 1;
validateattributes(a,{'numeric','sym'},{'vector','nonnan','finite','real'},'','DH-Parameter a',idx);
idx = idx+1;
if size(a,1)>size(a,2) %lay vector 
    a = a.';
end
nal = size(a,2); %Number of all arm LINKS
if isa(a,'numeric') %force symbolic
    a = sym(a);
    a_var = [];
else
    a_var = symvar(a);
    if numel(a_var)==nal
        a_var = a;
    end
    assumeAlso(a,'real')
end

validateattributes(alpha,{'numeric','sym'},{'vector','nonnan','finite','real','numel', nal},'','DH-Parameter alpha',idx);
idx = idx+1;
if size(alpha,1)>size(alpha,2) %lay vector 
    alpha = alpha.';
end
if isa(alpha,'numeric') %force symbolic
    alpha = sym(alpha);
    alpha_var = [];
else
    alpha_var = symvar(alpha);
    if numel(alpha_var)==nal
        alpha_var = alpha;
    end
    assumeAlso(alpha,'real')
end

validateattributes(d,{'numeric','sym'},{'vector','nonnan','finite','real','numel', nal},'','DH-Parameter d',idx);
idx = idx+1;
if size(d,1)>size(d,2) %lay vector 
    d = d.';
end
if isa(d,'numeric') %force symbolic
    d = sym(d);
    d_var = [];
else
    d_var = symvar(d);
    if numel(d_var)==nal
        d_var = d;
    end
    assumeAlso(d,'real')
end

validateattributes(theta,{'numeric','sym'},{'vector','nonnan','finite','real','numel', nal},'','DH-Parameter theta',idx);
idx = idx+1;
if size(theta,1)>size(theta,2) %lay vector 
    theta = theta.';
end
if isa(theta,'numeric') %force symbolic
    theta = sym(theta);
    theta_var = [];
else
    theta_var = symvar(theta);
    if numel(theta_var)==nal
        theta_var = theta;
    end
    assumeAlso(theta,'real')
end

validateattributes(DH_mod_act,{'logical'},{'scalar','binary'},'','DH-Parameter modified boolean (DH_mod_act)',idx);
idx = idx+1;

validateattributes(m,{'numeric','sym'},{'vector','nonnan','finite','real','numel', nal},'','Mass m',idx);
idx = idx+1;
if size(m,1)>size(m,2) %lay vector 
    m = m.';
end
if isa(m,'numeric') %force symbolic
    validateattributes(m,{'numeric'},{'nonnegative'},'','Mass m',idx);
    m_i = sym(m);
else
    assumeAlso(m,'real') 
    assumeAlso(m >= 0) 
    m_i = m; % better understandable code later
end
%output vars
if isa(m,'numeric') 
    m_var = [];
else
    m_var = symvar(m);
    if numel(m_var)==nal
        m_var = m;
    end
end

validateattributes(CoM,{'numeric','sym'},{'2d','nonnan','finite','real'},'','CoM matrix (CoM)',idx);
idx = idx+1;
% Check CoM input; If none given estimate them in the middle of the links
if isempty(CoM)
    CoM_est_act = true;
    warning('No CoMs given => estimate in middle of links.');
    if DH_mod_act
        warning('Except last link, because of modified DH-parameters do not provide the length information. (Set in joint instead)');
    end
    CoM_i_I = sym([zeros(3,nal);ones(1,nal)]);
else
    CoM_est_act = false;
    if size(CoM,1)~=3 && size(CoM,2)~=3 % Check for one side 3 elements 
        error('CoM must be a matrix with size either 3 x nal or nal x 3.');
    end
    if size(CoM,1)~=3 %ensure 3xnal 
        CoM = CoM.';
    end
    if size(CoM,2)~=nal %check nal length
        error('CoM must be a matrix with size either 3 x nal or nal x 3.');
    end
    if isa(CoM,'numeric') %force symbolic
        CoM_i_I = sym([CoM;ones(1,nal)]);
    else
        assumeAlso(CoM,'real') 
        CoM_i_I = [CoM;sym(ones(1,nal))];
    end
end
%output vars
if isa(CoM,'numeric') %CoM_est_act case at the output generation
    CoM_var = [];
else
    CoM_var = symvar(CoM);
    if numel(CoM_var) == (3*nal)
        CoM_var = CoM;
    end
end

validateattributes(Inertia,{'numeric','sym'},{'3d','nonnan','finite','real'},'','Inertia matrix (Inertia)',idx);
% idx = idx+1;
% determine input way of inertia if not estimate
inertia_in = 0;
if ~isempty(Inertia)
    if size(Inertia,3) > 1 || (size(Inertia,1)==3 && size(Inertia,2)==3) % 3d input or just one joint
        inertia_in = 3;
        if size(Inertia,1)~=3 || size(Inertia,2)~=3 || size(Inertia,3)~=nal
            error('Size of inertia not correct! 3D matrix input: 3x3 inertia matricies stacked in third dimension. Third dimension has number of links size.');
        else
            if isa(Inertia,'numeric') %force symbolic
                Inertia_i_I = sym(Inertia);
            else
                Inertia_i_I = Inertia;
            end
        end
    else % 2d input
        inertia_in = 2;
        if size(Inertia,1)~=6 && size(Inertia,2)~=6 % Check for one side 6 elements 
            error('Size of inertia not correct! Matrix with [Ixx Iyy Izz Ixy Ixz Iyz] as columns and size [6x Number of links].');
        end
        if size(Inertia,1)~=6 %ensure 6xnal 
            Inertia = Inertia.';
        end
        if size(Inertia,2)~=nal %check nal length
            error('Size of inertia not correct! Matrix with [Ixx Iyy Izz Ixy Ixz Iyz] as columns and size [6x Number of links].');
        end
        Inertia_i_I = sym(zeros(3,3,nal));
        if isa(Inertia,'numeric') %force symbolic
            Inertia_int = sym(Inertia);
        else
            Inertia_int = Inertia;
        end
        for jdx=1:nal
            Inertia_i_I(1,2,jdx) = Inertia_int(4,jdx); % fill upper left corner
            Inertia_i_I(1,3,jdx) = Inertia_int(5,jdx);
            Inertia_i_I(2,3,jdx) = Inertia_int(6,jdx);
            Inertia_i_I(:,:,jdx) = Inertia_i_I(:,:,jdx) + Inertia_i_I(:,:,jdx).'; % flip to lower right corner
            Inertia_i_I(:,:,jdx) = Inertia_i_I(:,:,jdx) + diag(Inertia_int(1:3,jdx)); % Add diagonal elements
        end
        clear Inertia_int
    end
end
%output vars
if isa(Inertia,'numeric') %Inertia_est_act case at the output generation
    Inertia_var = [];
else
    Inertia_var = symvar(Inertia);
    if (inertia_in == 2 && numel(Inertia_var) == (6*nal)) || ...
       (inertia_in == 3 && numel(Inertia_var) == (9*nal))
        Inertia_var = Inertia;
    end
end
clear inertia_in

narginchk(8,52);
% define parser and add arguments
iparser = inputParser;
addOptional(iparser,'debug',false,@(x)validateattributes(x,{'logical'},{'scalar','binary'}));
addOptional(iparser,'quiet',false,@(x)validateattributes(x,{'logical'},{'scalar','binary'}));
addOptional(iparser,'vq',0,@(x)validateattributes(x,{'sym'},{'vector','numel', 3}));
addOptional(iparser,'aq',0,@(x)validateattributes(x,{'sym'},{'vector','numel', nal}));
addOptional(iparser,'filename_prefix','',@(x)validateattributes(x,{'string','char'},{'scalartext'}));
%5
addOptional(iparser,'alt_act',false,@(x)validateattributes(x,{'logical'},{'scalar','binary'}));
addOptional(iparser,'optimize',4,@(x)validateattributes(x,{'numeric'},{'scalar','integer','>=', 0,'<=', 4}));
addOptional(iparser,'file_pct_act',0,@(x)validateattributes(x,{'numeric'},{'scalar','integer','>=', 0,'<=', 2}));
addOptional(iparser,'simplify_act',3,@(x)validateattributes(x,{'numeric'},{'scalar','integer','>=', -1,'<=', 3}));
addOptional(iparser,'desired_digits',des_digits_default,@(x)validateattributes(x,{'numeric'},{'scalar','integer','nonnan','finite','positive'}));
%10
addOptional(iparser,'TF_veh_arm',[],@(x)validateattributes(x,{'numeric','sym'},{'2d','nonnan','finite','real'}));
addOptional(iparser,'M_alg',false,@(x)validateattributes(x,{'logical'},{'scalar','binary'}));
addOptional(iparser,'update_only',false,@(x)validateattributes(x,{'logical'},{'scalar','binary'}));
addOptional(iparser,'C_mat',true,@(x)validateattributes(x,{'logical'},{'scalar','binary'}));
addOptional(iparser,'vqd',0,@(x)validateattributes(x,{'sym'},{'vector','numel', 3}));
%15 
addOptional(iparser,'aqd',0,@(x)validateattributes(x,{'sym'},{'vector','numel', nal}));
addOptional(iparser,'fileopt_act',false,@(x)validateattributes(x,{'logical'},{'scalar','binary'}));
addOptional(iparser,'path','',@(x)validateattributes(x,{'string','char'},{'scalartext'}));
addOptional(iparser,'save_fct','',@(x)validateattributes(x,{'string','char'},{'scalartext'}));
addOptional(iparser,'save_split','',@(x)validateattributes(x,{'string','char'},{'scalartext'}));
%20
addOptional(iparser,'calc','all',@(x)validateattributes(x,{'string','char'},{'scalartext'}));
addOptional(iparser,'filec_act',false,@(x)validateattributes(x,{'logical'},{'scalar','binary'}));

% do parsing and store results
parse(iparser,varargin{:});
debug = iparser.Results.debug;
quiet = iparser.Results.quiet;
vq = iparser.Results.vq;
vqd = iparser.Results.vqd;
aq = iparser.Results.aq; %set numeric 0 as default, but input must be sym
aqd = iparser.Results.aqd; %set numeric 0 as default, but input must be sym
path = iparser.Results.path;
filename_prefix = iparser.Results.filename_prefix;
alt_act = iparser.Results.alt_act;
optimize = iparser.Results.optimize;
file_pct_act = iparser.Results.file_pct_act;
simplify_act = iparser.Results.simplify_act;
des_digit = iparser.Results.desired_digits;
TF_veh_arm = iparser.Results.TF_veh_arm;
M_alg = iparser.Results.M_alg;
%update_act = iparser.Results.update_only;
C_mat_act = iparser.Results.C_mat;
calc = iparser.Results.calc;
fileopt_act = iparser.Results.fileopt_act;
save_fct = iparser.Results.save_fct;
save_split = iparser.Results.save_split;
filec_act = iparser.Results.filec_act;

% if debug it cannot be quite
if debug
    quiet = false;
end

% A bit of information for the user
if ~quiet
    disp('Initialize dynamics calculation function. Start with IO-check ...');
end

% some basic vars
digits(des_digit); %digits for vpa()
uz = sym([0;0;1]); % a z-axis
r = 1:3; % for cutting rotation parts out of TFs; Rot = TF(r,r) 
nul = sym(0); % a symbolic zero for some inits

% Check TF_veh_arm input; if empty => no vehicle
if isempty(TF_veh_arm)
    if ~quiet
        disp('No TF_veh_arm given => No Vehicle assumed.');
    end
    vehicle_act = false;
    T_V_A = [];
else
    if isa(TF_veh_arm,'numeric') %force symbolic
        T_V_A = sym(TF_veh_arm);
    else
        T_V_A = TF_veh_arm;
        assumeAlso(T_V_A,'real') 
    end
    if ~iseukltrans(T_V_A)
        error('TF_veh_arm is not a valid transformation matrix.');
    end
    vehicle_act = true;
end
%output vars
if isa(TF_veh_arm,'numeric') 
    TF_veh_arm_var = [];
else
    TF_veh_arm_var = symvar(TF_veh_arm);
    if numel(TF_veh_arm_var) == 12 %Rot matrix and Pos vector
        TF_veh_arm_var = TF_veh_arm(r,:);
    end
end

% % Check update only option
%%%% old; only for user choice
% if ~vehicle_act && update_act
%     disp('Update_only option only possible if vehicle active (=TF_veh_arm is set correctly). Ignoring now.')
%     update_act = false;
% end

% What to calc? 
% Check group input
if isempty(calc) || contains(calc,'all') %strcmp(calc,'all')
    calc = [calc ' T_A_EE M C G J '];
end
if contains(calc,'components') %strcmp(calc,'components')
    if vehicle_act
        calc = [calc ' T_A_EE Mu Mav Ma Jv Ja Vv Va '];
    else
        warning('Cannot calculate components, because vehicle not active. Ignoring now.');
    end
end

% Specify settings
calc = [calc ' ']; % append empty space for checks
if contains(calc,'T_A_EE')
    T_A_EE_calc_act = true;%actually always calculated. Only output or not determined here
else
    T_A_EE_calc_act = false;
end
if contains(calc,'M') %|| contains(calc,'Ma') %incl.
    M_calc_act = true;
else
    M_calc_act = false;
end
if vehicle_act && ~contains(calc,'M ') && ~contains(calc,'Ma ')
    update_act = true;
else
    update_act = false;
end
if contains(calc,'C')
    if M_calc_act == false
        warning('Calculation of C requested, therefore calculation of M forced.');
        calc = [calc ' M '];
        M_calc_act = true;
    end
    C_calc_act = true;
else
    C_calc_act = false;
end
if contains(calc,'G')
    G_calc_act = true;
else
    G_calc_act = false;
end
if contains(calc,'J ')
    J_calc_act = true; 
else
    J_calc_act = false;
end
if contains(calc,'J ') || contains(calc,'Ja')
    Ja_calc_act = true; 
else
    Ja_calc_act = false;
end
if vehicle_act
    if contains(calc,'J ') || contains(calc,'Jv')
        Jv_calc_act = true; 
    else
        Jv_calc_act = false;
    end
    if contains(calc,'J ') || contains(calc,'Vv')
        Vv_calc_act = true; 
    else
        Vv_calc_act = false;
    end
    if contains(calc,'J ') || contains(calc,'Va')
        Va_calc_act = true; 
    else
        Va_calc_act = false;
    end
else
    Jv_calc_act = false;
    Vv_calc_act = false;
    Va_calc_act = false;
end
if contains(calc,'T_S_I ') %Actually T_A_I or T_W_I = T_W_A.*T_A_I
    TSI_calc_act = true; 
else
    TSI_calc_act = false;
end
if contains(calc,'J_S_I ') %Jacobians to all links, not calculated before
    JSI_calc_act = true;
else
    JSI_calc_act = false;
end

if ~T_A_EE_calc_act && ~M_calc_act   && ~C_calc_act  && ~G_calc_act  && ...
        ~J_calc_act && ~Ja_calc_act  && ~Jv_calc_act && ~Vv_calc_act && ~Va_calc_act && ...
      ~TSI_calc_act && ~JSI_calc_act
    error('Nothing to calculate?! Choice is case sensitive!');
end

% What to save as function?
if contains(save_fct,'all')
    save_fct = 'T_A_EE M C G J';
end
if contains(save_fct,'components') %strcmp(calc,'components')
    if vehicle_act
        save_fct = [save_fct ' T_A_EE Mu Mav Ma Jv Ja Vv Va '];
    else
        warning('Cannot save components, because vehicle not active. Ignoring now.');
    end
end
save_fct = [save_fct ' ']; % append empty space for checks
% if contains(save_fct,'M') && update_act
%     save_fct = [save_fct ' Mu Mav']; %Add parts if only update
% end
% if contains(save_fct,'J') && update_act
%     save_fct = [save_fct ' V_v V_a']; %Add parts if only update
% end

% What to save as split functions?
if strcmp(save_split,'all')
    save_split = 'T_A_EE M C G J';
end
% if contains(save_split,'M') && update_act
%     save_split = [save_split ' Mu Mav']; %Add parts if only update
% end
% if contains(save_split,'J') && update_act
%     save_split = [save_split ' V_v V_a']; %Add parts if only update
% end

% Check path
path = fullfile(path);
% Append \ or / to path 
if ~isempty(path) && ~strcmp(path(end),filesep)
    path = [path filesep];
end

% Check Inertia input; If none given consider static robot on vehicle
if isempty(Inertia)
    if vehicle_act
        Inertia_est_act = true;
        alt_act = true;
        M_alg = false;
        warning('No Inertias given => estimate with static robot. And force alt_act version (due to wrong omega_i_I) and M_alg=false');
    else
        error('No Inertias given AND vehicle deactivated => Makes no sense, sorry.');
    end
else
    Inertia_est_act = false;
end

% Check alt_act
if alt_act && M_alg
    warning('M_alg and alt_act cannot be used together. => deactivating alt_act.');
end

% Check vq
if vehicle_act
    if isnumeric(vq) && isnumeric(vqd)
        vq_act = false;
    elseif ~isnumeric(vq) && ~isnumeric(vqd)
        vq_act = true;
    else
        warning('If vq is specified vqd is also needed! Ignoring now.');
        vq_act = false;
    end
    if size(vq,1)>size(vq,2) %lay vector 
        vq = vq.';
    end
    if size(vqd,1)>size(vqd,2) %lay vector 
        vqd = vqd.';
    end
else
    vq_act = false;
end

% Check aq
if isnumeric(aq)
    aq_act = false;
else
    if size(aq,1)>size(aq,2) %lay vector 
        aq = aq.';
    end
    if size(aqd,1)>size(aqd,2) %lay vector 
        aqd = aqd.';
    end
    aq_act = true;
end

% Determine link type
link_type = zeros(1,nal); % Vector for determining type of arm links
if aq_act
    na = size(aq,2); % Number of gen coos of arm
    % search elements of aq in theta and d;
    % First element of aq is internally q1; -> sorting of elements
    for idx=1:na
        hits = 0; %remembers number of found elements
        hit = 0;  % memorizes jdx
        hit_d = false; %true if hit was in d
        for jdx=1:nal
            if theta(jdx) == aq(idx) % check theta
                hit = jdx;
                hits = hits+1; 
                % no break to find double elements
            end
            if d(jdx) == aq(idx) % check d
                hit = jdx;
                hit_d = true;
                hits = hits+1; 
                % no break to find double elements
            end
        end
        % Check findings
        if hits == 0
            error(['Element ' aq(idx) ' of aq not found in theta nor d!']);
        elseif hits > 1
            error(['Element ' aq(idx) ' of aq multiple times in theta or d!']);
        end
        % determine link_type
        if hit_d
            link_type(hit) = 2; %hit in d => prismatic joint
        else 
            link_type(hit) = 1; %hit in theta => revolute joint
            % no hit not possible!! => so rest of joints is static
        end
    end
else
    na = 0; % Number of gen coos of arm
    for idx=1:nal                       % If d or theta contains a number symvar is not possible (=empty)
                                        %   => so this is not a generalized coordinate
        if ~isempty(symvar(theta(idx))) % Type 1 = revolute joint
            link_type(idx) = 1;
            na = na + 1;
        elseif ~isempty(symvar(d(idx))) % Type 2 = prismatic joint
            link_type(idx) = 2;
            na = na + 1;
        else
            link_type(idx) = 0;         % Type 0 = no joint = static part/link
        end
    end
end
if na == 0
    warning('Number of generalized coordinates is zero?! => Static robot?');
end
clear hit hit_d hits

% Problem with EE Jacobian calc and modified DH:
if ~quiet && link_type(end)>0 && Ja_calc_act && DH_mod_act
    disp('====HINT====');
    disp('You have choosen to calculate the geometric Jacobian from modified DH-parameters, ');
    disp('but the last link is not static. This means the algorithm is not calculating the ');
    disp('Jacobian to the End-Effector, since the last link length is not included in this ');
    disp('set of DH-Parameters. If you want to include it add an additional static link as');
    disp('final link with the final link length.');
    disp('============');
end  
 
% Force PCT at simplify 
if simplify_act==-1
    if ~hasParallelToolbox()
        warning('No Parallel Computing Toolbox found. Cannot use pct_simplify_act==1.');
        pct_simplify_act=0;
        simplify_act=3; %Choose automatic
    else
        pct_simplify_act=1;
        simplify_act=2; %Must force level 2
    end
else
    pct_simplify_act=0;
end
% Determine simplify_act level if automatic set
if simplify_act==3
    if na<=simplify_th 
        simplify_act=2; % if small number of gen coo, simplify possible
    else
        simplify_act=1; % otherwise better only TFs
    end
end

% check optimize level:
if simplify_act==0 && M_alg
    if optimize==1 || optimize==2 || optimize==3
        warning('Cannot use optimize, due to M_alg active AND no simplify. (no reason for optimize)');
    end
    optimize=0;
else
    if optimize==2 || optimize==3
        if ~vehicle_act
            warning('Cannot set optimize level 2 or 3, due to no vehicle. Using level 1 instead.');
            optimize=1;
        end
    elseif optimize>=4
        if vehicle_act
            optimize=3;
        else
            optimize=1;
        end
    end
end

% Set file_pct_act status
if file_pct_act==1 
    if isempty(save_fct)% Test for usable
        warning('Cannot use PCT at file output since no output.');
        file_pct_act=0;
    end
    if ~hasParallelToolbox()% Test for parallel computing
        warning('Cannot use PCT at file output since no Parallel Computing Toolbox found.');
        file_pct_act=0;
    end
elseif file_pct_act==2 
    if ~hasParallelToolbox() || isempty(save_fct)
        file_pct_act=0;
    end
    if file_pct_act==2 %%%sry bad programming
        if na<=parallel_low 
            file_pct_act=0; % if small number of gen coo; do not use parallel computing
        elseif na<=parallel_high && isempty(gcp('nocreate'))
            file_pct_act=0; % if small number of gen coo and new parallel pool would need to start; no parallel computing
        else
            file_pct_act=1; % else use parallel computing
        end
    end
end

%% init
% A bit of information for the user
if ~quiet
    disp('Continue with initialize other variables ...');
end

if vehicle_act
    nv = 3; % number of vehicle DoF (x y phi)
else
    nv = 0;
end
nva = nv + na; % all DoF vehicle + arm (=output size)
nval = nv + nal; % all Links + vehicle dof

if debug
    disp(['debug: nal: ' int2str(nal) '; na: ' int2str(na) '; nv: ' int2str(nv)]);
end

% set helper vars for M calc
if update_act
    M_end = nv; % If update only => only first 3 columns are calculated
else
    M_end = nva;
end
% optimize by leaving out some parts and using knowledge about update matrix
if optimize==0
    M_start = 1;
elseif optimize==1
    M_start = 1;
elseif optimize==2
    M_start = 2;
elseif optimize>=3
    M_start = 3;
end

% syms ALL variables as internal vars and only at output replace with
% requested input vars from d, theta and vq!

% vehicle
if vehicle_act
    % If no update:
    % syms m_v 
    % syms CoM_v [3 1]
    % syms Inertia_v [3 3]

    syms x  y  phi   real
    syms xd yd phid  real

    % location of vehicle in world 3D
    T_W_V = sym([ ...
        cos(phi), -sin(phi), 0, x
        sin(phi),  cos(phi), 0, y
        0,         0,        1, 0
        0,         0,        0, 1 ]);
    % location of Robot base in world 3D
    T_W_A = T_W_V * T_V_A;
    if simplify_act>=1
        if ~quiet
            disp('Simplify T_W_A matrix ...');
        end
        T_W_A = simplify(T_W_A);
    end   
end

% robot 
% This part here is problematic; very new functions; 2019B needed
qin = sym(zeros(1,na)); %just for init
syms qin [1 na] real
qdin = sym(zeros(1,na)); %just for init
syms qdin [1 na] real

% Extend internal vars with sym(0) for static links
% And put internal numbered qs at correct places
qine = sym(zeros(1,nal));
qdine = sym(zeros(1,nal));
jdx = 1;
for idx=1:nal
    if link_type(idx)~=0
        qine(idx) = qin(jdx);
        qdine(idx) = qdin(jdx);
        jdx = jdx + 1;
    end
end
% check:
if debug
    disp(['debug: jdx-1-na: ' int2str(jdx-1-na) '; should be 0']);
end

% change external d and theta to internal
din = d;
thetain = theta;
qext = sym(zeros(1,na)); %collect external names for substitute later
qdext = sym(zeros(1,na)); %collect external names for substitute later
jdx = 1;
for idx=1:nal
    switch link_type(idx)
        case 0
            
        case 1
            thetain(idx) = qine(idx);
            qext(jdx) = theta(idx);
            if aq_act
                qdext(jdx) = aqd(jdx);                
            else
                qdext(jdx) = sym([char(symvar(theta(idx))) 'd']);
            end
            jdx = jdx + 1;
        case 2
            din(idx) = qine(idx);
            qext(jdx) = d(idx);
            if aq_act
                qdext(jdx) = aqd(jdx);
            else
                qdext(jdx) = sym([char(symvar(d(idx))) 'd']);
            end
            jdx = jdx + 1;
    end
end
% check:
if debug
    disp(['debug: jdx-1-na: ' int2str(jdx-1-na) '; should be 0']);
end

% build vector with all gen coo velocities for derivatives
if vehicle_act
    xqin = [x y phi qin];
    xqdin = [xd yd phid qdin];
else
    xqin = qin;
    xqdin = qdin;
end  

%% TFs and CoMs calc
% A bit of information for the user
if ~quiet
    disp('Calculate TFs and CoMs ...');
end

% TFs and position vectors of robot
T_I1_I = sym(zeros(4,4,nal));
T_A_I = sym(zeros(4,4,nal));
for idx = 1:nal
    % Calc transformation to next link
    if DH_mod_act
        T_I1_I(:,:,idx) = HomogeniusTransformMatrix_modifiedDH(a(idx),alpha(idx),din(idx),thetain(idx));
    else
        T_I1_I(:,:,idx) = HomogeniusTransformMatrix(a(idx),alpha(idx),din(idx),thetain(idx));
    end
    
    if idx==1 %First link is a bit different
        T_A_I(:,:,idx) = T_I1_I(:,:,idx); %base to first link frame
    else % other links
        T_A_I(:,:,idx) = T_A_I(:,:,idx-1)*T_I1_I(:,:,idx); %base to current link frame
    end
    
    % maybe simplify here??
    if simplify_act>=1
        if ~quiet
            fprintf('Simplify TF to %i. Link (%i/%i)\n', idx, idx, nal);
        end
        T_A_I(:,:,idx) = simplify(T_A_I(:,:,idx));
    end
    
end


% CoM to base with estimate if neccessary
CoM_i_A = sym(zeros(4,nal));
for idx = 1:nal
    if CoM_est_act %Estimate
        if DH_mod_act
            if idx==nal
                CoM_i_I(r,idx) = sym(zeros(3,1)); % For modified DH the last link CoM is set to its link position
            else
                CoM_i_I(r,idx) = sym(1/2)*T_I1_I(r,4,idx+1); %rest is in middle of the links
            end
        else
            %For standard DH all are set in the middle of the links
            % But need to be transformed to the link coo sys
            CoM_i_I(:,idx) = T_I1_I(:,:,idx)\ [(sym(1/2)*T_I1_I(r,4,idx));sym(1)]; 
        end
    end
    
    % shift CoM vector from Link frame to Base frame
    CoM_i_A(:,idx) = T_A_I(:,:,idx)*CoM_i_I(:,idx);
end
% check:
% if debug && simplify_act>=1
%     disp('CoM_i_I:');
%     simplify(CoM_i_I)
% end

%% Calculation of Geometric Jacobian J
% First manipulator Jacobian Ja
if Ja_calc_act
    if ~quiet
        if vehicle_act
            disp('Calculate geometric Jacobian Ja of manipulator ...');
        else
            disp('Calculate geometric Jacobian J ...');            
        end
    end            
    % The robot arm Jacobian is calculated as usual, relative to its arm
    % base frame A and maybe later updated due to vehicle.
    Ja = calc_jacobian(T_A_I(r,4,nal),nal,DH_mod_act,link_type,T_A_I);
    
    % Cut to neglect static links
    cut = logical(link_type);
    Ja = Ja(:,cut);
    clear cut
        
    if simplify_act>=2
        if ~quiet
            disp('Simplify Jacobian matrix ...');
        end
        Ja = simplify(Ja);
    end
end

% Secondly set vehicle Jacobian Jv
% only if vehicle; this is needed for M_alg active (the partial Jacobians)
if vehicle_act && (M_alg || Jv_calc_act || JSI_calc_act)
    if ~quiet
        disp('Set vehicle Jacobian Jv ...');
    end    
    % If there is a vehicle under the robot the stuff gets a bit more
    % complex. So the EE Jacobian needs to be extendend and updated
    % with the vehicle to get it projecting to world frame.
    % First the vehicle Jacobian is defined:
    Jv = sym(...
            [1 0 0
             0 1 0
             0 0 0
             0 0 0
             0 0 0
             0 0 1]);
end

% Third update for manipulator Jacobian Va
if vehicle_act && (M_alg || Va_calc_act || JSI_calc_act)
    if ~quiet
        disp('Set update for manipulator Jacobian Va ...');
    end    
    Va = J_frame_up(T_W_A);
    % simplify already done at T_W_A setting
end

if Vv_calc_act 
    if ~quiet
        disp('Calculate update for vehicle Jacobian Vv ...');
    end        
    % If there is a vehicle the jacobian needs to be updated
    % radius of EE while turning vehicle
    r_EE_V = T_V_A * T_A_I(1:4,4,nal);
    % Calculate update
    Vv = J_point_up(r_EE_V,T_W_V);
    clear r_EE_V
    
    if simplify_act>=2
        if ~quiet
            disp('Simplify Vv matrix ...');
        end
        Vv = simplify(Vv);
    end  
end

if J_calc_act  
    if vehicle_act  
        if ~quiet
            disp('Calculate geometric Jacobian J of mobile manipulator ...');
        end        
        % Set J of EE in World:
        J = [Vv*Jv  Va*Ja];
        if simplify_act>=2
            if ~quiet
                disp('Simplify J matrix ...');
            end
            J = simplify(J);
        end
    else
        J = Ja;
    end
end

if JSI_calc_act
    % First calc partial Jacobians of manipulator to each of its links
    J_A_I = sym(zeros(6,nal,nal));
    for idx=1:nal
        J_A_I(:,:,idx) = calc_jacobian(T_A_I(r,4,idx),idx,DH_mod_act,link_type,T_A_I);
    end
    if vehicle_act
        J_S_I = sym(zeros(6,nval,nval));
        for idx=1:nval
            if idx==1
                % updated partial Jacobian for vehicle x motion
                J_S_I(:,1,idx) = Jv(:,1);
            elseif idx == 2
                % updated partial Jacobian for vehicle y motion
                J_S_I(:,1:2,idx) = Jv(:,1:2);
            elseif idx == 3
                % updated partial Jacobian for vehicle rotation phi                
                J_S_I(:,1:3,idx) = Jv;
            else
                jdx = idx-3;
                % Then the update for the Jv:
                T_V_I = T_V_A * T_A_I(:,:,jdx);
                Vv_i = J_point_up(T_V_I,T_W_V);
                % updated partial Jacobian for vehicle due to Link_i rotation
                J_S_I(:,1:3,idx) = Vv_i * Jv;
                % update J_A_I = turn to world frame
                J_S_I(:,4:nval,idx) = Va * J_A_I(:,:,jdx);
            end
            clear T_V_I Vv_i
        end
    else
        J_S_I = J_A_I;
    end  
    % Cut to neglect static links
    cut = [ones(1,nv) link_type]; % add ones for the vehicle dof
    cut = logical(cut);
    J_S_I = J_S_I(:,cut,cut);
    if simplify_act>=1 %&& debug 
        J_S_I = simplify_matrix(J_S_I,'link Jacobians',quiet);                  
    end
    clear cut J_A_I
end
    
%% Calculation of mass matrix
if M_calc_act
    if M_alg
        % if M_alg = second version
        if ~quiet
            disp('Calculate mass matrix M with Euler-Lagrange in fixed frame ...');
        end

        % Transform Inertias to A frame
        Inertia_i_A = sym(zeros(3,3,nal));
        for idx=1:nal
            Inertia_i_A(:,:,idx) = T_A_I(r,r,idx) * Inertia_i_I(:,:,idx) * T_A_I(r,r,idx).';
        end

        % calc partial jacobians with CoMs, all relative to A
        % => J_CoM_i_A, whereas this is 3D now!
        J_CoM_i_A = sym(zeros(6,nal,nal));
        for idx=1:nal
            J_CoM_i_A(:,:,idx) = calc_jacobian(CoM_i_A(r,idx),idx,DH_mod_act,link_type,T_A_I);
        end

        if vehicle_act  
            % Vehicle update
            % extend m_i, turn/extend inertia_A 
            % J_S: use update law [V_v_CoM*J_v_W   V_a*J_CoM_is_A]

            m_i_S = [nul nul nul m_i]; 
            % If not only update, so if m_v would be input:
            %m_i_S = [0 m_v 0 m_i]; %mass of vehicle only once at last translatory coordinate!

            % Then the update for the J_v CoM:
            V_v_CoM = sym(eye(6));
            % If no update:
            %V_v_CoM = J_point_up(CoM_v(r),T_W_V);

            % loop for inertia and J update
            Inertia_i_S = sym(zeros(3,3,nval));
            J_CoM_i_S = sym(zeros(6,nval,nval));
            for idx=1:nval
                if idx==1
                    % no inertia for x
                    % updated partial Jacobian for vehicle x motion
                    J_CoM_i_S(:,1,idx) = V_v_CoM * Jv(:,1);
                elseif idx == 2
                    % no inertia for y
                    % updated partial Jacobian for vehicle y motion
                    J_CoM_i_S(:,1:2,idx) = V_v_CoM * Jv(:,1:2);
                elseif idx == 3
                    % If no update:
                    % Inertia vehicle in world, as third element
                    %Inertia_i_S(:,:,idx) = T_W_V(r,r) * Inertia_v * T_W_V(r,r).';
                    % updated partial Jacobian for vehicle rotation phi                
                    J_CoM_i_S(:,1:3,idx) = V_v_CoM * Jv;
                else
                    jdx = idx-3;
                    % otherwise go through robot arm; turn to world
                    Inertia_i_S(:,:,idx) = T_W_A(r,r) * Inertia_i_A(:,:,jdx) * T_W_A(r,r).';

                    % Then the update for the J_v:
                    CoM_S = T_V_A * CoM_i_A(:,jdx);
                    V_v_CoM = J_point_up(CoM_S,T_W_V);
                    % updated partial Jacobian for vehicle due to CoM_i rotation
                    J_CoM_i_S(:,1:3,idx) = V_v_CoM * Jv;
                    % update J_CoM_is_A = turn to world frame
                    J_CoM_i_S(:,4:nval,idx) = Va * J_CoM_i_A(:,:,jdx);
                end
            end
            clear CoM_S V_v_CoM

        else
            % if no vehicle no update required
            m_i_S = m_i;
            Inertia_i_S = Inertia_i_A;
            J_CoM_i_S = J_CoM_i_A;
        end
        
        % maybe simplify J_CoM_i_S here??
        if simplify_act>=1 %&& debug 
            J_CoM_i_S = simplify_matrix(J_CoM_i_S,'partitial Jacobians',quiet);                  
        end
    
        % Calculate M matrix with formular from DeLuca or Khatib, with all
        % Links included, so also static ones (and maybe vehicle)
        % optimize or update only do not work here?!
        M_all = sym(zeros(nval,nval));
        for idx=1:nval
            M_all = M_all + m_i_S(idx).*(J_CoM_i_S(1:3,:,idx).' * J_CoM_i_S(1:3,:,idx));
            M_all = M_all + (J_CoM_i_S(4:6,:,idx).' * Inertia_i_S(:,:,idx) * J_CoM_i_S(4:6,:,idx));
        end

        % Cut to neglect static links
        cut = [ones(1,nv) link_type]; % add ones for the vehicle dof
        cut = logical(cut);
        % if update only the first part is needed
        if update_act
            M = M_all(cut,1:M_end);
        else
            M = M_all(cut,cut);
        end    

        % Add a check here, if the cutted stuff is really zero.
        if ~any(any(M_all(~cut,:))) && ~any(any(M_all(:,~cut)))
            if debug
                disp('debug: all cutted values are zero. => correct, no error.')
            end
        else
            warning('Not all cutted values are zero!? This might indicate an error.')
        end

        clear M_all cut

    else
        %% Rotational energy calc      
        % A bit of information for the user
        if ~quiet
            disp('Calculate mass matrix M ...');
        end
        % start omega of omega calc = omega of robot base
        if vehicle_act
            % rotational velocity of vehicle = phi_dot around z-axis in V frame
            % So S frame is V frame here
            omega_0_S = [nul;nul;phid];
        else
            omega_0_S = sym(zeros(3,1));
        end

        if Inertia_est_act % && vehicle_act %implicitly        
            % A bit of information for the user
            if ~quiet
                disp('Calculate rotatory energy with inertia estimate ...');
            end

            % Estimate code = old style 
            % rotational velocity of robot parts = vehicle rotation velocity
            omega_i_I = sym([zeros(2,nal);ones(1,nal)])*phid;

            % Inertia of Robot parts
            % Use CoM_i_V here ??!!
            Inertia_i_I = m_i.*sum(CoM_i_A(1:2,:).^2 ,1);

            % rotatory kinetic energy of robot parts
            Kr_i_I = sym(1/2)*(Inertia_i_I.*sum(omega_i_I.^2,1) );

        else
            % A bit of information for the user
            if ~quiet
                disp('Calculate rotatory energy with moving frames algorithm ...');
            end

            % DeLuca version 
            omega_i_I = sym(zeros(3,nal));
            Kr_i_I = sym(zeros(1,nal));
            for idx = 1:nal
                if DH_mod_act
                    % Modified DH; adapted from DeLuca by Alex
                    % Major difference: calculation here in i frame not in i-1
                    if idx==1 %First link is a bit different
                        % Energy calc start frame is either arm frame or vehicle->arm frame
                        if vehicle_act
                            T_S_I = T_V_A * T_A_I(:,:,idx);
                        else
                            T_S_I = T_A_I(:,:,idx); 
                        end
                        %first link omega is based on base omega
                        omega_i_I(:,idx) = (T_S_I(r,r).')*omega_0_S; %mod!!

                    else % other links
                        % other link omega are last omega in current frame
                        omega_i_I(:,idx) = (T_I1_I(r,r,idx).')*omega_i_I(:,idx-1); %mod!!
                    end
                    % If link is rotatory add the qd in z-axis (z-axis: DH-definition).
                    if link_type(idx) == 1
                        omega_i_I(:,idx) = omega_i_I(:,idx) + qdine(idx)*uz; %mod!!
                    end

                else
                    % Standard DH direct DeLuca
                    % omega_i_I1 is term in [] and this is build up next:
                    if idx==1 %First link is a bit different
                        %first link omega is based on base omega
                        if vehicle_act
                            omega_i_I1 = (T_V_A(r,r).') * omega_0_S;
                        else
                            omega_i_I1 = omega_0_S;
                        end
                    else % other links
                        % other link omega are last omega in last frame
                        omega_i_I1 = omega_i_I(:,idx-1); %Standard!!
                    end
                    % If link is rotatory add the qd in z-axis (z-axis: DH-definition).
                    if link_type(idx) == 1
                        omega_i_I1 = omega_i_I1 + qdine(idx)*uz; %Standard!!
                    end
                    % Apply TF to _i_I
                    omega_i_I(:,idx) = (T_I1_I(r,r,idx).')*omega_i_I1; %Standard!!
                end

                % rotatory kinetic energy of robot parts
                Kr_i_I(idx) = sym(1/2)*((omega_i_I(:,idx).') * Inertia_i_I(:,:,idx) * omega_i_I(:,idx));
            end
            clear T_S_I omega_i_I1
        end

        %% Translatory Energy
        if alt_act
            % A bit of information for the user
            if ~quiet
                disp('Calculate translatory energy with diff(p_CoM,t) ...');
            end

            % old style also working, but adapted to usage without vehicle
            % Energy calc start frame is either arm frame or world->vehicle->arm frame
            if vehicle_act
                T_S_A = T_W_A; % location of Robot base in world
            else
                T_S_A = sym(eye(4)); % arm frame means do nothing
            end
            % CoM_i_S Robot parts location in start frame
            CoM_i_S = T_S_A*CoM_i_A;
            % v_CoM_i_S velocity of Robot parts CoMs in start frame
            v_CoM_i_S = diff_t(CoM_i_S,xqin,xqdin);
            if simplify_act>=1
                if ~quiet
                    disp('Simplify v_CoM_i_S ...');
                end
                v_CoM_i_S = simplify(v_CoM_i_S);
            end

            % v_CoM_i_A velocity of Robot parts CoMs in robot base frame
            v_CoM_i_A = T_S_A\v_CoM_i_S; 
            if simplify_act>=1
                if ~quiet
                    disp('Simplify v_CoM_i_A ...');
                end
                v_CoM_i_A = simplify(v_CoM_i_A);
            end

            % translatory kinetic energy of robot parts
            Kt_i_I = sym(1/2)*(m_i.*sum((v_CoM_i_A(r,:)).^2 ,1) );

            clear T_S_A CoM_i_S v_CoM_i_S v_CoM_i_A

        else
            % A bit of information for the user
            if ~quiet
                disp('Calculate translatory energy with moving frames algorithm ...');
            end

            % DeLuca version 
            % start velocity of velocity calc = velocity of vehicle in W frame
            % So S frame is W frame here
            if vehicle_act
                % translatory velocity of vehicle = x_dot and y_dot; z is zero (vehicle cannot fly)
                v_0_S = [xd;yd;nul];
            else
                v_0_S = sym(zeros(3,1)); %or no velocity if no vehicle
            end

            v_i_I = sym(zeros(3,nal));
            Kt_i_I = sym(zeros(1,nal));
            for idx = 1:nal
                if DH_mod_act
                    % Modified DH; adapted from DeLuca by Alex
                    % Major difference: calculation here in i frame not in i-1
                    if idx==1 %First link is a bit different
                        % Pure trans Energy calc start frame is either arm frame or
                        % world->vehicle->arm frame
                        if vehicle_act
                            T_S_I = T_W_A * T_A_I(:,:,idx);
                        else
                            T_S_I = T_A_I(:,:,idx); 
                        end
                        %first link velocity is based on start velocity
                        v_i_I(:,idx) = (T_S_I(r,r).')*v_0_S; %mod!!

                        % trans resulting from rot Energy calc start frame is 
                        % either arm frame or vehicle->arm frame (because rotation
                        % is around CoM vehicle
                        if vehicle_act
                            T_S_I = T_V_A * T_A_I(:,:,idx);
                        else
                            T_S_I = T_A_I(:,:,idx); 
                        end
                        % add translatory velocity resulting from rotation of start
                        % around its rotation centre, but addition again in i frame
                        % (3.term in [])
                        v_i_I(:,idx) = v_i_I(:,idx) + (T_S_I(r,r).')* (S(omega_0_S)*T_S_I(r,4) ); %mod!!

                    else % other links
                        % other link omega are last omega in current frame
                        v_i_I(:,idx) = (T_I1_I(r,r,idx).')*v_i_I(:,idx-1); %mod!!

                        % add translatory velocity resulting from rotation of last
                        % link, but addition again in i frame (3.term in [])
                        v_i_I(:,idx) = v_i_I(:,idx) + (T_I1_I(r,r,idx).')* (S(omega_i_I(:,idx-1))*T_I1_I(r,4,idx) ); %mod!!
                    end

                    % If link is prismatic add the qd in z-axis (z-axis: DH-definition).
                    if link_type(idx) == 2
                        v_i_I(:,idx) = v_i_I(:,idx) + qdine(idx)*uz; %mod!!
                    end

                else
                    % Standard DH direct DeLuca
                    % v_i_I1 is term in [] and this is build up next:
                    if idx==1 %First link is a bit different
                        % Pure trans Energy calc start frame is either arm frame or
                        % world->vehicle->arm frame
                        if vehicle_act
                            % first link velocity is based on base velocity
                            v_i_I1 = (T_W_A(r,r).')*v_0_S + (T_V_A(r,r).')*(S(omega_0_S)*T_V_A(r,4)); 
                        else
                            v_i_I1 = v_0_S; 
                        end
                    else % other links
                        % other link omega are last omega in last frame
                        v_i_I1 = v_i_I(:,idx-1); %Standard!!
                    end

                    % If link is prismatic add the qd in z-axis (z-axis: DH-definition).
                    if link_type(idx) == 2
                        v_i_I1 = v_i_I1 + qdine(idx)*uz; %Standard!!
                    end

                    % Calc omega_i_I1
                    omega_i_I1 = T_I1_I(r,r,idx)*omega_i_I(:,idx); %Standard!!

                    % Add translatory velocity resulting from rotation of the Link
                    % since the frame is moving seen from the last frame (Standard DH!!)
                    v_i_I1 = v_i_I1 + S(omega_i_I1) * T_I1_I(r,4,idx); %Standard!!

                    % Apply TF to _i_I
                    v_i_I(:,idx) = (T_I1_I(r,r,idx).')*v_i_I1; %Standard!!
                end

                % calculate velocity of CoM in I = velocity of frame and velocity
                % due to rotation around frame of CoM = Steiner theorem
                v_CoM_i_I = v_i_I(:,idx) + S(omega_i_I(:,idx)) * CoM_i_I(r,idx);

                % translatory kinetic energy of robot parts
                Kt_i_I(idx) = sym(1/2)* (m_i(idx) * (v_CoM_i_I.') * v_CoM_i_I);
            end
            clear T_S_I v_i_I1 v_0_S omega_i_I1 v_CoM_i_I
        end

        %% total kinetic energy
        % A bit of information for the user
        if ~quiet
            disp('Summing up all energies ...');
        end

        % Sum up all energies (Koenig theorem!)
        K = sum(Kt_i_I,2) + sum(Kr_i_I,2); % +Energy of vehicle if needed Extension

        %% Calculating M elementwise
        % Differantiate K twice to velocities ==> Mass Matrix
        if ~quiet
            % pre face for status
            disp('Calculate mass matrix M with differentiating twice ...');
            print_pre_calc(M_end,M_start)
        end
        % M is mass matrix; maybe only a part of it
        M = sym(zeros(nva,M_end));
        for idx = M_start:nva
            Min = sym(zeros(nva,M_end));
            Min(idx,:) = M_calc_from_K(idx,M_end,quiet,pct_simplify_act,optimize,update_act,K,xqdin);
            M = M + Min;
        end
    end % End of M calculations 

    %% post processing    
    if ~quiet
        disp('Start post processing for M matrix...');
    end

    % Do simplify maybe
    if simplify_act>=2
        if pct_simplify_act>0
            if ~quiet
                % pre face for status
                disp('Simplify with Parallel computing...');
            end
            if isempty(gcp('nocreate'))
                parpool('local');
                close_pool = true;
            else
                close_pool = false;
            end
            M2 = sym(zeros(nva,M_end));
            parfor jdx=M_start:nva
                % Min M2 ... due to parfor
                Min_row = sym(zeros(1,M_end));

                % optimize: calculate only lower left corner and later flip this up,
                % because of mass matrix symmetry
                if optimize>0
                    line_end = jdx;
                else
                    line_end = M_end;
                end

                % update only: calc top left 3x3 M_vec update and lower left na x3
                % coupeling matrix
                if update_act && line_end>3
                    line_end = 3;
                end

                for hdx=1:line_end
                    Min_row(1,hdx) = simplify(M(jdx,hdx));
                    if ~quiet
                        disp(['Finished: ' int2str(jdx) ' x ' int2str(hdx)]);
                    end
                end
                Min = sym(zeros(nva,M_end));
                Min(jdx,:) = Min_row;
                M2 = M2 + Min;
            end
            M = M2;
            if close_pool && ~debug
                delete(gcp('nocreate'));
            end
            clear M2 Min Min_row close_pool

        else
            if ~quiet
                % pre face for status
                disp('Simplify without Parallel computing...');
                print_pre_calc(M_end,M_start)
            end
            for jdx=M_start:nva
                if ~quiet
                    fprintf('%i. Row: ', jdx);
                end
                % optimize: calculate only lower left corner and later flip this up,
                % because of mass matrix symmetry
                if optimize>0
                    line_end = jdx;
                else
                    line_end = M_end;
                end

                % update only: calc top left 3x3 M_vec update and lower left na x3
                % coupeling matrix
                if update_act && line_end>3
                    line_end = 3;
                end

                for hdx=1:line_end
                    if ~quiet
                        fprintf('o');
                    end
                    M(jdx,hdx) = simplify(M(jdx,hdx));
                    if ~quiet
                        fprintf('\b');
                        fprintf('v ');
                    end
                end
                % Print line break if finished
                if ~quiet
                    fprintf('\n');
                end
            end
        end
    end

    % De-optimize M
    if optimize>=3
        M(2,1) = nul; % second row first element is always zero.
        M(2,2) = sum(m_i,2); % translatory mass update is sum of arm masses ...
    end
    if optimize>=2
        M(1,1) = M(2,2);     % ... and actually the same for x and y
    end
    if optimize>=1 % if optimize 1: flip up the calculated lower left corner
        if update_act
            M(r,r) = tril(M(r,r),0) + tril(M(r,r),-1).'; %update only vehicle update is optimized
        else
            M = tril(M,0) + tril(M,-1).'; % otherwise flip full matrix
        end
    end
end % M_calc_act

%% Calculation of Coriolis and Centrifugal terms
if C_calc_act
    if ~quiet
        disp('Calculate Coriolis term C with Christoffel symbols ...');
    end 
    if update_act
        Mc = [M(r,r)     M(4:end,r).'
              M(4:end,r) sym(zeros(na))];
        C = C_calc(Mc,xqin,xqdin,C_mat_act);
        clear Mc
    else
        C = C_calc(M,xqin,xqdin,C_mat_act);
    end
    if simplify_act>=2
        if ~quiet
            disp('Simplify C matrix ...');
        end
        C = simplify(C);
    end
end

%% G_calc
if G_calc_act
    if ~quiet
        disp('Calculate Gravity vector G ...');
    end
    if update_act
        G = sym(zeros(nva,1)); %there is no update actually
    else
        if vehicle_act
            m_i_S = [nul nul nul m_i];
            CoM_i_S = [sym(zeros(size(CoM_i_A,1),3)), T_W_A * CoM_i_A];
        else
            m_i_S = m_i;
            CoM_i_S = CoM_i_A;
        end
        G = G_calc(xqin,m_i_S,CoM_i_S);
        if simplify_act>=2
            if ~quiet
                disp('Simplify G matrix ...');
            end
            G = simplify(G);
        end
        clear m_i_S CoM_i_S
    end
end

%% Output generation
% A bit of information for the user
if ~quiet
    disp('All Calculations done. Generating output ...');
end

% variables of output
if vehicle_act && ~vq_act
    vq = [x y phi];
    vqd = [xd yd phid];
end

add_vars_DH = {}; % Additional vars from DH parameters
if ~isempty(a_var)
    add_vars_DH = cat(2,add_vars_DH,{'a';a_var});
end
if ~isempty(alpha_var)
    add_vars_DH = cat(2,add_vars_DH,{'alpha';alpha_var});
end
d_var_static = setdiff(d_var,qext,'stable');
if ~isempty(d_var_static)
    add_vars_DH = cat(2,add_vars_DH,{'d';d_var_static});
end
theta_var_static = setdiff(theta_var,qext,'stable');
if ~isempty(theta_var_static)
    add_vars_DH = cat(2,add_vars_DH,{'theta';theta_var_static});
end
add_vars_Dyn = {}; %Additional vars from Dynamics
if ~isempty(m_var)
    add_vars_Dyn = cat(2,add_vars_Dyn,{'m';m_var});
end
if ~isempty(CoM_var)
    add_vars_Dyn = cat(2,add_vars_Dyn,{'CoM';CoM_var});
end
if ~isempty(Inertia_var)
    add_vars_Dyn = cat(2,add_vars_Dyn,{'Inertia';Inertia_var});
end

% Replace internal variables and put in output
% substitute internal q's with requested q's

jdx = 1;
%M
if M_calc_act
    M = subs(M,qin,qext);
    if vehicle_act && vq_act
        M = subs(M,[x y phi],vq);
    end
    if vehicle_act
        vars = {'qv' 'qa'; vq qext};
    else
        vars = {'q'; qext};
    end
    if ~isempty(add_vars_DH)
        vars = cat(2,vars,add_vars_DH);
    end
    if ~isempty(add_vars_Dyn)
        vars = cat(2,vars,add_vars_Dyn);
    end
    if vehicle_act && ~isempty(TF_veh_arm_var)
        vars = cat(2,vars,{'T_V_A';TF_veh_arm_var});
    end
    
    if vehicle_act
        % Mu
        out.Mu = M(r,r);
        save_cell{jdx} = save_mat_check(M(r,r),'Mu',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
        jdx = jdx + 1;

        % Mav
        if na==0
            out.Mav = [];
        else
            out.Mav = M(4:end,r);
            save_cell{jdx} = save_mat_check(M(4:end,r),'Mav',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
            jdx = jdx + 1;
        end
        
    end
    
    if ~update_act
        out.M = M;
        save_cell{jdx} = save_mat_check(M,'M',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
        jdx = jdx + 1;
    end
    clear vars
    
    if vehicle_act && ~update_act
        % Ma
        vars = {'qa'; qext};
        if ~isempty(add_vars_DH)
            vars = cat(2,vars,add_vars_DH);
        end
        if ~isempty(add_vars_Dyn)
            vars = cat(2,vars,add_vars_Dyn);
        end
        if ~isempty(setdiff(symvar(M(4:end,4:end)),[vars{2,:}],'stable'))
            warning('Left over variables in Ma!');
            disp('====HINT====');
            disp('There were some variables of the vehicle found in the manipulator mass matrix part Ma.');
            disp('So Ma is not in the output nor a function is generated.');
            disp('This can sometimes happen if: ');
            disp('The vehicle is active (without vehicle the variables are not even instantiated)');
            disp('M_alg is chosen (for the moving frames method it seems to be not relevant)');
            disp('Not the highest simplify level is choosen (the variables would disappear, if active)');
            disp('Solution:');
            disp('Run the function again without the vehicle active and use the mass matrix M as Ma.');
            disp('============');
        else
            out.Ma = M(4:end,4:end);
            save_cell{jdx} = save_mat_check(M(4:end,4:end),'Ma',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
            jdx = jdx + 1;
        end
        clear vars
    end
end

% C
if C_calc_act
    C = subs(C,qin,qext);
    C = subs(C,qdin,qdext);
    if vehicle_act && vq_act
        C = subs(C,[x y phi],vq);
        C = subs(C,[xd yd phid],vqd);
    end  
    if vehicle_act
        vars = {'qv' 'qa' 'qdv' 'qda'; vq qext vqd qdext};
    else
        vars = {'q' 'qd'; qext qdext};
    end
    if ~isempty(add_vars_DH)
        vars = cat(2,vars,add_vars_DH);
    end
    if ~isempty(add_vars_Dyn)
        vars = cat(2,vars,add_vars_Dyn);
    end
    if vehicle_act && ~isempty(TF_veh_arm_var)
        vars = cat(2,vars,{'T_V_A';TF_veh_arm_var});
    end
    out.C = C; 
    save_cell{jdx} = save_mat_check(C,'C',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
    jdx = jdx + 1;
    clear vars
end

% G
if G_calc_act
    G = subs(G,qin,qext);
    if vehicle_act && vq_act
        G = subs(G,[x y phi],vq);
    end  
    if vehicle_act
        vars = {'qv' 'qa'; vq qext};
    else
        vars = {'q'; qext};
    end
    if ~isempty(add_vars_DH)
        vars = cat(2,vars,add_vars_DH);
    end
    if ~isempty(add_vars_Dyn)
        vars = cat(2,vars,add_vars_Dyn);
    end
    if vehicle_act && ~isempty(TF_veh_arm_var)
        vars = cat(2,vars,{'T_V_A';TF_veh_arm_var});
    end
    syms g real
    vars = cat(2,vars,{'g';g});
    out.G = G; 
    save_cell{jdx} = save_mat_check(G,'G',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
    jdx = jdx + 1;
    clear vars
end
% Forward kinematic 
if T_A_EE_calc_act
    T_A_EE = T_A_I(:,:,end);
    T_A_EE = subs(T_A_EE,qin,qext);
    if vehicle_act && vq_act
        T_A_EE = subs(T_A_EE,[x y phi],vq);
    end
    out.T_A_EE = T_A_EE;
    if vehicle_act
        vars = {'qv' 'qa'; vq qext};
    else
        vars = {'q'; qext};
    end
    if ~isempty(add_vars_DH)
        vars = cat(2,vars,add_vars_DH);
    end
    save_cell{jdx} = save_mat_check(T_A_EE,'T_A_EE',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
    jdx = jdx + 1;
    clear vars
end
% Calc T_S_I output
if TSI_calc_act
    if vehicle_act
        T_S_I(:,:,1) = T_W_V; %First frame is vehicle frame
        T_S_I(:,:,2) = T_W_A; %Second frame is arm base frame
        for idx = 1:nal
            T_S_I(:,:,idx+2) = T_W_A * T_A_I(:,:,idx); %Rest is to the links
        end
    else
        T_S_I = T_A_I;
    end  
    T_S_I = subs(T_S_I,qin,qext);
    if vehicle_act
        if vq_act
            T_S_I = subs(T_S_I,[x y phi],vq);
        end
        vars = {'qv' 'qa'; vq qext};        
        if ~isempty(add_vars_DH)
            vars = cat(2,vars,add_vars_DH);
        end
        if ~isempty(TF_veh_arm_var)
            vars = cat(2,vars,{'T_V_A';TF_veh_arm_var});
        end
    else
        vars = {'q'; qext};
        if ~isempty(add_vars_DH)
            vars = cat(2,vars,add_vars_DH);
        end
    end
    out.T_S_I = T_S_I; 
    save_cell{jdx} = save_mat_check(T_S_I,'T_S_I',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
    jdx = jdx + 1;
    clear vars
end


% J and V
if J_calc_act
    J = subs(J,qin,qext);
    if vehicle_act
        if vq_act
            J = subs(J,[x y phi],vq);
        end
        vars = {'qv' 'qa'; vq qext};        
        if ~isempty(add_vars_DH)
            vars = cat(2,vars,add_vars_DH);
        end
        if ~isempty(TF_veh_arm_var)
            vars = cat(2,vars,{'T_V_A';TF_veh_arm_var});
        end
    else
        vars = {'q'; qext};
        if ~isempty(add_vars_DH)
            vars = cat(2,vars,add_vars_DH);
        end
    end
    out.J = J;  
    save_cell{jdx} = save_mat_check(J,'J',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
    jdx = jdx + 1;
    clear vars 
end

if vehicle_act
    if Ja_calc_act
        Ja = subs(Ja,qin,qext);
        vars = {'qa'; qext};
        if ~isempty(add_vars_DH)
            vars = cat(2,vars,add_vars_DH);
        end
        out.Ja = Ja;  
        save_cell{jdx} = save_mat_check(Ja,'Ja',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
        jdx = jdx + 1;
        clear vars 
    end
    if Jv_calc_act
        out.Jv = Jv;  
        vars = {'';sym([])};
        save_cell{jdx} = save_mat_check(Jv,'Jv',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
        jdx = jdx + 1;
        clear vars 
    end
    if Va_calc_act
        if vq_act
            Va = subs(Va,[x y phi],vq);
        end
        vars = {'qv'; vq};
        if ~isempty(add_vars_DH)
            vars = cat(2,vars,add_vars_DH);
        end
        if ~isempty(TF_veh_arm_var)
            vars = cat(2,vars,{'T_V_A';TF_veh_arm_var});
        end
        out.Va = Va;  
        save_cell{jdx} = save_mat_check(Va,'Va',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
        jdx = jdx + 1;
        clear vars 
    end
    if Vv_calc_act
        Vv = subs(Vv,qin,qext);
        if vq_act
            Vv = subs(Vv,[x y phi],vq);
        end
        vars = {'qv' 'qa'; vq qext};
        if ~isempty(add_vars_DH)
            vars = cat(2,vars,add_vars_DH);
        end
        if ~isempty(TF_veh_arm_var)
            vars = cat(2,vars,{'T_V_A';TF_veh_arm_var});
        end
        out.Vv = Vv;  
        save_cell{jdx} = save_mat_check(Vv,'Vv',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
        jdx = jdx + 1;
        clear vars 
    end
end
% Calc J_S_I output
if JSI_calc_act
    J_S_I = subs(J_S_I,qin,qext);
    if vehicle_act
        if vq_act
            J_S_I = subs(J_S_I,[x y phi],vq);
        end
        vars = {'qv' 'qa'; vq qext};        
        if ~isempty(add_vars_DH)
            vars = cat(2,vars,add_vars_DH);
        end
        if ~isempty(TF_veh_arm_var)
            vars = cat(2,vars,{'T_V_A';TF_veh_arm_var});
        end
    else
        vars = {'q'; qext};
        if ~isempty(add_vars_DH)
            vars = cat(2,vars,add_vars_DH);
        end
    end
    out.J_S_I = J_S_I;  
    save_cell{jdx} = save_mat_check(J_S_I,'J_S_I',save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act);
%     jdx = jdx + 1;
    clear vars 
end

% Make functions
save_cell = save_cell(~cellfun('isempty',save_cell));
if ~isempty(save_cell)
    if file_pct_act
        if ~quiet
            disp('Outputing functions with parallel computing...');
        end
        if isempty(gcp('nocreate'))
            parpool('local');
            close_pool = true;
        else
            close_pool = false;
        end
        parfor idx=1:numel(save_cell)
            save_mat(save_cell{idx},quiet)
        end
        if close_pool && ~debug
            delete(gcp('nocreate'));
        end
    else
        if ~quiet
            disp('Outputing functions without parallel computing...');
        end
        for idx=1:numel(save_cell)
            save_mat(save_cell{idx},quiet)
        end
    end
end

% A bit of information for the user
if ~quiet
    disp('Finished without known errors.');
    toc
end

end %function end

%% helper functions
function R = HomogeniusTransformMatrix_modifiedDH(a,alpha,d,theta)
R = sym(...
    [cos(theta),            -sin(theta),             0,           a
     cos(alpha)*sin(theta),  cos(alpha)*cos(theta), -sin(alpha), -d*sin(alpha)
     sin(alpha)*sin(theta),  sin(alpha)*cos(theta),  cos(alpha),  d*cos(alpha)
     0,                      0,                      0,           1            ]);
end

function R = HomogeniusTransformMatrix(a,alpha,d,theta)
R = sym(...
    [cos(theta), -sin(theta)*cos(alpha),  sin(theta)*sin(alpha), a*cos(theta)
     sin(theta),  cos(theta)*cos(alpha), -cos(theta)*sin(alpha), a*sin(theta)
     0,           sin(alpha),             cos(alpha),            d
     0,           0,                      0,                     1             ]);
end

function M = S(v)
M = sym(...
    [ 0    -v(3)  v(2)
      v(3)  0    -v(1)
     -v(2)  v(1)  0   ]);
end

function [Result] = iseukltrans(M)
%ISEUKLTRANS pr�ft ob M eine Euklidische Transformation ist; ggf. mit threshold 
%als Genauigkeit.
%   0 = Keine Euk. Transformation; 1 = Korrekte Euk. Transformation

% %% Input pr�fen
% narginchk(1,2);
% if nargin == 1
%     threshold = sym(0); 
% end

%% Check M
Result = all(size(M) == [4 4]) && all(M(4,1:4)==sym([0 0 0 1])) ;%&& isrotm(M(1:3,1:3),threshold) %%%out due to syms

end
%%% Not working with symbolic input
% function [Result] = isrotm(R, threshold)
% %ISROTM pr�ft ob R eine Rotationsmatrix ist; ggf. mit threshold als
% %Genauigkeit.
% %   0 = Keine Rotationsmatrix; 1 = Korrekte Rotationsmatrix
% 
% %% Input pr�fen
% narginchk(1,2);
% if nargin == 1
%     threshold = sym(0);
% end
% 
% %% Check R
% Result = all(size(R) == [3 3]) && simplify(abs(det(R)-sym(1)))<=threshold && all(all(simplify(abs((R.'*R)-sym(eye(3))))<=threshold),2);
% 
% end

function reply = hasParallelToolbox(S)
% Somewhere from the internet but strongly modified;
% and so far not tested on a machine without parallel toolbox; 
% Sorry I have none :-(

try
    % If the function is available, Toolbox is there
    if isempty(gcp('nocreate')) || ~isempty(gcp('nocreate'))
        hasPPT = true;
    end
catch ME
    if ~strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
      rethrow(ME);
    end
    hasPPT = false;
end
usePPT = hasPPT;

% override through input
if nargin > 0
   usePPT = S && hasPPT;
end

reply = usePPT;
end

function Mr = M_calc_from_K(row,M_end,quiet,pct_act,optimize,update_act,K,xqdin)
    % This is the M matrix calculator

    if ~quiet && pct_act==0
        fprintf('%i. Row: ', row);
    end
    
    %init one row of mass matrix
    Mr = sym(zeros(1,M_end));
    
    % 1. diff: Every row of mass matrix
    mm = diff(K,xqdin(row));

    % optimize: calculate only lower left corner and later flip this up,
    % because of mass matrix symmetry
    if optimize>0
        line_end = row;
    else
        line_end = M_end;
    end

    % update only: calc top left 3x3 M_vec update and lower left na x3
    % coupeling matrix
    if update_act && line_end>3
        line_end = 3;
    end

    for hdx = 1:line_end
        if ~quiet && pct_act==0
            fprintf('o');
        end
        % 2. diff: Every column differentiated
        Mr(1,hdx)=diff(mm,xqdin(hdx));
        if ~quiet && pct_act>0
            disp(['Finished: ' int2str(row) ' x ' int2str(hdx)]);
        end
        if ~quiet && pct_act==0
            fprintf('\b');
            fprintf('v ');
        end
    end
    if ~quiet && pct_act==0
        fprintf('\n');
    end
end

function print_pre_calc(columns,start_row)
    % Prints header for matrix calc
    fprintf('Column: ');
    for idx=1:columns
        fprintf('%i ', idx);
    end
    fprintf('\n');
    for idx=1:start_row-1
        fprintf('%i. Row: optimized\n', idx);
    end
end

function J_a_A = calc_jacobian(p_aim_A,at_link,DH_mod_act,link_type,T_A_I)
    % Calculates Jacobians, eg EE or Partial
    % 
    % p_aim_A: position of aim in arm base frame eg EE or a CoM
    % at_link: number of the link were the aim is attached to; 
    % rest is same as outside
    
    
    nal = size(link_type,2); %restore amount of ALL links
    %na must be given, cannot be restored
    
    uz = sym([0;0;1]); %a z-axis
    r = 1:3; %rotational part cutter
    
    J_a_A = sym(zeros(6,nal));
    if DH_mod_act
        % modified DH to Jacobian; from DeLuca adapted by Alex
        % Major difference: do calculations around link/joint i, since both
        % are located at the same place
        
        for idx=1:nal
            % if link is not static do calculations; otherwise nothing to do
            if link_type(idx)>0
                % Calculate the z-axis component in A frame; (z-axis due to DH-para)
                z_i_A = T_A_I(r,r,idx)*uz;
                % Choose link type
                if link_type(idx)==1
                    % revolute joint
                    % calculate vector from this joint to aim
                    p_iEE_A = p_aim_A - T_A_I(r,4,idx);
                    % add z x p to translatory part
                    J_a_A(1:3,idx) = S(z_i_A)*p_iEE_A; 
                    % add z to rotatory part
                    J_a_A(4:6,idx) = z_i_A;
                elseif link_type(idx)==2
                    % prismatic joint
                    J_a_A(1:3,idx) = z_i_A; % add z to translatory part
                    % rotatory part stays zero
                else
                    % WHAT?!
                    error('unknown link type');                    
                end            
            end
            % If the link was calculated where the aim is
            % attached to, the algorithm stops, since the rest is only
            % filled with zeros
            if idx >= at_link
                break;
            end  
        end
    else
        % Standard DH to Jacobian; from DeLuca
        for idx=1:nal
            % if link is not static do calculations; otherwise nothing to do
            if link_type(idx)>0
                % Calculate the z-axis component; (z-axis due to DH-para)
                if idx==1 % First Link is a bit different
                    z_i1_A = uz; %actually it is only a z-axis
                else
                    % For the other links the z-axis must be rotated to A
                    z_i1_A = T_A_I(r,r,idx-1)*uz;
                end
                % Choose link type
                if link_type(idx)==1
                    % revolute joint
                    % calculate vector from this joint to Aim
                    if idx==1 % First Link is a bit different
                        p_i1EE_A = p_aim_A; %only A->Aim
                    else
                        % other links need this vector:
                        p_i1EE_A = p_aim_A - T_A_I(r,4,idx-1);
                    end
                    % add z x p to translatory part
                    J_a_A(1:3,idx) = S(z_i1_A)*p_i1EE_A; 
                    % add z to rotatory part
                    J_a_A(4:6,idx) = z_i1_A;
                elseif link_type(idx)==2
                    % prismatic joint
                    J_a_A(1:3,idx) = z_i1_A; % add z to translatory part
                    % rotatory part stays zero
                else
                    % WHAT?!
                    error('unknown link type');                    
                end         
            end
            % If the link was calculated where the aim is
            % attached to, the algorithm stops, since the rest is only
            % filled with zeros
            if idx >= at_link
                break;
            end  
        end
    end
    
end %J calc end

function Split_output_mat(mat,mat_name,path,filename_prefix,vars,fileopt_act,quiet,file_pct_act)
    % This outputs a matrix as single mat files in a folder
    
    full_path = [path filename_prefix mat_name filesep];
    % A bit of information for the user
    if ~quiet
        disp(['Save ' mat_name ' in files: ' [full_path filename_prefix mat_name] '_ROW_COL.m']);
    end
    
    %make folder if not exist
    if ~exist(full_path, 'dir')
        mkdir(full_path)
    end
    
    % A bit of information for the user
    if ~quiet && file_pct_act==0
        print_pre_calc(size(mat,2),1)
    end
    for idx = 1:size(mat,1)
        if ~quiet && file_pct_act==0
            fprintf('%i. Row: ', idx);
        end
        for jdx = 1:size(mat,2)
            if ~quiet && file_pct_act==0
                fprintf('o');
            end
            filename = [full_path filename_prefix mat_name '_' int2str(idx) '_' int2str(jdx) '.m'];
            matlabFunction(mat(idx,jdx),'file',filename,'vars',vars(2,:),'Outputs',{mat_name},'Optimize',fileopt_act);
            repair_input(filename,vars);
            if ~quiet && file_pct_act>0
                disp(['Finished: ' filename_prefix mat_name '_' int2str(idx) '_' int2str(jdx) '.m']);
            end
            if ~quiet && file_pct_act==0
                fprintf('\b');
                fprintf('v ');
            end
        end
        if ~quiet && file_pct_act==0
            fprintf('\n');
        end
    end

end

function save_mat(to_save,quiet)
    % This saves a matrix to file(s)

    if to_save.split
        Split_output_mat(to_save.mat,to_save.mat_name,to_save.path,to_save.filename_prefix,to_save.vars,to_save.fileopt_act,quiet,to_save.file_pct_act)
    end
    if ~to_save.split
        %make folder if not exist
        if ~exist(to_save.path, 'dir')
            mkdir(to_save.path)
        end
        filename = [to_save.path to_save.filename_prefix to_save.mat_name '.m'];
        if ~quiet
            disp(['Generating ' filename ' function ...']);
        end
        matlabFunction(to_save.mat,'file',filename,'vars',to_save.vars(2,:),'Outputs',{to_save.mat_name},'Optimize',to_save.fileopt_act);
        repair_input(filename,to_save.vars);
        if ~quiet && to_save.file_pct_act>0
            disp(['Finished ' filename ' function.']);
        end
        if to_save.filec_act
            if ~quiet
                disp(['Generating C++ functionn in codegen' filesep 'lib' filesep to_save.filename_prefix to_save.mat_name filesep ' ...']);
            end
            args = cell(1,size(to_save.vars,2));
            if ~isempty(to_save.vars{2,1})
                for idx=1:size(to_save.vars,2)
                    args{idx} = coder.typeof(ones(size(to_save.vars{2,idx})));
                end
            else
                args = {};
            end
            codegen(filename,'-args',args,'-config:lib','-lang:c++');
            if ~quiet && to_save.file_pct_act>0
                disp(['Finished C++ code generation of ' to_save.mat_name '.']);
            end
        end
    end
    
end


function out = save_mat_check(mat,mat_name,save_fct,save_split,path,filename_prefix,vars,fileopt_act,filec_act,file_pct_act)
    % This saves a matrix to file(s)
    out = [];
    if contains(save_split,[mat_name ' '])
        out.mat = mat;
        out.mat_name = mat_name;
        out.split = true;
        out.path = path;
        out.filename_prefix = filename_prefix;
        out.vars = vars;
        out.fileopt_act = fileopt_act;
        out.filec_act = filec_act;
        out.file_pct_act = file_pct_act;
    elseif contains(save_fct,[mat_name ' '])
        out.mat = mat;
        out.mat_name = mat_name;
        out.split = false;
        out.path = path;
        out.filename_prefix = filename_prefix;
        out.vars = vars;
        out.fileopt_act = fileopt_act;
        out.filec_act = filec_act;
        out.file_pct_act = file_pct_act;
    end
end

function repair_input(filename,vars)
    % read text of file, without deleting it
    filetext = fileread(filename);
    % replace inX with the vars name
    for idx=1:size(vars,2)
        if ~isscalar(vars{2,idx})
            filetext = replace(filetext, ['in' int2str(idx)], vars{1,idx});
            filetext = replace(filetext, ['IN' int2str(idx)], vars{1,idx});
        end
    end
    filetext = replace(filetext, ',:', ''); %Make independent of row or column vector
    filetext = replace(filetext, ':,', '');

    %write to file
    fileID = fopen(filename,'w'); %CONTENT DELETED!!
    fprintf(fileID, '%s',filetext); 
    fclose(fileID);
end

function matrix = simplify_matrix(matrix,name,quiet)
    % This function simplifies elementwise a big matrix, with nice output
    n = numel(matrix);
    if ~quiet
        fprintf(['Simplifying all the %i elements of the ' name ', current element: '], n);
    end
    for idx=1:n
        if ~quiet
            fprintf('%i', idx);
        end
        matrix(idx) = simplify(matrix(idx));
        if ~quiet
            ndigits = 1+floor(log10(idx)); % count digits of idx ...
            for jdx=1:ndigits
                fprintf('\b'); % ... to remove each from print
            end
        end
    end
    if ~quiet
        fprintf('done \n');
    end     
end






    