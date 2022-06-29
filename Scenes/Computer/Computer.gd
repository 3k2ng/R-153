extends Area2D

export(String) var system_name

export(bool) var destroyed = false

onready var player_access = false
onready var particle_system = $ParticleSystem
onready var terminal = $"/root/TerminalAutoload"
onready var player_hacking = false
var nearby_bodies = null
var not_connected = Color(256,0,0)
var connected = Color(0,0,256)
var origin
var new
var from = Vector2()
var to = Vector2()
var computers


func _ready():
	TerminalAutoload.connect("exit_hacking", self, "exit_hacking")
	terminal.connect("explode", self, "die")
	NetworkManager.computers.append(self)
	computers = NetworkManager.computers
	$AnimatedSprite.play("Off")

func _physics_process(_delta):
	#print(terminal.root_system)
	if terminal.root_system != self:
		update()


func _on_Computer_body_entered(body):
	if body.is_in_group("player"):
		player_access = true

func _on_Computer_body_exited(body):
	if body.is_in_group("player"):
		player_access = false

func _input(event):
	if event.is_action_released("Hack") and player_access and not player_hacking:
		if not destroyed:
			var hacking = TerminalAutoload.hack_system(system_name)
			if hacking:
				player_hacking = true
				$AnimatedSprite.play("On")
				update()

func _draw():
	if player_hacking:
		origin = to_local(self.global_position)
		from = Vector2(origin.x, origin.y)
		computers = NetworkManager.list_ssh(system_name)
		for computer in computers:
			if computer != self.system_name:
				new = to_local(NetworkManager.get_computer(computer).position)
				to = Vector2(new.x, new.y)
				if terminal.root_system != NetworkManager.get_computer(computer):
					draw_line(from, to, not_connected)
				else:
					draw_line(from, to, connected)
	else:
		draw_line(Vector2(), Vector2(), Color(0,0,0))

func exit_hacking():
	player_hacking = false
	if not destroyed:
		$AnimatedSprite.play("Off")
	update()

func die(target_system):
	if target_system == self.system_name:
		$AnimationPlayer.play("explode")
		computers.erase(self)
		if TerminalAutoload.root_system.system_name == target_system:
			TerminalAutoload.exit_hacking()

func _on_ExplosionRadius_body_entered(body):
	if body.has_method("set_nearby"):
		body.set_nearby(system_name)

func _on_ExplosionRadius_body_exited(body):
	if body.has_method("set_nearby"):
		body.set_nearby("")

func kill():
	TerminalAutoload.emit_signal("die", system_name)
