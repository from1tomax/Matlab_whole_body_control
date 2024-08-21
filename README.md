# Whole Body Controller



## Prerquisites

**Tested version:**

Matlab 2020b

**Required toolboxes:**

Robotics System Toolbox 

*Also other toolboxes might be needed, Matlab should notify you in that case.*

## Folder structure
`calc_COM` is a simple scrip to calculate the central of mass.

`DynCalc` contains the code needed to compute the functions that describe the kinematics and the dynamics of the robot.

`Simulation_modified` contains the code used to simulate the control law. 

## Run Simulation
 - Enter **Whole_body** folder, open `RB_KAIROS_ImpControl_OpSpace_quat_2020b_safety_main.m`
 - Enter **Arm only folder** folder, open `RB_KAIROS_ImpControl_OpSpace_ArmOnly.m`
 - Enter **Base only** folder, open `RB_KAIROS_ImpControl_OpSpace_BaseOnly.m`

It is sufficient to press "RUN" in the matlab environment to open the related simulink file and perform the simulation. 