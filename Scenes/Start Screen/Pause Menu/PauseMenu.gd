extends CanvasLayer

export (NodePath) var transition_rect_path

onready var _transition_rect : SceneTransitionRect = get_node(transition_rect_path)
onready var _animation_player = $AnimationPlayer
onready var _menu = $Menu
onready var _resume = $Menu/Resume
onready var _exit = $Menu/Exit

onready var _hover_over = $Sounds/hover_over
onready var _next_screen = $Sounds/next_screen
onready var _level_select = $Sounds/level_select

var _focused := false


func _ready() -> void:
	layer = 100
	

func _input(event: InputEvent) -> void:
	
	var paused = get_tree().paused
	
	if event.is_action_pressed("ESC"):
		if not paused:
			# Entered Pause Menu
			_pause()
		else:
			# Exited Pause Menu
			_unpause()
			
	if _is_UpDownLeftRight(event) and paused:
		_hover_over.play()
	
	if paused and not _focused:
		if event.is_action_pressed("Down"):
			_exit.grab_focus()
			_focused = true		
		elif event.is_action_pressed("Up") or event.is_action_pressed("Left") or event.is_action_pressed("Right"):
			_resume.grab_focus()
			_focused = true

func _pause() -> void:
	get_tree().paused = true
	_menu.visible = true
	_animation_player.play("fade")
	
func _unpause() -> void:
	get_tree().paused = false
	_animation_player.play_backwards("fade")
	yield(_animation_player, "animation_finished")
	_menu.visible = false
	_focused = false

func _is_UpDownLeftRight(event: InputEvent) -> bool:
	return event.is_action_pressed("Up") or event.is_action_pressed("Down") or event.is_action_pressed("Left") or event.is_action_pressed("Right")
	

func _on_MenuButton_hovered() -> void:
	if get_tree().paused:
		_hover_over.play()


func _on_Resume_pressed() -> void:
	_next_screen.play()
	_unpause()


func _on_Restart_pressed() -> void:
	_level_select.play()
	yield(_level_select, "finished")
	_menu.visible = false	
	_focused = false
	get_tree().paused = false
	get_tree().reload_current_scene()
	


func _on_Exit_pressed() -> void:
	_next_screen.play()
	yield(_next_screen, "finished")
	_menu.visible = false	
	_focused = false
	_transition_rect.transition_to("res://Scenes/Start Screen/Main Screen/StartScreen.tscn")
	get_tree().paused = false
