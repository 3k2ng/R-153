extends CanvasLayer

export (NodePath) var transition_rect_path

onready var _transition_rect : SceneTransitionRect = get_node(transition_rect_path)
onready var _animation_player = $AnimationPlayer
onready var _display = $Display

onready var _hover_over = $Sounds/hover_over
onready var _next_screen = $Sounds/next_screen

var _shown := false

func _ready() -> void:
	layer = 100
	add_to_group("game_end_screens")
	yield(get_tree().create_timer(2), "timeout")
	show()

func show() -> void:
	_shown = true
	_display.visible = true
	_animation_player.play("fade")	


func _on_Exit_hovered() -> void:
	_hover_over.play()
	
func _on_Exit_pressed() -> void:
	_transition_rect.transition_to("res://Scenes/Start Screen/Level Select Screen/LevelSelectScreen.tscn")
