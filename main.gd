extends Node
class_name Main

## This sets the framerate. V-Sync is off in project settings otherwise
## this would be capped by monitor refresh rate
## Set to 0 to see the max speed you can run the simulation
@export var simulation_speed: int = 90

## Set the simulation grid size
@export var grid_size: Vector2i = Vector2i(512, 512)

## The brush size when drawing on the screen
@export var brush_width: float = 20.0

var paused: bool = false

@onready var current_gen_game_board: Sprite2D = $CurrentGeneration/GameBoard
@onready var next_gen_game_board: Sprite2D = $NextGeneration/GameBoard
@onready var current_generation: SubViewport = $CurrentGeneration
@onready var next_generation: SubViewport = $NextGeneration
@onready var hud: HUD = $CanvasLayer

func _ready() -> void:
    # Make sure things are okay
    var screen_size = get_viewport().size
    assert(grid_size.x <= screen_size.x && grid_size.y <= screen_size.y,
        "grid_size cannot exceed resolution. Adjust project settings to increase resolution or decrease the grid size.")

    Engine.max_fps = simulation_speed
    current_gen_game_board.material.set_shader_parameter("brush_width", brush_width)

    set_grid_size(grid_size)

func set_grid_size(sz: Vector2i) -> void:
    current_generation.size = sz
    next_generation.size = sz

    # We need this b/c sprites are positioned by their texture center, we need top left corner
    # so that pixel coordinates in the sprite match the viewport, texture rect, and screen coordinates
    current_gen_game_board.offset = sz / 2
    next_gen_game_board.offset = sz / 2

func clear_canvas() -> void:
    current_gen_game_board.material.set_shader_parameter("clear", true)
    next_gen_game_board.material.set_shader_parameter("clear", true)

    await get_tree().create_timer(0.5).timeout

    current_gen_game_board.material.set_shader_parameter("clear", false)
    next_gen_game_board.material.set_shader_parameter("clear", false)

func _on_canvas_layer_brush_size_changed(value: float) -> void:
    current_gen_game_board.material.set_shader_parameter("brush_width", value)

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
        var tex_mouse_position = Vector2(x, y)

        current_gen_game_board.material.set_shader_parameter("mouse_position", tex_mouse_position)

func _on_canvas_layer_paused() -> void:
    paused = !paused
    current_gen_game_board.material.set_shader_parameter("paused", paused)
    next_gen_game_board.material.set_shader_parameter("paused", paused)

func _on_canvas_layer_cleared() -> void:
    clear_canvas()

func _on_hud_fps_changed(value: int) -> void:
    Engine.max_fps = value

func _on_hud_grid_changed(value: Vector2i) -> void:
    set_grid_size(value)
    clear_canvas()
