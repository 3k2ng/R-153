extends Area2D

export(String) var system_name
signal die
onready var player_access = false
onready var particle_system = $ParticleSystem
onready var terminal = $"/root/TerminalAutoload"
onready var player_hacking = false
var nearby_bodies = null
var color = Color(256,0,0)
var origin_x = 0
var origin_y = 0
var new_x = 0
var new_y = 0
var from = 0
var to = 0
var computers = []

func _ready():
	TerminalAutoload.connect("exit_hacking", self, "exit_hacking")
	terminal.connect("explode", self, "die")
	NetworkManager.computers.append(self)
	computers = NetworkManager.computers
	origin_x = self.position.x
	origin_y = self.position.y

	
func _on_Computer_body_entered(body):
	if body.is_in_group("player"):
		player_access = true
		_draw_line()

func _on_Computer_body_exited(body):
	if body.is_in_group("player"):
		player_access = false

func _input(event):
	if event.is_action_released("Hack") and player_access and not player_hacking:
		var hacking = TerminalAutoload.hack_system(system_name)
		if hacking:
			player_hacking = true

func exit_hacking():
	player_hacking = false


func die(target_system):
	if target_system == self.system_name:
		TerminalAutoload.emit_signal("die", system_name)
		particle_system.emitting = true
		$AnimationPlayer.play("fade_out")
		yield(get_tree().create_timer(1.5), "timeout")
		queue_free()



func _draw_line():
	for computer in computers:
		if computer != self:
			print("Self: ", self, "\tComputer: ", computer)
			new_x = computer.position.x
			new_y = computer.position.y
			from = Vector2(origin_x, origin_y)
			to = Vector2(new_x, new_y)
			update()

func _on_ExplosionRadius_body_entered(body):
	if body.has_method("set_nearby"):
		body.set_nearby(system_name)

func _on_ExplosionRadius_body_exited(body):
	if body.has_method("set_nearby"):
		body.set_nearby("")
