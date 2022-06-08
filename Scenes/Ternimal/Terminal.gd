extends CanvasLayer

const MAX_LINES = 10
const MAX_CHARS = 93

var current_system: FileSystem
var current_directory: String

onready var hacking = false

onready var input = $"Input"
onready var output = $"Output"

onready var output_queue = []

func _ready():
	set_system($"../FileSystem")

func _input(event):
	if event.is_action_released("Hack"):
		input.grab_focus()

func _on_text_input(input_text):
	input.text = ""
	var phrases = Array(input_text.to_upper().split(" "))
	while ("" in phrases):
		phrases.erase("")
	execute_input(phrases)

func print_output(output_text):
	output_text = output_text
	while (len(output_text) > MAX_CHARS):
		output_queue.append(output_text.substr(0, MAX_CHARS))
		if len(output_queue) > MAX_LINES:
			output_queue.pop_front()
		output_text = output_text.substr(MAX_CHARS).trim_prefix(" ")
	output_queue.append(output_text)
	if len(output_queue) > MAX_LINES:
		output_queue.pop_front()
	output.text = PoolStringArray(output_queue).join("\n")

func print_file(dir):
	var file = current_system.get_file(dir)
	if (file.file_type == 0):
		print_output(file.location + "/" + file.file_name)
	else:
		print_output(file.content)

func execute_input(input_phrases):
	var command = input_phrases.pop_front()
	var args = input_phrases
	match (command):
		"HELP":
			print_output("help")
		"CD":
			print_output("cd")
		"CAT":
			print_file(current_directory + "/" + args[0])
		"EXIT":
			output.text = ""
			input.release_focus()
		_:
			print_output("unknown command: there's no command called %s, type HELP for list of all commands" % command)

func set_system(sys):
	current_system = sys
	current_directory = "~"
