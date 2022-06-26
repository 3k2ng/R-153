class_name SceneTransitionRect
extends CanvasLayer

export (String, FILE, "*.tscn") var next_scene_path

onready var _animation_player = $AnimationPlayer

func _ready() -> void:
	layer = 100
	_animation_player.play_backwards("fade")

func transition() -> void:
	_animation_player.play("fade")
	yield(_animation_player, "animation_finished")
	get_tree().change_scene(next_scene_path)

func transition_to(next_scene_path) -> void:
	_animation_player.play("fade")
	yield(_animation_player, "animation_finished")
	get_tree().change_scene(next_scene_path)
