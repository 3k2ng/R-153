extends Control

onready var _start_game = $"Menu/Start Game"
onready var _transition_rect = $SceneTransitionRect

func _ready() -> void:
	_start_game.grab_focus()



func _on_Start_Game_pressed() -> void:
	_transition_rect.transition_to()
