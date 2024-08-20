close all;
clear all;

% Load Panda URDF 
panda = importrobot("panda_gen.urdf")

% Define new Panda base to be attached to the vehicle base (KAIROS)
arm_base = rigidBody("arm_base");

jnt_arm_base = rigidBodyJoint("joint_arm_base");
arm_base.Joint = jnt_arm_base;
arm_base.Joint.setFixedTransform(trvec2tform([-0.275,-0.155, 0.6900-0.127])*eul2tform([pi 0 0]));

% Retrieve each arm link
link1 = panda.Bodies{1,1};
link2 = panda.Bodies{1,2};
link3 = panda.Bodies{1,3};
link4 = panda.Bodies{1,4};
link5 = panda.Bodies{1,5};
link6 = panda.Bodies{1,6};
link7 = panda.Bodies{1,7};
link8 = panda.Bodies{1,8};

addVisual(arm_base, "Mesh", 'Meshes/link0.stl');
addVisual(link1, "Mesh", 'Meshes/link1.stl');
addVisual(link2, "Mesh", 'Meshes/link2.stl');
addVisual(link3, "Mesh", 'Meshes/link3.stl');
addVisual(link4, "Mesh", 'Meshes/link4.stl');
addVisual(link5, "Mesh", 'Meshes/link5.stl');
addVisual(link6, "Mesh", 'Meshes/link6.stl');
addVisual(link7, "Mesh", 'Meshes/link7.stl');

% Define vehicle
mobile_base1 = rigidBody("mobile_base1"); %Prismatic joint x
mobile_base2 = rigidBody("mobile_base2"); %Prismatic joint y
mobile_base3 = rigidBody("mobile_base3"); %Revolute joint z

jntX_mobile_base = rigidBodyJoint("jntX_mobile_base", "prismatic");
jntX_mobile_base.JointAxis = [1 0 0];
jntY_mobile_base = rigidBodyJoint("jntY_mobile_base", "prismatic");
jntY_mobile_base.JointAxis = [0 1 0];
jntRotZ_mobile_base = rigidBodyJoint("jntRotZ_mobile_base", "revolute");
jntRotZ_mobile_base.JointAxis = [0 0 1];
mobile_base1.Joint = jntX_mobile_base;
mobile_base2.Joint = jntY_mobile_base;
mobile_base3.Joint = jntRotZ_mobile_base;

mobile_base1.Joint.setFixedTransform(trvec2tform([0,0,0.127]));
addVisual(mobile_base3, "Mesh", 'Meshes/summit_xlsk_plus.stl');

% Create Robot model by attaching each rigid body
RB_Kairos = rigidBodyTree;

RB_Kairos.addBody(mobile_base1,'base');
RB_Kairos.addBody(mobile_base2,'mobile_base1');
RB_Kairos.addBody(mobile_base3,'mobile_base2');
RB_Kairos.addBody(arm_base,'mobile_base3');
RB_Kairos.addBody(link1,'arm_base');
RB_Kairos.addBody(link2,'panda_link1');
RB_Kairos.addBody(link3,'panda_link2');
RB_Kairos.addBody(link4,'panda_link3');
RB_Kairos.addBody(link5,'panda_link4');
RB_Kairos.addBody(link6,'panda_link5');
RB_Kairos.addBody(link7,'panda_link6');
RB_Kairos.addBody(link8,'panda_link7');

clear robot arm_base panda
clear -regexp ^link ^mobile ^jnt





