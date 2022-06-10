extends CanvasLayer

enum TerminalState {
	DISABLED,
	HACK,
	SSH,
	PASSWORD,
	ENABLED
}

const MAX_LINES = 10
const MAX_CHARS = 93

var current_system: FileSystem
var current_user: User
var current_directory: String

var target_system: FileSystem
var target_user: User

onready var input = $"Input"
onready var output = $"Output"

onready var output_queue = []

onready var current_state = TerminalState.DISABLED

onready var password_tries = 0

func _ready():
	hack_system($"../FileSystem")

func _on_text_input(input_text):
	input.text = ""
	match current_state:
		TerminalState.PASSWORD:
			if input_text == target_user.user_password:
				current_user = target_user
				set_system(target_system)
				current_state = TerminalState.ENABLED
			elif password_tries > 0:
				print_output("wrong password, you have %d tries left" % password_tries)
				password_tries -= 1
			else:
				clear_output()
				current_state = TerminalState.ENABLED
				print_output("fail to access user")
		TerminalState.SSH:
			var selection = input_text.to_int()
			if selection >= 0 and selection < len(target_system.users):
				target_user = target_system.users[selection]
				current_state = TerminalState.PASSWORD
				password_tries = 3
				clear_output()
				print_output("please enter the password for %s" % target_user.user_name)
		TerminalState.HACK:
			var selection = input_text.to_int()
			if selection >= 0 and selection < len(target_system.users):
				current_user = target_system.users[selection]
				set_system(target_system)
				current_state = TerminalState.ENABLED
		TerminalState.ENABLED:
			print_output(current_directory + "> " + input_text)
			var phrases = Array(input_text.split(" "))
			while "" in phrases:
				phrases.erase("")
			execute_input(phrases)

func print_output(output_text):
	output_text = output_text
	while len(output_text) > MAX_CHARS:
		output_queue.append(output_text.substr(0, MAX_CHARS))
		if len(output_queue) > MAX_LINES:
			output_queue.pop_front()
		output_text = output_text.substr(MAX_CHARS).trim_prefix(" ")
	output_queue.append(output_text)
	if len(output_queue) > MAX_LINES:
		output_queue.pop_front()
	output.text = PoolStringArray(output_queue).join("\n")

func clear_output():
	output.text = ""
	output_queue = []

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
			print_output("help") # todo: print every command and specify the use of one when mentioned
		"LS":
			for file in current_system.get_files(current_directory):
				print_output("[%s, %s, %s] %s" % [file.file_owner.user_name, "dir" if file.file_type == 0 else ("tex" if file.file_type == 1 else "exe"), "private" if file.is_private else "public", file.file_name])
		"CD":
			if len(args) == 0:
				print_output("cd")
			else:
				var dir = transform_directory(current_directory + "/" + args[0])
				var accessed_file = current_system.get_file(dir)
				if accessed_file != null:
					if accessed_file.file_type == 0:
						current_directory = accessed_file.location + "/" + accessed_file.file_name
				elif dir == "~":
					current_directory = "~"
				else:
					print_output(">:(")
		"SSH-LS":
			if len(args) == 0:
				for sys in get_tree().get_nodes_in_group("network_manager")[0].list_ssh(current_system.system_name):
					print_output(sys)
			else:
				for user in get_tree().get_nodes_in_group("network_manager")[0].list_user(args[0]):
					print_output(user)
		"SSH":
			if len(args) == 0:
				pass
			else:
				clear_output()
				ssh_system(get_tree().get_nodes_in_group("network_manager")[0].get_system(args[0]))
		"EXPL":
			print_output("expl")
		"CAT":
			if len(args) == 0:
				print_output("cat")
			else:
				var dir = transform_directory(current_directory + "/" + args[0])
				var accessed_file = current_system.get_file(dir)
				if accessed_file != null:
					if accessed_file.file_type == 0:
						print_output(accessed_file.location + "/" + accessed_file.file_name)
					else:
						print_output(accessed_file.content)
				elif dir == "~":
					print_output("~")
				else:
					print_output(">:(")
		"WHO":
			print_output("%s: %s" % [current_system.system_name, current_user.user_name])
		"CLR":
			clear_output()
		"EXIT":
			clear_output()
			input.release_focus()
		_:
			print_output("unknown command: there's no command called %s, type HELP for list of all commands" % command)

func ssh_system(sys):
	print_output("successfully connected to the system, please log in to an user:")
	for i in len(sys.users):
		print_output("%d: %s" % [i, sys.users[i].user_name])
	target_system = sys
	current_state = TerminalState.SSH

func hack_system(sys):
	input.grab_focus()
	print_output("successfully gain access to the system, please choose an user:")
	for i in len(sys.users):
		print_output("%d: %s" % [i, sys.users[i].user_name])
	target_system = sys
	current_state = TerminalState.HACK

func set_system(sys):
	current_system = sys
	current_directory = "~"
	clear_output()
	print_output("you are now %s: %s" % [current_system.system_name, current_user.user_name])
