tool
extends Control

export (String) var text = "" setget _set_text, _get_text
export (String, FILE, "*.tscn") var next_scene_path
export (NodePath) var transition_rect_path
export (bool) var locked = false setget _set_locked, _get_locked

onready var _animation_player := $AnimationPlayer
onready var _button := $Button
onready var _transition_rect := get_node(transition_rect_path)

func _ready() -> void:
	_button.text = text
	_button.disabled = locked

func _set_text(value: String) -> void:
	text = value
	if _button != null:
		_button.text = text

func _get_text() -> String:
	return text

func _set_locked(value: bool) -> void:
	locked = value	
	if _button != null:
		_button.disabled = value

func _get_locked() -> bool:
	return locked
	

func _on_Button_mouse_entered() -> void:
	if not locked:
		_animation_player.play("bubble")

func _on_Button_pressed() -> void:
	_transition_rect.transition_to(next_scene_path)

func _on_Button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.is_action_just_pressed("Mouse"):
		if locked:
			if not _animation_player.is_playing():
				_animation_player.play("shake")
