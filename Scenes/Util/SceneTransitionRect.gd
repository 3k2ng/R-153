extends ColorRect

export (String, FILE, "*.tscn") var next_scene_path

onready var _animation_player = $AnimationPlayer

func _ready() -> void:
	_animation_player.play_backwards("fade")

func transition_to(_next_scene := next_scene_path) -> void:
	_animation_player.play("fade")
	yield(_animation_player, "animation_finished")
	get_tree().change_scene(_next_scene)
