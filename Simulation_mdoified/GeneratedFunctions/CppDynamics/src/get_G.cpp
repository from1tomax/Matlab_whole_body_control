//
//  Academic License - for use in teaching, academic research, and meeting
//  course requirements at degree granting institutions only.  Not for
//  government, commercial, or other organizational use.
//
//  get_G.cpp
//
//  Code generation for function 'get_G'
//


// Include files
#include "get_G.h"
#include <cmath>

// Function Definitions
void get_G(const double qa[7], double G[10])
{
  double G_tmp;
  double b_G_tmp;
  double c_G_tmp;
  double t10;
  double t11;
  double t12;
  double t13;
  double t14;
  double t15;
  double t16;
  double t17;
  double t18;
  double t18_tmp;
  double t19;
  double t2;
  double t20;
  double t21;
  double t22;
  double t23;
  double t24;
  double t25;
  double t25_tmp;
  double t26;
  double t26_tmp;
  double t27;
  double t28;
  double t29;
  double t3;
  double t32;
  double t35;
  double t36;
  double t36_tmp;
  double t37;
  double t39;
  double t4;
  double t40;
  double t41;
  double t46;
  double t46_tmp;
  double t47;
  double t49;
  double t5;
  double t50;
  double t52;
  double t53;
  double t53_tmp;
  double t59;
  double t6;
  double t61;
  double t62;
  double t64;
  double t65;
  double t66;
  double t67;
  double t69;
  double t7;
  double t70;
  double t71;
  double t72;
  double t73;
  double t75;
  double t76;
  double t8;
  double t80;
  double t81;
  double t84;
  double t85;
  double t9;

  // GET_G
  //     G = GET_G(qa,G)
  //     This function was generated by the Symbolic Math Toolbox version 8.6.
  //     14-Feb-2023 10:02:51
  t2 = std::cos(qa[1]);
  t3 = std::cos(qa[2]);
  t4 = std::cos(qa[3]);
  t5 = std::cos(qa[4]);
  t6 = std::cos(qa[5]);
  t7 = std::cos(qa[6]);
  t8 = std::sin(qa[1]);
  t9 = std::sin(qa[2]);
  t10 = std::sin(qa[3]);
  t11 = std::sin(qa[4]);
  t12 = std::sin(qa[5]);
  t13 = std::sin(qa[6]);
  t14 = t2 * t4;
  t15 = t2 * t10;
  t16 = t4 * t8;
  t17 = t8 * t10;
  t18_tmp = t8 * t9;
  t18 = t18_tmp * t11;
  t22 = t2 * t5 * t9;
  t23 = t3 * t5 * t8;
  t25_tmp = t2 * t9;
  t25 = t25_tmp * t11;
  t26_tmp = t3 * t8;
  t26 = t26_tmp * t11;
  t27 = t5 * t8 * t9;
  t35 = t8 * 0.316;
  t36_tmp = t2 * t3;
  t36 = t36_tmp * 0.0825;
  t40 = t18_tmp * 0.0825;
  t19 = t3 * t14;
  t20 = t3 * t15;
  t21 = t3 * t16;
  t24 = t3 * t17;
  t28 = t5 * t9 * t16;
  t29 = t9 * t11 * t16;
  t32 = t9 * t12 * t17;
  t37 = t14 * 0.0825;
  t39 = t16 * 0.384;
  t41 = t17 * 0.0825;
  t46_tmp = t9 * t17;
  t46 = t46_tmp * 0.384;
  t53_tmp = t9 * t16;
  t53 = t53_tmp * 0.0825;
  t47 = t14 + t24;
  t4 = t17 + t19;
  t49 = t19 * 0.0825;
  t50 = t20 * 0.384;
  t52 = t24 * 0.0825;
  t65 = t26 + t28;
  t59 = t15 + -t21;
  t10 = t16 + -t20;
  t61 = t5 * t4;
  t62 = t6 * t47;
  t3 = t11 * t4;
  t64 = t12 * t47;
  t72 = t23 + -t29;
  t73 = t6 * t65;
  t66 = t5 * t62;
  t67 = t5 * t59;
  t69 = t11 * t59;
  t70 = t12 * t59;
  t71 = t12 * t10;
  t75 = t22 + t3;
  t76 = t18 + t67;
  t4 = t25 - t61;
  t85 = t71 + -t6 * t4;
  t80 = t6 * t76;
  t81 = t12 * t76;
  t84 = t64 + t80;
  G[0] = 0.0;
  G[1] = 0.0;
  G[2] = 0.0;
  G[3] = 0.0;
  G_tmp = t6 * t10;
  b_G_tmp = t6 * t4;
  c_G_tmp = t12 * t4;
  G[4] = ((((9.8067 * ((((((t16 * 0.10442 - t17 * 0.05317) - t19 * 0.05317) -
    t20 * 0.10442) + t35) + t36) + t25_tmp * 0.027454) * -3.587895 + 9.8067 *
             (t2 * 0.003141 - t8 * 0.02872) * 0.646926) + 9.8067 * (((((((((t16 *
    -0.345563 + t20 * 0.345563) + t22 * 0.041065) - t25 * 0.011953) - t35) - t36)
    + t41) + t49) + t61 * 0.011953) + t3 * 0.041065) * 1.225946) - 9.8067 *
           (((((((((((((t35 + t36) + t39) - t41) + -t49) + -t50) + t71 * 0.088)
                  - G_tmp * 0.061597) - t7 * t75 * 0.004252) + t13 * t75 *
                0.010517) + t7 * t85 * 0.010517) + t13 * t85 * 0.004252) -
             b_G_tmp * 0.088) - c_G_tmp * 0.061597) * 0.735522) + 9.8067 *
          (((((((((((t22 * 0.010517 - t35) - t36) - t39) + t41) + t49) + t50) +
               t3 * 0.010517) - t71 * 0.060149) + G_tmp * 0.014117) + b_G_tmp *
            0.060149) + c_G_tmp * 0.014117) * 1.666555) - 9.8067 * ((t8 *
    0.249498 + t36_tmp * 0.027518) - t25_tmp * 0.039252) * 3.228604;
  G_tmp = t32 - t73;
  b_G_tmp = t12 * t65;
  c_G_tmp = t6 * t9 * t17;
  G[5] = (((9.8067 * ((((((t23 * -0.041065 + t26 * 0.011953) + t28 * 0.011953) +
    t29 * 0.041065) + -t40) + t53) + t46_tmp * 0.345563) * -1.225946 + 9.8067 *
            (t26_tmp * 0.039252 + t18_tmp * 0.027518) * 3.228604) - 9.8067 * (((
              -t40 + t26_tmp * 0.027454) + t53_tmp * 0.05317) + t46_tmp *
            0.10442) * 3.587895) - 9.8067 * ((((((((((t32 * 0.088 + -t40) + t46)
    + t53) - t73 * 0.088) - b_G_tmp * 0.061597) - t7 * t72 * 0.004252) + t13 *
              t72 * 0.010517) + t7 * G_tmp * 0.010517) + t13 * G_tmp * 0.004252)
           - c_G_tmp * 0.061597) * 0.735522) + 9.8067 * ((((((((t23 * 0.010517 -
    t29 * 0.010517) - t32 * 0.060149) + t40) + -t46) + -t53) + t73 * 0.060149) +
    b_G_tmp * 0.014117) + c_G_tmp * 0.014117) * 1.666555;
  G_tmp = ((t37 + t15 * 0.384) + t52) + -(t21 * 0.384);
  b_G_tmp = t6 * t59;
  c_G_tmp = t5 * t64;
  t4 = t66 - t70;
  t10 = t11 * t47;
  G[6] = ((9.8067 * (((t14 * 0.05317 + t15 * 0.10442) - t21 * 0.10442) + t24 *
                     0.05317) * -3.587895 - 9.8067 * (((((G_tmp - t66 * 0.060149)
    + t70 * 0.060149) + t10 * 0.010517) - b_G_tmp * 0.014117) - c_G_tmp *
            0.014117) * 1.666555) - 9.8067 * ((((((((G_tmp - t66 * 0.088) + t70 *
    0.088) - b_G_tmp * 0.061597) - c_G_tmp * 0.061597) - t7 * t4 * 0.010517) -
             t13 * t4 * 0.004252) + t7 * t11 * t47 * 0.004252) - t11 * t13 * t47
           * 0.010517) * 0.735522) - 9.8067 * (((((t15 * 0.345563 - t21 *
    0.345563) + t37) + t52) + t5 * t47 * 0.011953) + t10 * 0.041065) * 1.225946;
  G_tmp = t27 - t69;
  b_G_tmp = t6 * G_tmp;
  c_G_tmp = t12 * G_tmp;
  G[7] = (9.8067 * (((((t7 * t76 * -0.004252 + t13 * t76 * 0.010517) + b_G_tmp *
                       0.088) + c_G_tmp * 0.061597) + t6 * t7 * G_tmp * 0.010517)
                    + t6 * t13 * G_tmp * 0.004252) * 0.735522 - 9.8067 * (((t18 *
             0.010517 + t67 * 0.010517) - b_G_tmp * 0.060149) - c_G_tmp *
           0.014117) * 1.666555) - 9.8067 * (((t18 * 0.041065 + t27 * 0.011953)
    + t67 * 0.041065) - t69 * 0.011953) * 1.225946;
  b_G_tmp = t62 - t81;
  G[8] = 9.8067 * (((((t62 * 0.088 + t64 * 0.061597) + t80 * 0.061597) - t81 *
                     0.088) + t7 * b_G_tmp * 0.010517) + t13 * b_G_tmp *
                   0.004252) * 0.735522 + 9.8067 * (((t62 * 0.060149 + t64 *
    0.014117) + t80 * 0.014117) - t81 * 0.060149) * 1.666555;
  G[9] = 9.8067 * (((t7 * t84 * -0.004252 + t13 * t84 * 0.010517) + t7 * G_tmp *
                    0.010517) + t13 * G_tmp * 0.004252) * -0.735522;
}

// End of code generation (get_G.cpp)