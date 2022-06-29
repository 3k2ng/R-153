extends Node

onready var all_dead = false

signal all_human_dead

func _process(delta):
	if not all_dead:
		var alive = 0
		for npc in get_tree().get_nodes_in_group("human"):
			if not npc.dead:
				alive += 1
		if alive == 0:
			emit_signal("all_human_dead")
			all_dead = true
