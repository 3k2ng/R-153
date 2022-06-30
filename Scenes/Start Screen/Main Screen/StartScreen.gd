extends Control

onready var _start_game = $"Menu/Start Game"
onready var _quit = $"Menu/Quit"
onready var _transition_rect = $SceneTransitionRect

var _focused := false

func _input(event: InputEvent) -> void:
	
	if _is_UpDownLeftRight(event):
		Sounds.ui_hover_over.play()
	
	if not _focused:
		if event.is_action_pressed("Down"):
			_quit.grab_focus()
			_focused = true
		elif event.is_action_pressed("Up") or event.is_action_pressed("Left") or event.is_action_pressed("Right"):
			_start_game.grab_focus()
			_focused = true

func _is_UpDownLeftRight(event: InputEvent) -> bool:
	return event.is_action_pressed("Up") or event.is_action_pressed("Down") or event.is_action_pressed("Left") or event.is_action_pressed("Right")

func _on_Start_Game_pressed() -> void:
	Sounds.ui_next_screen.play()
	_transition_rect.transition()

func _on_Settings_pressed() -> void:
	Sounds.ui_next_screen.play()
	_transition_rect.transition_to("res://Scenes/Start Screen/Settings/SettingsScreen.tscn")

func _on_Quit_pressed() -> void:
	get_tree().quit()

func _on_menu_button_mouse_entered() -> void:
	Sounds.ui_hover_over.play()


