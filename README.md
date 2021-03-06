# MATLAB solution for optimizing BVP

## The Problem
Minimizes

![](https://latex.codecogs.com/svg.latex?\widetilde{\Psi_0}(u,y)=\gamma_y\int_{\Omega_i}(y(x)-y_d)^2dx+\gamma_u\int_{\Omega}u^2(x)dx\quad{\to\quad}min)

With constraints

![](https://latex.codecogs.com/svg.latex?-y''+r(x)y'+g_1(x)y+g_3(x)y^3=f_0(x)+f_u(x))

![](https://latex.codecogs.com/svg.latex?\widetilde{\Psi_1}(u,y)=\int_{\Omega_j}(\left|y(x)-y^+\right|+y(x)-y^+)^2dx=0)

![](https://latex.codecogs.com/svg.latex?u^-\leq{u}\leq{u^+})

## The GUI

To open GUI, run `GUI_V02.m` in MATLAB environment


Fields for model parameters support functions of variable *x* as values

After changing some model-ralted parameters, press the button to see updated results for direct problem (some numerical info and plot). 

![image](https://user-images.githubusercontent.com/8505995/50459591-92c94b80-0975-11e9-92de-ad19517c04e3.png)

## Requirements
MATLAB R2014b or higher.
Version R2015a is recommended.
