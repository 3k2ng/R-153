extends CanvasLayer

const MAX_LINES = 9
const MAX_CHARS = 90

onready var animation_player = $"AnimationPlayer"

onready var input = $"TerminalUI/Input"
onready var output = $"TerminalUI/Output"

onready var output_queue = []

func _ready():
	TerminalAutoload.connect("print_console", self, "print_output")
	TerminalAutoload.connect("clear_console", self, "clear_output")
	TerminalAutoload.connect("hack", self, "enter_hacking")
	TerminalAutoload.connect("exit_hacking", self, "exit_hacking")

func _on_text_input(input_text):
	input.text = ""
	TerminalAutoload.parse_input(input_text)

func print_output(output_text):
	output_text = output_text
	while len(output_text) > MAX_CHARS:
		var current_line = output_text.substr(0, MAX_CHARS)
		var last_space = current_line.find_last(" ")
		output_text = output_text.substr(last_space).trim_prefix(" ")
		current_line = current_line.substr(0, last_space)
		output_queue.append(current_line)
		if len(output_queue) > MAX_LINES:
			output_queue.pop_front()
	output_queue.append(output_text)
	if len(output_queue) > MAX_LINES:
		output_queue.pop_front()
	output.text = PoolStringArray(output_queue).join("\n")

func clear_output():
	output.text = ""
	output_queue = []

func enter_hacking():
	input.grab_focus()
	animation_player.play("enable")

func exit_hacking():
	input.release_focus()
	animation_player.play("disable")
