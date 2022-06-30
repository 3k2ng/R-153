extends CanvasLayer

export (NodePath) var transition_rect_path

onready var _transition_rect : SceneTransitionRect = get_node(transition_rect_path)
onready var _animation_player = $AnimationPlayer
onready var _display = $Display
onready var _body_check = $"/root/BodyCheck"

onready var _hover_over = $Sounds/hover_over
onready var _next_screen = $Sounds/next_screen

var _shown := false

func _ready() -> void:
	_body_check.connect("all_human_dead", self, "show")	
	layer = 100
#	add_to_group("game_end_screens")
#	yield(get_tree().create_timer(2), "timeout")
#	show()

func show() -> void:
	_shown = true
	_animation_player.play("fade")
	yield(_animation_player, "animation_finished")
	_display.visible = true
	

func _on_Exit_hovered() -> void:
	_hover_over.play()
	
func _on_Exit_pressed() -> void:
	_next_screen.play()
	_transition_rect.transition_to("res://Scenes/Start Screen/Level Select Screen/LevelSelectScreen.tscn")
