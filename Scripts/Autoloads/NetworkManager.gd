extends Node

export(Array, Array, String) var networks
export(Array, Resource) var users
var computers = []

func list_ssh(system_name):
	var systems = []
	for network in networks:
		if system_name in network:
			for system in network:
				if not system in systems and system != system_name:
					systems.append(system)
	return systems

func get_system(system_name):
	for system in get_tree().get_nodes_in_group("file_system"):
		if system.system_name == system_name:
			return system

func get_computer(system_name):
	for computer in get_tree().get_nodes_in_group("computer"):
		if computer.system_name == system_name:
			return computer

func get_user(user_name):
	for user in users:
		if user.user_name == user_name:
			return user
