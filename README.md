Please note that this is only for school project , if you have any problem about copyright or ownership please contact me right away !!
# Wind Turbine MPPT Controller Design

## Overview
This project models a wind turbine energy conversion system and implements a Maximum Power Point Tracking (MPPT) controller using Perturb & Observe (P&O) and Tip Speed Ratio (TSR) algorithms.

**Techniques:** MATLAB, Simulink, PID Control, Dynamic Modeling.

## System Architecture
<img width="1445" height="465" alt="image" src="https://github.com/user-attachments/assets/48751cb8-a063-42b4-922d-12c1ede7dffe" />

*The system consists of the Wind Turbine Aerodynamics model, Drive Train, PMSG Generator, and the MPPT Controller.*
(For detail of subsystems please consider opening the slx file.)

## Key Features
* **Dynamic Modeling:** Mathematical modeling of the turbine aerodynamics.
* **Control Algorithm:** Implements P&O to track optimal power output under varying wind speeds.
* **Simulation Results:** Achieved 95% efficiency in power extraction in simulation.

## Results
*P&O results*
<img width="852" height="911" alt="image" src="https://github.com/user-attachments/assets/0baafd31-de4a-4ea3-aefc-99d7b3ef8293" />
*TSR result*
<img width="980" height="798" alt="image" src="https://github.com/user-attachments/assets/9f3f0f3c-c569-4daa-854f-a6a12debfb26" />

*Graphs showing the controllers tracking the maximum power curve.*
*These are only the result of two main methods, in the project there are also two other methods which are only AI application on improving efficiency. And if you're interested, you can improve them for better performance
## How to Run
1. Open `pid_testing.slx` in MATLAB/Simulink (Version 2019b or later).
2. Run the `PID.m` script to initialize variables.
3. You also need to run the training scripts (If I forget any scripts , please forgive me)
4. Run the simulation.
