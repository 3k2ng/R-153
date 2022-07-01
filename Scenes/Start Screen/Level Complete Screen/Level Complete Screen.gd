extends CanvasLayer

export (NodePath) var transition_rect_path
export (int) var level

onready var _transition_rect : SceneTransitionRect = get_node(transition_rect_path)
onready var _animation_player = $AnimationPlayer
onready var _display = $Display
onready var _body_check = $"/root/BodyCheck"

var _shown := false

func _ready() -> void:
	layer = 100	
	_body_check.connect("all_human_dead", self, "show")	
#	add_to_group("game_end_screens")
#	yield(get_tree().create_timer(2), "timeout")
#	show()


func show() -> void:
	if level < 4:
		unlock_next_level()
	_shown = true
	_animation_player.play("fade")
	yield(_animation_player, "animation_finished")
	_display.visible = true
	Sounds.ui_level_complete.play()
	
func unlock_next_level() -> void:
	var levels_save_file := File.new()
	levels_save_file.open("res://Saves/levels.SAVE", File.READ_WRITE)
	var content := levels_save_file.get_csv_line()
	var levels_status: PoolIntArray
	for status in content:
		levels_status.append(int(status))
	levels_status[1] = 1
	levels_save_file.close()
	
	var save_file := File.new()
	save_file.open("res://Saves/levels.SAVE", File.WRITE)
#	print(str(levels_status).replace("[", "").replace("]", ""))
	save_file.store_string(str(levels_status).replace("[", "").replace("]", ""))
	save_file.close()


func _on_Exit_hovered() -> void:
	Sounds.ui_hover_over.play()
	
func _on_Exit_pressed() -> void:
	Sounds.ui_next_screen.play()
	_transition_rect.transition_to("res://Scenes/Start Screen/Level Select Screen/LevelSelectScreen.tscn")
