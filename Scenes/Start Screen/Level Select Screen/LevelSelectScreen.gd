extends Control

onready var _transition_rect := $SceneTransitionRect
onready var _row1 = $Levels/row1
onready var _row2 = $Levels/row2

func _ready() -> void:
	var levels_locked_status := get_levels_locked_status()
	var levels = _row1.get_children()
	levels.append_array(_row2.get_children())
	
	print(levels_locked_status)
	var i = 0
	for level in levels:
		level.locked = not bool(levels_locked_status[i])
		i += 1
		
func get_levels_locked_status() -> PoolIntArray:
	var level_save_file := File.new()
	level_save_file.open("res://Saves/levels.SAVE", File.READ)
	var levels := level_save_file.get_csv_line()
	var levels_status : PoolIntArray
	for status in levels:
		levels_status.append(int(status))
	level_save_file.close()
	return levels_status

func _on_BackButton_pressed() -> void:
	Sounds.ui_next_screen.play()
	_transition_rect.transition()

func _on_BackButton_mouse_entered() -> void:
	Sounds.ui_hover_over.play()
