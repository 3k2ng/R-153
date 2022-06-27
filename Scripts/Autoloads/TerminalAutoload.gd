extends Node

signal hack
signal exit_hacking

signal print_console
signal clear_console
signal explode

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
	elif access != AccessState.NONE:
		print_console(current_directory + "> " + input_text)
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
	var path = original_dir.split("/")
	var ret = []
	for stuff in path:
		if stuff == "..":
			ret.pop_back()
		elif stuff != ".":
			ret.append(stuff)
	return PoolStringArray(ret).join("/")

func execute_input(input_phrases):
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
		"WHO":
			command_who()
		"CLR":
			clear_console()
		"EXIT":
			clear_console()
			exit_hacking()
		_:
			print_console("unknown command: there's no command called %s, type HELP for list of all commands" % command)

func command_help(args):
	if len(args) == 0:
		print_console("available commands")

func command_ls():
	var current_system = root_system if access == 2 else remote_system
	for file in current_system.get_files(current_directory):
		print_console("[%s, %s, %s] %s" % [file.file_owner, "dir" if file.is_directory else "tex", "private" if file.is_private else "public", file.file_name])

func command_cd(args):
	if len(args) == 0:
		print_console("cd")
	else:
		var current_system = root_system if access == 2 else remote_system
		var dir = transform_directory(current_directory + "/" + args[0])
		var accessed_file = current_system.get_file(dir)
		if accessed_file:
			if accessed_file.is_directory and file_accessible(accessed_file):
				current_directory = accessed_file.location + "/" + accessed_file.file_name
		elif dir == "~":
			current_directory = "~"
		else:
			print_console(">:(")

func command_cat(args):
	if len(args) == 0:
		print_console("cat")
	else:
		var current_system = root_system if access == 2 else remote_system
		var dir = transform_directory(current_directory + "/" + args[0])
		var accessed_file = current_system.get_file(dir)
		if accessed_file:
			if accessed_file.is_directory:
				print_console(accessed_file.location + "/" + accessed_file.file_name)
			elif file_accessible(accessed_file):
				print_console(accessed_file.content)
		elif dir == "~":
			print_console("~")
		else:
			print_console(">:(")

func command_ssh(args):
	if len(args) == 0:
		print_console("ssh")
	else:
		var addresses = args[0].split("@") # input: user_name@system_name
		current_user = NetworkManager.get_user(addresses[0])
		remote_system = NetworkManager.get_system(addresses[1])
		if remote_system and current_user:
			if current_user.user_password != "":
				access = AccessState.PASSWORD
				print_console("please enter password for %s" % current_user.user_name)
			else:
				access = AccessState.USER
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
	command_who()

func get_user_info():
	if access == AccessState.ROOT:
		return "root@%s" % root_system.system_name
	return "%s@%s" % [current_user.user_name, remote_system.system_name]

func exit_hacking():
	emit_signal("exit_hacking")

func file_accessible(target_file):
	if access == AccessState.ROOT:
		return true
	elif access == AccessState.USER and target_file.file_owner == current_user.user_name:
		return true
	return false
