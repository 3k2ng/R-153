extends Area2D

export(String) var system_name

export(bool) var destroyed = false

onready var player_access = false
onready var particle_system = $ParticleSystem
onready var terminal = $"/root/TerminalAutoload"
onready var player_hacking = false

func _ready():
	TerminalAutoload.connect("exit_hacking", self, "exit_hacking")
	terminal.connect("explode", self, "die")
	$AnimatedSprite.play("Off")

	
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

func exit_hacking():
	player_hacking = false
	if not destroyed:
		$AnimatedSprite.play("Off")

func die(target_system):
	if target_system == self.system_name:
		$AnimationPlayer.play("explode")

func _on_ExplosionRadius_body_entered(body):
	if body.has_method("set_nearby"):
		body.set_nearby(system_name)

func _on_ExplosionRadius_body_exited(body):
	if body.has_method("set_nearby"):
		body.set_nearby("")

func kill():
	TerminalAutoload.emit_signal("die", system_name)
