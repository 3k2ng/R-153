extends Control

onready var _transition_rect := $SceneTransitionRect

func _on_BackButton_pressed() -> void:
	Sounds.ui_next_screen.play()
	_transition_rect.transition()

func _on_BackButton_mouse_entered() -> void:
	Sounds.ui_hover_over.play()
