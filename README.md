# Godot input buffer

##### More responsive input in Godot

Ever had a game ignore your input because you pressed the button a millisecond too early? This project fixes that problem by implementing an input buffer, which stores inputs for a short window of time so their associated actions can be executed in the next possible frame. It's easy to add it to any project, supports keyboard and controller input, and works with both GDScript and C#. Your players won't know it's there, but they'll feel it!

## Usage

### GDScript

1. Put a copy of the `input_buffer.gd` file into your project. You can clone the repository, download a ZIP of it, or simply copy and paste the file's contents into a new file, whatever works for you. Once you have the file, move it into anywhere in your project folder.
2. Add the `input_buffer.gd` script to your project's AutoLoad settings. More information on how to do that can be found [here](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html#autoload).
3. That's all the setup you need! To use it in your game, just call `InputBuffer.is_action_press_buffered` where you'd usually call `Input.is_action_just_pressed`

MIT License
