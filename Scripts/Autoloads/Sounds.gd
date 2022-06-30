extends Node

onready var player_jump := $Player/jump

onready var terminal_keyboard_button := $Terminal/keyboard_button
onready var terminal_keyboard_button_enter := $Terminal/keyboard_button_enter

onready var ui_error := $UI/error
onready var ui_game_over := $UI/game_over
onready var ui_hover_over := $UI/hover_over
onready var ui_level_select := $UI/level_select
onready var ui_next_screen := $UI/next_screen

onready var npc_explode := $Explosions/npc_explode
onready var computer_explode := $Explosions/computer_explode

func get_all_sounds() -> Array:
	return get_tree().get_nodes_in_group("sounds")


