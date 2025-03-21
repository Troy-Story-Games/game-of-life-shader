extends Node
class_name Main

## This sets the framerate. V-Sync is off in project settings otherwise
## this would be capped by monitor refresh rate
## Set to 0 to see the max speed you can run the simulation
@export var simulation_speed: int = 90

## Set the simulation grid size
@export var grid_size: Vector2i = Vector2i(1920, 1080)

## The brush size when drawing on the screen
@export var brush_width: float = 20.0

@onready var current_gen_game_board: Sprite2D = $CurrentGeneration/GameBoard
@onready var next_gen_game_board: Sprite2D = $NextGeneration/GameBoard
@onready var current_generation: SubViewport = $CurrentGeneration
@onready var next_generation: SubViewport = $NextGeneration


func _ready() -> void:
    Engine.max_fps = simulation_speed
    current_gen_game_board.material.set_shader_parameter("brush_width", brush_width)

    current_generation.size = grid_size
    next_generation.size = grid_size

    current_gen_game_board.offset = grid_size / 2
    next_gen_game_board.offset = grid_size / 2

    print(current_gen_game_board.offset)

func _input(event: InputEvent):
    if not event is InputEventMouse:
        return

    if event is InputEventMouseButton:
        current_gen_game_board.material.set_shader_parameter("mouse_pressed", event.pressed)

    if event is InputEventMouseMotion:
        # We need to constrain the mouse position based on the texture size
        # so that we can have a window that's 900x900 while rendering a 50x50
        # game grid for example. This is not needed when the window resolution
        # matches the window size (e.g. no scaling)
        var tex_size = current_generation.size
        var screen_size = get_viewport().size
        var x = remap(event.position.x, 0, screen_size.x, 0, tex_size.x)
        var y = remap(event.position.y, 0, screen_size.y, 0, tex_size.y)
        var tex_mouse_position = Vector2i(x, y)

        current_gen_game_board.material.set_shader_parameter("mouse_position", tex_mouse_position)
