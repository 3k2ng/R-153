extends Control

onready var transition_rect := $SceneTransitionRect

func _ready() -> void:
	pass


func _on_Button_pressed() -> void:
	transition_rect.transition()
