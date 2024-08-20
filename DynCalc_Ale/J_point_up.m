function Jup = J_point_up(radius,rotation)
    % This function calculates the update matrix of a Jacobian for a 
    % point at radius distance with respect to the current end-effector
    % frame. The rotation matrix is necessary to rotate the radius vector
    % to the base frame the Jacobian is referring to.
    
    %Input:
    % radius:   3 element vector (TF or 4 element also allowed)
    % rotation: 3x3 rotation matrix (or TF)
    
    r = 1:3; %rotational part cutter
    calc_symbolic = false; %determines automatically if symbolic or not
    if isa(radius,'sym') || isa(radius,'symfun') 
        calc_symbolic = true;
        if ~(isa(rotation,'sym') || isa(rotation,'symfun'))
            rotation = sym(rotation);
        end
    end
    if ~calc_symbolic && (isa(rotation,'sym') || isa(rotation,'symfun')) 
        calc_symbolic = true;
        if ~(isa(radius,'sym') || isa(radius,'symfun'))
            radius = sym(radius);
        end
    end
    
    % input check
    if ~(all(size(rotation) == [3 3]) || iseukltrans(rotation) || all(size(rotation) == [3 4]))
        error('J_point_up: Unknown rotationmatrix format!');
    end
    
    % determine radius vector
    if iseukltrans(radius)
        vec = radius(1:3,4);
    elseif all(size(radius) == [3 1])
        vec = radius;
    elseif all(size(radius) == [1 3])
        vec = radius.';
    elseif all(size(radius) == [4 1])
        vec = radius(1:3);
    elseif all(size(radius) == [1 4])
        vec = radius(1:3).';
    else
        error('J_point_up: Unknown radius format!');
    end
    
    % rotate radius in world frame
    vec = rotation(r,r) * vec;
    
    % The update for the Jacobian:
    if calc_symbolic
        Jup = sym(eye(6));
        % top right corner is influence of turning on radius translatory velocity
        Jup(1:3,4:6) = Ss(vec).';
    else
        Jup = eye(6);
        % top right corner is influence of turning on radius translatory velocity
        Jup(1:3,4:6) = S(vec).';
    end
    
    % Math rules:
    % Real formular: 
    %       v_tot = v_trans + omega x radius
    % To bring omega to the end for matrix multiply, respect the
    % antikommutativity: 
    %       v_tot = v_trans - radius x omega
    % Get rid of the cross-product, by taking S(.) function, and using
    % antisymmetry of S(.) to get rid of minus: 
    %       v_tot = v_trans + S(radius)^T * omega
    % By use of full velocity vector x_dot=[v_trans;omega]:
    %       v_tot = [eye(3)  S(radius)^T]*x_dot
    % Remaining issue: omega and radius must be with respect to the same
    % frame. Since omega is mostly with respect to base frame, it is wise
    % to rotate radius in the same frame. Really just rotate it and do not
    % transform the location! (NOT: TF*radius)
    % Correct for top right corner: 
    %       S(rotation*radius)^T
    % Also correct just rotating back and forth (making more complex):
    %       rotation*S(radius)^T*rotation^T
    % WRONG:
    %       rotation*S(radius)^T
    % I tested it, so S(.) and rotation* are not interchangeable
    
end

function [Result] = iseukltrans(M)
%ISEUKLTRANS checks if the M transformation is euclidean

%% Check M
Result = all(size(M) == [4 4]) && all(M(4,1:4)==[0 0 0 1]) ;

end

function M = S(v)
%Compute skew symmetric matrix corresponding to vector v
M = [...
      0    -v(3)  v(2)
      v(3)  0    -v(1)
     -v(2)  v(1)  0   ];
end

function M = Ss(v)
%Compute symbolic skew symmetric matrix corresponding to vector v
M = sym([...
      0    -v(3)  v(2)
      v(3)  0    -v(1)
     -v(2)  v(1)  0   ]);
end