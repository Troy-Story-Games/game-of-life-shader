extends CanvasLayer
class_name HUD

signal paused()
signal cleared()
signal brush_size_changed(value: float)
signal fps_changed(value: int)
signal grid_changed(value: Vector2i)

var is_paused: bool = false

@onready var brush_size_label: Label = $HUDContainer/MarginContainer/TopPanel/BrushSizeLabel
@onready var fps_label: Label = $HUDContainer/MarginContainer/TopPanel/FPSLabel
@onready var pause_button: Button = $HUDContainer/MarginContainer/TopPanel/PauseButton
@onready var fps_line_edit: LineEdit = $HUDContainer/MarginContainer/TopPanel/FPSLineEdit
@onready var grid_line_edit: LineEdit = $HUDContainer/MarginContainer/TopPanel/GridLineEdit

func _ready() -> void:
    var parent = get_parent() as Main
    brush_size_label.text = "Brush Size: " + str(parent.brush_width)
    grid_line_edit.placeholder_text = "Grid: " + str(parent.grid_size.x) + "x" + str(parent.grid_size.y)

func _process(_delta: float) -> void:
    fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _on_pause_button_pressed() -> void:
    is_paused = !is_paused
    if is_paused:
        pause_button.text = "Resume"
    else:
        pause_button.text = "Pause"
    paused.emit()

func _on_clear_button_pressed() -> void:
    cleared.emit()

func _on_brush_size_value_changed(value: float) -> void:
    brush_size_label.text = "Brush Size: " + str(value)
    brush_size_changed.emit(value)

func _on_fps_line_edit_text_submitted(new_text: String) -> void:
    fps_changed.emit(new_text.to_int())
    fps_line_edit.text = ""
    fps_line_edit.placeholder_text = "set fps"

func _on_grid_line_edit_text_submitted(new_text: String) -> void:
    var xy = new_text.split("x", false, 2)
    grid_changed.emit(Vector2i(xy[0].to_int(), xy[1].to_int()))
    grid_line_edit.text = ""
    grid_line_edit.placeholder_text = "Grid: " + new_text
