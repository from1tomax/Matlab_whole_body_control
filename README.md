# Whole Body Controller



## Prerquisites

**Tested version:**

Matlab 2020b

**Required toolboxes:**

Robotics System Toolbox 

*Also other toolboxes might be needed, Matlab should notify you in that case.*

## Folder structure
`DynCalc` contains the code needed to compute the functions that describe the kinematics and the dynamics of the robot.

`Simulation` contains the code used to simulate the whole-body control law. 

In some cases the file name terminates with "ROS", this means that the code is thought to be run in connection with a Gazebo environment.

## Run Simulation
The file of most interest is `RB_KAIROS_ImpControl_OpSpace_quat_2020b_safety_main.m` 
which runs a simulation of the whole-body control law together with the safety algorithm. 
It is sufficient to press "RUN" in the matlab environment to open the related simulink file and perform the simulation. 