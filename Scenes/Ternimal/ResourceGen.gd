extends Node


export(String, FILE, "*.json") var data_path

export(PackedScene) var system_prefab

func _process(_delta):
	var data_file = File.new()
	if data_file.open(data_path, File.READ) != OK:
		return
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.parse(data_text)
	if data_parse.error != OK:
		return
	var data = data_parse.result

	var users = []
	for user in data.users:
		var new_user = User.new()
		new_user.user_name = user.name
		new_user.user_password = user.password
		users.append(new_user)

	for system in data.systems:
		var new_system = system_prefab.instance()
		new_system.system_name = system.name
		new_system.system_owner = system.owner
		var files = []
		for file_data in system.files:
			var new_file = CustomFile.new()
			new_file.file_name = file_data.name
			new_file.file_owner = file_data.owner
			new_file.is_private = file_data.private
			new_file.is_directory = file_data.directory
			new_file.location = file_data.location
			if not file_data.directory:
				new_file.content = file_data.content
			files.append(new_file)
		get_parent().add_child(new_system)
		new_system.files = files
	
	var networks = []
	for network in data.networks:
		var new_network = []
		for system in network.systems:
			new_network.append(system)
		networks.append(new_network)
	NetworkManager.networks = networks
	NetworkManager.users = users
	queue_free()

