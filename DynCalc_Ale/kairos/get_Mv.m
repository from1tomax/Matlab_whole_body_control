function Mv = get_Mv(qv)
%GET_MV
%    MV = GET_MV(qv)

%    This function was generated by the Symbolic Math Toolbox version 8.6.
%    05-May-2023 11:52:18

phi = qv(3);
t2 = cos(phi);
t3 = sin(phi);
t4 = t2.*1.3554857805;
t5 = t3.*1.3554857805;
t6 = t3.*4.378475871315;
t9 = t2.*4.378475871315;
t7 = -t4;
t8 = -t5;
t10 = -t9;
t11 = t6+t7;
t12 = t8+t10;
Mv = reshape([2.0165e+2,0.0,t11,0.0,0.0,0.0,0.0,0.0,2.0165e+2,t12,0.0,0.0,0.0,0.0,t11,t12,1.209842138233319e+1,0.0,0.0,0.0,0.0,0.0,0.0,0.0,5.241925e-2,0.0,0.0,0.0,0.0,0.0,0.0,0.0,5.241925e-2,0.0,0.0,0.0,0.0,0.0,0.0,0.0,5.241925e-2,0.0,0.0,0.0,0.0,0.0,0.0,0.0,5.241925e-2],[7,7]);
