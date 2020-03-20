---
title: 'Baxter Plays Checkers'
subtitle: 'ROS, MoveIt, OpenCV, AI'
date: 2019-12-13 10:05:55 +0300
description: Programmed a Baxter robot to play a full game of checkers against a human opponent. This project placed 1st in the judged competition between 6 teams!
featured_image: '/images/Projects/baxter_chx/showcase2.gif'
---

## Project Overview

For this project, my team built a ROS (Robot Operating System) Melodic package that allows a Baxter robot to play modern checkers (this means that possible jumps must be taken)! The package gives you the choice to play using our custom AI move generator, or against a human-operated Baxter robot. View it on [GitHub](https://github.com/moribots/final-project-checkers)!

Here's a 6x sped-up video showing a full AI-operated game (minus kings)! 

<iframe width="560" height="315" src="https://www.youtube.com/embed/6ZOXy3TKYeM" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

The core project components are:

* `MoveIt!` for controlling the robot's arms during pick and place routines as well arm setups for viewing the board and safely shutting down.
* `OpenCV` with `CV Bridge` for image processing to identify the board state using ROS images.
* `Minimax + Alpha-Beta Pruning` for intelligent move generation.
* `SMACH`, ROS' state machine package, used to wrap it all together!

The state diagram below explains the main flow of the program:

![smach](/images/Projects/baxter_chx/smach.svg)

### MoveIt!

To move Baxter's arms, an `action server` was created which called `MoveIt!` methods depending on the type of goal received. For example, if a pick or place goal was received from the client, the server called `MoveIt!`'s cartesian path planner in the end-effector space to perform a pick and place for the given coordinates using the following sequence:

1. Pre-move home position (dependent on reachability of target area).
2. Pick standoff position.
3. Pick.
4. Pick standoff position.
5. Place standoff position.
6. Place.
7. Place standoff position.
8. Home configuration away from the board (different from 1).

The video below shows this in realtime:

<iframe width="560" height="315" src="https://www.youtube.com/embed/kUovtpajinI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

The other goal types caused the server to motion plan in the joint space to send the arms to pre-configured positions for viewing the board or clearing the board for the other arm to operate.

### Computer Vision

Our Computer Vision node  uses `cv2.findCheckerboardCorners` to build a coordinate system for the identified board, and projects the centre of each square relative to this coordinate system. Next, the image is split into two color-thresholded streams to look for purple and green pieces, which it identifies using Hough Transforms. Finally, to avoid false-identification, pieces are only considered in the square if their centroid is within a thresholded distance of a given square. In that sense, the squares are labeled either 'empty', 'purple', or 'green', and this is the board state that is relayed back to the state machine. 

The image below shows our robust computer vision pipeline which projects the correct board state despite unwanted elements in the camera's field of vision.

![cv](/images/Projects/baxter_chx/cv.png)

### AI Move Generation

Our AI move generator is a minimax algorithm sped-up with alpha-beta pruning.

![abp](/images/Projects/baxter_chx/abp.png)

In brief, the minimax algorithm is a recursive tree search algorithm where, beginning from the root of the tree, each layer is assigned (in an alternating fashion) to be either maximizing or minimizing. For example, when looking for Baxter's best move in a given board state, the search tree is built such that Baxter's moves are in maximizing layers, beginning from the root, and his opponent's moves are in minimizing layers. Beginning from the root, moves are applied to the board state until a win condition is found, or until the tree depth is reached. Next, that board state for each layer is scored and propagated up through its parent node towards the root of the tree, resulting in the optimal move for baxter, depending on tree depth.

This algorithm is optimized for speed using alpha-beta pruning, introducing aptly-named variables which record the maximum and minimum values of each parent node's children, so that once a child is found to have a worse score than the current maximum or minimum, its own branches are discarded from the search tree. This addition more than doubles the explorable tree-depth for a reasonable wait time whilst still returning equivalently good moves.

To use the package, please check out the [GitHub repository](https://github.com/moribots/final-project-checkers)!