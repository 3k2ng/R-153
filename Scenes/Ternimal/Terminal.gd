extends CanvasLayer

const MAX_LINES = 10

onready var hacking = false

onready var input = $"Input"
onready var output = $"Output"

onready var output_queue = []

func _ready():
	pass

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
	output_queue.append(output_text)
	if len(output_queue) > MAX_LINES:
		output_queue.pop_front()
	output.text = PoolStringArray(output_queue).join("\n")

func execute_input(input_phrases):
	var command = input_phrases.pop_front()
	var args = input_phrases
	match (command):
		"HELP":
			print_output("help")
		_:
			print_output("unknown command")
