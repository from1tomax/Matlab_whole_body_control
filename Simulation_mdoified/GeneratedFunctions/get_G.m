function G = get_G(qa)
%GET_G
%    G = GET_G(qa,G)

%    This function was generated by the Symbolic Math Toolbox version 8.6.
%    14-Feb-2023 10:02:51
g = 9.8067;
q2 = qa(2);
q3 = qa(3);
q4 = qa(4);
q5 = qa(5);
q6 = qa(6);
q7 = qa(7);
t2 = cos(q2);
t3 = cos(q3);
t4 = cos(q4);
t5 = cos(q5);
t6 = cos(q6);
t7 = cos(q7);
t8 = sin(q2);
t9 = sin(q3);
t10 = sin(q4);
t11 = sin(q5);
t12 = sin(q6);
t13 = sin(q7);
t14 = t2.*t4;
t15 = t2.*t10;
t16 = t4.*t8;
t17 = t8.*t10;
t18 = t8.*t9.*t11;
t22 = t2.*t5.*t9;
t23 = t3.*t5.*t8;
t25 = t2.*t9.*t11;
t26 = t3.*t8.*t11;
t27 = t5.*t8.*t9;
t35 = t8.*(7.9e+1./2.5e+2);
t36 = t2.*t3.*(3.3e+1./4.0e+2);
t40 = t8.*t9.*(3.3e+1./4.0e+2);
t19 = t3.*t14;
t20 = t3.*t15;
t21 = t3.*t16;
t24 = t3.*t17;
t28 = t5.*t9.*t16;
t29 = t9.*t11.*t16;
t32 = t9.*t12.*t17;
t33 = -t25;
t34 = -t27;
t37 = t14.*(3.3e+1./4.0e+2);
t38 = t15.*(4.8e+1./1.25e+2);
t39 = t16.*(4.8e+1./1.25e+2);
t41 = t17.*(3.3e+1./4.0e+2);
t44 = -t40;
t46 = t9.*t17.*(4.8e+1./1.25e+2);
t53 = t9.*t16.*(3.3e+1./4.0e+2);
t30 = -t20;
t31 = -t21;
t42 = -t29;
t43 = -t32;
t45 = -t41;
t47 = t14+t24;
t48 = t17+t19;
t49 = t19.*(3.3e+1./4.0e+2);
t50 = t20.*(4.8e+1./1.25e+2);
t51 = t21.*(4.8e+1./1.25e+2);
t52 = t24.*(3.3e+1./4.0e+2);
t54 = -t46;
t58 = -t53;
t65 = t26+t28;
t55 = -t49;
t56 = -t50;
t57 = -t51;
t59 = t15+t31;
t60 = t16+t30;
t61 = t5.*t48;
t62 = t6.*t47;
t63 = t11.*t48;
t64 = t12.*t47;
t72 = t23+t42;
t73 = t6.*t65;
t66 = t5.*t62;
t67 = t5.*t59;
t68 = -t62;
t69 = t11.*t59;
t70 = t12.*t59;
t71 = t12.*t60;
t75 = t22+t63;
t77 = t33+t61;
t79 = -t6.*(t25-t61);
t82 = t43+t73;
t74 = -t66;
t76 = t18+t67;
t78 = t34+t69;
t85 = t71+t79;
t80 = t6.*t76;
t81 = t12.*t76;
t83 = t70+t74;
t84 = t64+t80;
t86 = t68+t81;
G = [0.0;0.0;0.0;0.0;g.*(t16.*1.0442e-1-t17.*5.317e-2-t19.*5.317e-2-t20.*1.0442e-1+t35+t36+t2.*t9.*2.7454e-2).*(-3.587895)+g.*(t2.*3.141e-3-t8.*2.872e-2).*6.46926e-1+g.*(t16.*(-3.45563e-1)+t20.*3.45563e-1+t22.*4.1065e-2-t25.*1.1953e-2-t35-t36+t41+t49+t61.*1.1953e-2+t63.*4.1065e-2).*1.225946-g.*(t35+t36+t39-t41+t55+t56+t71.*(1.1e+1./1.25e+2)-t6.*t60.*6.1597e-2-t7.*t75.*4.252e-3+t13.*t75.*1.0517e-2+t7.*t85.*1.0517e-2+t13.*t85.*4.252e-3-t6.*(t25-t61).*(1.1e+1./1.25e+2)-t12.*(t25-t61).*6.1597e-2).*7.35522e-1+g.*(t22.*1.0517e-2-t35-t36-t39+t41+t49+t50+t63.*1.0517e-2-t71.*6.0149e-2+t6.*t60.*1.4117e-2+t6.*(t25-t61).*6.0149e-2+t12.*(t25-t61).*1.4117e-2).*1.666555-g.*(t8.*2.49498e-1+t2.*t3.*2.7518e-2-t2.*t9.*3.9252e-2).*3.228604;g.*(t23.*(-4.1065e-2)+t26.*1.1953e-2+t28.*1.1953e-2+t29.*4.1065e-2+t44+t53+t9.*t17.*3.45563e-1).*(-1.225946)+g.*(t3.*t8.*3.9252e-2+t8.*t9.*2.7518e-2).*3.228604-g.*(t44+t3.*t8.*2.7454e-2+t9.*t16.*5.317e-2+t9.*t17.*1.0442e-1).*3.587895-g.*(t32.*(1.1e+1./1.25e+2)+t44+t46+t53-t73.*(1.1e+1./1.25e+2)-t12.*t65.*6.1597e-2-t7.*t72.*4.252e-3+t13.*t72.*1.0517e-2+t7.*(t32-t73).*1.0517e-2+t13.*(t32-t73).*4.252e-3-t6.*t9.*t17.*6.1597e-2).*7.35522e-1+g.*(t23.*1.0517e-2-t29.*1.0517e-2-t32.*6.0149e-2+t40+t54+t58+t73.*6.0149e-2+t12.*t65.*1.4117e-2+t6.*t9.*t17.*1.4117e-2).*1.666555;g.*(t14.*5.317e-2+t15.*1.0442e-1-t21.*1.0442e-1+t24.*5.317e-2).*(-3.587895)-g.*(t37+t38+t52+t57-t66.*6.0149e-2+t70.*6.0149e-2+t11.*t47.*1.0517e-2-t6.*t59.*1.4117e-2-t5.*t64.*1.4117e-2).*1.666555-g.*(t37+t38+t52+t57-t66.*(1.1e+1./1.25e+2)+t70.*(1.1e+1./1.25e+2)-t6.*t59.*6.1597e-2-t5.*t64.*6.1597e-2-t7.*(t66-t70).*1.0517e-2-t13.*(t66-t70).*4.252e-3+t7.*t11.*t47.*4.252e-3-t11.*t13.*t47.*1.0517e-2).*7.35522e-1-g.*(t15.*3.45563e-1-t21.*3.45563e-1+t37+t52+t5.*t47.*1.1953e-2+t11.*t47.*4.1065e-2).*1.225946;g.*(t7.*t76.*(-4.252e-3)+t13.*t76.*1.0517e-2+t6.*(t27-t69).*(1.1e+1./1.25e+2)+t12.*(t27-t69).*6.1597e-2+t6.*t7.*(t27-t69).*1.0517e-2+t6.*t13.*(t27-t69).*4.252e-3).*7.35522e-1-g.*(t18.*1.0517e-2+t67.*1.0517e-2-t6.*(t27-t69).*6.0149e-2-t12.*(t27-t69).*1.4117e-2).*1.666555-g.*(t18.*4.1065e-2+t27.*1.1953e-2+t67.*4.1065e-2-t69.*1.1953e-2).*1.225946;g.*(t62.*(1.1e+1./1.25e+2)+t64.*6.1597e-2+t80.*6.1597e-2-t81.*(1.1e+1./1.25e+2)+t7.*(t62-t81).*1.0517e-2+t13.*(t62-t81).*4.252e-3).*7.35522e-1+g.*(t62.*6.0149e-2+t64.*1.4117e-2+t80.*1.4117e-2-t81.*6.0149e-2).*1.666555;g.*(t7.*t84.*(-4.252e-3)+t13.*t84.*1.0517e-2+t7.*(t27-t69).*1.0517e-2+t13.*(t27-t69).*4.252e-3).*(-7.35522e-1)];
