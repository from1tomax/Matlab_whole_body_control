function Jup = J_frame_up(rotation)
    % This function calculates the update matrix for a Jacobian to refer
    % to a different frame. Therefore, the rotation between the frames is
    % necessary. Precisely: p_new = R_new_old * p_old, so the rotation that
    % needs to be applied to the old points to be rotated in the new frame.
    
    %Input:
    % rotation: 3x3 rotation matrix (or TF)
    
    r = 1:3; %rotational part cutter
    calc_symbolic = false; %determines automatically if symbolic or not
    if isa(rotation,'sym') || isa(rotation,'symfun') 
        calc_symbolic = true;
    end
    
    % input check
    if ~(all(size(rotation) == [3 3]) || iseukltrans(rotation) || all(size(rotation) == [3 4]))
        error('J_frame_up: Unknown rotationmatrix format!');
    end
        
    % The update for the Jacobian:
    if calc_symbolic
        Jup = sym(eye(6));
    else
        Jup = eye(6);
    end
    % On diagonal are rotation matricies that rotate the velocities
    % from old to new frame
    Jup(1:3,1:3) = rotation(r,r);
    Jup(4:6,4:6) = rotation(r,r); 
        
end

function [Result] = iseukltrans(M)
%ISEUKLTRANS pr�ft ob M eine Euklidische Transformation ist

%% Check M
Result = all(size(M) == [4 4]) && all(M(4,1:4)==[0 0 0 1]) ;

end
