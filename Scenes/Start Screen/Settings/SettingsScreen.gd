extends Control

onready var _scene_transition_rect = $SceneTransitionRect
onready var _hover_over = $Sounds/hover_over
onready var _next_screen = $Sounds/next_screen


func _ready() -> void:
	pass


func _on_Back_Button_hovered() -> void:
	_hover_over.play()

func _on_Back_Button_pressed() -> void:
#	yield(_next_screen, "finished")
	_next_screen.play()
	_scene_transition_rect.transition()
	
