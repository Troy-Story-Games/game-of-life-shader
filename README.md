# Conway's Game of Life as a Godot 4.x Project

Implemented with a shader and no loops. Change the brush size, simulation speed, grid size, etc. by using the interface at the top. Pause/resume/clear and draw with the mouse by clicking and dragging.

Playing around with a way slower simulation speed (5 FPS) on a lower resolution (something like 128x128) really shows what's going on. And if you want to see just how fast a shader can rip through this simulation, go ahead and set the FPS to 0 and watch the FPS output in the debugger. I was able to hit between 2900 and 3400 FPS.

The shader was pretty straightforward, but I was stuck for hours trying to get it to actually simulate more than a single step. I found this: https://godotengine.org/asset-library/asset/842 for Godot 3 and was able to figure out what they were doing with the viewports. For the simulation to run in this way I use 2 viewports with 2 sprites and final texture rect. Each viewport has the other viewport as its texture. When white pixels show up on one, they are processed back and forth by the shader on each viewport and are rendered to the screen by the texture rect.

A solution without viewports would have made the shader more complicated with multiple internal textures to go between and I wanted the shader to be dirt simple to read/understand.
