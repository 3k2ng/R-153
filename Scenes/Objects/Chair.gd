extends StaticBody2D

var player = null
var npc = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player || npc:
		self.set_collision_layer_bit(0, false)
	else:
		self.set_collision_layer_bit(0, true)
	

func _on_Area2D_body_entered(body):
	if body.get_name() == "Player":
		player = body
	else:
		npc = body


func _on_Area2D_body_exited(body):
	if body.get_name() == "Player":
		player = null
	else:
		npc = null
