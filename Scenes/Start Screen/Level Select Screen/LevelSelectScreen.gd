extends Control

onready var _transition_rect := $SceneTransitionRect

onready var _next_screen = $Sounds/next_screen
onready var _hover_over = $Sounds/hover_over

func _on_BackButton_pressed() -> void:
	_transition_rect.transition()
	_next_screen.play()

func _on_BackButton_mouse_entered() -> void:
	_hover_over.play()
