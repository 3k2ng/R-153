extends Control

onready var _scene_transition_rect = $SceneTransitionRect


func _ready() -> void:
	pass


func _on_Back_Button_hovered() -> void:
	Sounds.ui_hover_over.play()

func _on_Back_Button_pressed() -> void:
#	yield(_next_screen, "finished")
	Sounds.ui_next_screen.play()
	_scene_transition_rect.transition()
#	for sound in Sounds.get_all_sounds():
#		print(sound.name, ": ", sound.volume_db)
	print(Settings.sfx_percent)
	
