extends Control

onready var _start_game = $"Menu/Start Game"
onready var _quit = $"Menu/Quit"
onready var _transition_rect = $SceneTransitionRect

var _focused := false

func _input(event: InputEvent) -> void:
	if not _focused:
		if event.is_action_pressed("Down"):
			_quit.grab_focus()
			_focused = true
		elif event.is_action_pressed("Up") or event.is_action_pressed("Left") or event.is_action_pressed("Right"):
			_start_game.grab_focus()
			_focused = true
			

func _on_Start_Game_pressed() -> void:
	_transition_rect.transition()

func _on_Quit_pressed() -> void:
	get_tree().quit()
