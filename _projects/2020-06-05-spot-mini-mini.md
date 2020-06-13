---
title: 'Spot Mini Mini'
subtitle: 'Quadruped Locomotion, Bezier Gait, Reinforcement Learning'
date: 2020-06-04 10:05:55 +0300
description: Developed Pybullet Spot Environment and deployed 12-point Bezier-curve gait as baseline for RL task. 
featured_image: '/images/Projects/spot-mini-mini/spot-mini-mini.gif'
---

## Project Overview
The goal of this project is to deploy a remote-controlled quadruped platform on which ORB-SLAM2 can be performed. For phase one of this two-part project, I built a Pybullet environment using the open-source Spot Micro CAD models for a fairly accessible (< $1000) robot. Then, I deployed a 12-point Bezier gait with proprioceptive feedback for phase reset, and used this as a baseline for Reinforcement Learning tasks on various terrain environments. Feel free to check out the package on [Github](https://github.com/moribots/spot_mini_mini).

<div class="gallery" data-columns="1">
	<img src="/images/Projects/spot-mini-mini/spot-mini-mini.gif" style="width: 100%">
</div>

## Inverse Kinematics
After deriving the [Inverse Kinematics](https://www.researchgate.net/publication/320307716_Inverse_Kinematic_Analysis_Of_A_Quadruped_Robot) for each leg, the next step was to describe the IK for the body itself. The approach used here considers a **world frame** $w$, which is the robot centroid's base position, and a **body frame** $b$, describing the robot's pose relative to the world frame. In addition, we have $T_{wh}$, which is a transform from the world frame to the robot's hip: this describes the base transform between the robot centroid and the hip. Finally, we have our inputs: $T_{wb}$, which describes the desired transform from **world** to **body** (RPY and Translation), and $T_{bf}$, the desired **foot** position relative to the transformed **body** - this is useful for gait generation. The output of our process is $T_{hf}$, the transform between each **hip** and its respective **foot** required to achieve this motion. The gallery below shows our inputs and outputs, as well as the actual process for getting $T_{hf}$. Note that this diagram is facing the robot, so the example shown is for **body roll**.

<div class="gallery" data-columns="1">
	<img src="/images/Projects/spot-mini-mini/io.jpg" style="width: 70%">
	<img src="/images/Projects/spot-mini-mini/thf.jpg" style="width: 70%">
</div>

Here's a gif of the body IK in action:

<div class="gallery" data-columns="1">
	<img src="/images/Projects/spot-mini-mini/spot_rpy.gif" style="width: 60%">
</div>


## Bezier Gait
The [Bezier Gait](https://dspace.mit.edu/handle/1721.1/98270) deployed in this project uses a closed-loop trajectory generator, which resets whenever the reference foot (front left) hits the ground after a swing. The Bezier curve for the Swing period is made up of 12 points, where some of them overlap to induce zero vertical velocities or changes in foot direction. The Table and image below summarize the gait:


<div class="gallery" data-columns="1">
	<img src="/images/Projects/spot-mini-mini/bezier.jpg" style="width: 60%">
	<img src="/images/Projects/spot-mini-mini/bezier_points.png" style="width: 120%">
</div>

For the Stance portion of the gait, we simply deploy a sinusoidal curve whose z-amplitude is the desired penetration depth and whose x-amplitude is the half the Stride Length. Note, for y-coordinate foot motion, we apply the same Bezier and Sinusoidal curves as for x-coordinate motions.

Here's what this looks like on Spot:
<div class="gallery" data-columns="1">
	<img src="/images/Projects/spot-mini-mini/spot_bezier.gif" style="width: 50%">
</div>

I implemented Yaw control based on [this paper](http://www.inase.org/library/2014/santorini/bypaper/ROBCIRC/ROBCIRC-54.pdf) which treats the quadruped as a four-wheel steering car. The intuition here is that to turn clockwise, both front feet should move towards the rear-left, and both back feet should move towards the rear-right of the robot during the stance phase. To adequately trace a circular path while doing this, the directional vector of each foot is modulated at each iteration by $\theta_{mod}$ to remain tangent to said circle, as shown in the second image below:

<div class="gallery" data-columns="1">
	<img src="/images/Projects/spot-mini-mini/yaw_overview.jpg" style="width: 25%">
	<img src="/images/Projects/spot-mini-mini/yaw_mod.jpg" style="width: 50%">
</div>

Here's what this looks like on Spot:
<div class="gallery" data-columns="1">
	<img src="/images/Projects/spot-mini-mini/spot_yaw.gif" style="width: 50%">
</div>

<!-- ## Environment and Terrain

The environment provided here is largely derived from Pybullet's **minitaur** example. In fact, it is nearly identical aside from accounting for the differences in the robots themselves. Another difference is the terrain used in the environment, for which I provide 3 options. First, the **plane** terrain (default) is the unmodified ground surface in Pybullet. Next, you have the option to use a programmatically generated heightfield (see `heightfield.py`) using **height_field=True** in the env constructor, or an image-generated one, for which you also need **img_heightfield=True**. You should experiment with the meshscale argument as well, as this will change the characteristics of your terrain.

<div class="gallery" data-columns="1">
	<img src="/images/Projects/spot-mini-mini/rough.png" style="width: 100%">
	<img src="/images/Projects/spot-mini-mini/mountain.png" style="width: 100%">
</div>

## Reinforcement Learning Task -->




