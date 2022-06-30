extends CanvasLayer

export (NodePath) var transition_rect_path

onready var _transition_rect : SceneTransitionRect = get_node(transition_rect_path)
onready var _animation_player = $AnimationPlayer
onready var _display = $Display

onready var _hover_over = $Sounds/hover_over
onready var _next_screen = $Sounds/next_screen
onready var _level_select = $Sounds/level_select
onready var _game_over = $Sounds/game_over

var _shown = false

func _ready() -> void:
	_display.visible = false
	layer = 102
	add_to_group("game_end_screens")

func _on_MenuButton_hovered() -> void:
	if _shown:
		_hover_over.play()

func show() -> void:
	_shown = true
	_display.visible = true
	_animation_player.play("fade")
	_game_over.play()	


func _on_Restart_pressed() -> void:
	_level_select.play()
	yield(_level_select, "finished")
	get_tree().reload_current_scene()


func _on_Exit_pressed() -> void:
	_next_screen.play()
	yield(_next_screen, "finished")
	_transition_rect.transition_to("res://Scenes/Start Screen/Main Screen/StartScreen.tscn")
