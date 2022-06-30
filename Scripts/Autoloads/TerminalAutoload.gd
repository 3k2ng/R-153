extends Node

signal hack
signal exit_hacking

signal print_console
signal clear_console
signal explode
signal die

enum AccessState {
	NONE,
	PASSWORD,
	ROOT,
	USER
}

onready var access = AccessState.NONE

var root_system: FileSystem

var remote_system: FileSystem
var current_user: User
var current_directory: String

func parse_input(input_text):
	if access == AccessState.PASSWORD:
		if current_user.user_password == input_text:
			access = AccessState.USER
			setup_system()
		else:
			access = AccessState.ROOT
			setup_system()
			print_console("cannot connect to system: system not available")
			remote_system = null
	elif access != AccessState.NONE:
		print_console("> %s" % input_text)
		var phrases = Array(input_text.split(" "))
		while "" in phrases:
			phrases.erase("")
		execute_input(phrases)

func print_console(output_text):
	emit_signal("print_console", output_text)

func clear_console():
	emit_signal("clear_console")

func explode(target_system):
	emit_signal("explode", target_system)

func transform_directory(original_dir):
	if original_dir[-1] == "~":
		return "~"
	var path = original_dir.split("/")
	var ret = []
	for stuff in path:
		if stuff == "..":
			ret.pop_back()
		elif stuff != ".":
			ret.append(stuff)
	return PoolStringArray(ret).join("/")

func execute_input(input_phrases):
	if len(input_phrases) == 0:
		print_console("")
		prompt()
		return
	var command = input_phrases.pop_front().to_upper()
	var args = input_phrases

	match command:
		"HELP":
			command_help(args)
		"LS":
			command_ls()
		"CD":
			command_cd(args)
		"CAT":
			command_cat(args)
		"SSH":
			command_ssh(args)
		"SSH-LS":
			command_sshls()
		"LOGOUT":
			command_logout()
		"EXPL":
			command_expl()
		"WHO":
			command_who()
		"CLEAR":
			clear_console()
		"EXIT":
			clear_console()
			exit_hacking()
		_:
			print_console("unknown command: there's no command called %s, type HELP for list of all commands" % command)
	if access != AccessState.PASSWORD:
		prompt()

func command_help(args):
	var commands = ["HELP", "LS", "CD", "CAT", "SSH","SSH-LS", "WHO", "CLEAR", "EXPL", "LOGOUT", "EXIT"]
	if len(args) == 0:
		describe_command("HELP")
		print_console("available commands")
		print_console(PoolStringArray(commands).join(", "))
	else:
		describe_command(args.pop_front().to_upper())

func command_ls():
	var current_system = root_system if access == 2 else remote_system
	for file in current_system.get_files(current_directory):
		print_console("[%s, %s, %s] %s" % [file.file_owner, "dir" if file.is_directory else "tex", "private" if file.is_private else "public", file.file_name])

func command_cd(args):
	if len(args) == 0:
		command_cd(["~"])
	else:
		var current_system = root_system if access == 2 else remote_system
		var dir = transform_directory(current_directory + "/" + args[0])
		var accessed_file = current_system.get_file(dir)
		if accessed_file:
			if accessed_file.is_directory and file_accessible(accessed_file):
				current_directory = accessed_file.location + "/" + accessed_file.file_name
				print_console("changed directory to: %s" % current_directory)
			elif accessed_file.is_directory:
				print_console("cannot change to target directory: access not available")
			else:
				print_console("cannot change to target directory: file is not directory")
		elif dir == "~":
			current_directory = "~"
			print_console("changed directory to: %s" % current_directory)
		else:
			print_console("cannot change to target directory: file is not available")

func command_cat(args):
	if len(args) == 0:
		describe_command("CAT")
	else:
		var current_system = root_system if access == 2 else remote_system
		var dir = transform_directory(current_directory + "/" + args[0])
		var accessed_file = current_system.get_file(dir)
		if accessed_file:
			if accessed_file.is_directory and file_accessible(accessed_file):
				print_console(accessed_file.location + "/" + accessed_file.file_name)
			elif file_accessible(accessed_file):
				print_console(accessed_file.content)
			else:
				print_debug(file_accessible(accessed_file))
				print_console("cannot get file content: access not available")
		elif dir == "~":
			print_console("~")
		else:
			print_console("cannot get file content: file is not available")

func command_ssh(args):
	if len(args) == 0:
		describe_command("SSH")
	else:
		var addresses = args[0].split("@") # input: user_name@system_name
		if len(addresses) < 2:
			print_console("cannot connect to system: unknown address, please use <user_name@system_name>")
			return
		current_user = NetworkManager.get_user(addresses[0])
		remote_system = NetworkManager.get_system(addresses[1])
		if remote_system and current_user:
			if current_user.user_password != "":
				access = AccessState.PASSWORD
				print_console("please enter password for %s" % current_user.user_name)
			else:
				access = AccessState.USER
				setup_system()
		elif current_user:
			print_console("cannot connect to system: system not available")
		else:
			print_console("cannot connect to system: user not available")

func command_sshls():
	var current_system = root_system if access == 2 else remote_system
	var current_network = NetworkManager.list_ssh(current_system.system_name)
	print_console("available systems in the current network:")
	for system_name in current_network:
		print_console(system_name)

func command_expl():
	var current_system = root_system if access == 2 else remote_system
	if can_explode():
		explode(current_system.system_name)
		command_logout()
	else:
		print_console("cannot explode the system: this user is not the system owner")

func command_logout():
	if access == AccessState.ROOT:
		clear_console()
		exit_hacking()
	else:
		access = AccessState.ROOT
		setup_system()

func command_who():
	print_console("you're currently %s" % get_user_info())

func hack_system(system_name):
	var target_system = NetworkManager.get_system(system_name)
	if target_system:
		access = AccessState.ROOT
		root_system = target_system
		setup_system()
		emit_signal("hack")
		return true
	return false

func setup_system():
	clear_console()
	current_directory = "~"
	prompt()

func get_user_info():
	if access == AccessState.ROOT:
		return "root@%s" % root_system.system_name
	return "%s@%s" % [current_user.user_name, remote_system.system_name]

func exit_hacking():
	emit_signal("exit_hacking")
	yield(get_tree().create_timer(1.0), "timeout")
	remote_system = null

func file_accessible(target_file):
	if access == AccessState.ROOT:
		return true
	elif not target_file.is_private: 
		return true
	elif target_file.file_owner == current_user.user_name:
		return true
	return false

func can_explode():
	if access == AccessState.ROOT:
		return true
	elif access == AccessState.USER and remote_system.is_owner(current_user.user_name):
		return true
	return false

func describe_command(command):
	match command:
		"HELP":
			print_console("HELP <command>: get command syntax")
		"LS":
			print_console("LS: list every files in the current directory")
		"CD":
			print_console("CD <directory>: change directory")
			print_console("CD <directory>: go back to root directory")
		"CAT":
			print_console("CAT <file>: get file content")
		"SSH":
			print_console("SSH <user>@<system>: gain user access to a system")
		"SSH-LS":
			print_console("SSH-LS: list every systems in the current")
		"WHO":
			print_console("WHO: get information about current user")
		"CLEAR":
			print_console("CLEAR: clear console")
		"EXPL":
			print_console("EXPL: explode current system")
		"LOGOUT":
			print_console("LOGOUT: return to root system")
		"EXIT":
			print_console("EXIT: turn off terminal")

func prompt():
	print_console("%s [%s]" % [get_user_info(), current_directory])
