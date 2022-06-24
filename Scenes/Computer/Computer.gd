extends Area2D

export(String) var system_name

onready var player_access = false

onready var player_hacking = false

func _ready():
	TerminalAutoload.connect("exit_hacking", self, "exit_hacking")

func _on_Computer_body_entered(body):
	if body.is_in_group("player"):
		player_access = true

func _on_Computer_body_exited(body):
	if body.is_in_group("player"):
		player_access = false

func _input(event):
	if event.is_action_released("Hack") and player_access and not player_hacking:
		var file_system = get_tree().get_nodes_in_group("network_manager")[0].get_system(system_name)
		if file_system:
			get_tree().get_nodes_in_group("terminal")[0].hack_system(file_system)
			player_hacking = true

func exit_hacking():
	player_hacking = false
