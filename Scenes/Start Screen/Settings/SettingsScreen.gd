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
	


func _on_Erase_Saved_Data_pressed() -> void:
	var save_file := File.new()
	save_file.open("user://levels.txt", File.WRITE)
	save_file.store_string("1, 0, 0, 0, 0")
	save_file.close()
	Sounds.ui_level_select.play()
