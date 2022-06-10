extends Node

export(Array, Array, String) var networks

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

func list_user(system_name):
	var system = get_system(system_name)
	var users = []
	for user in system.users:
		users.append(user.user_name)
	return users
