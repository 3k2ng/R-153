extends KinematicBody2D

var body_detected = []
export var access_level = clamp(0, 0, 3)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
func _on_Area2D_body_entered(body):
	body_detected = body
	if body.name == "NPC":
		print("NPC detected: ", body_detected)
	elif body.name == "Player":
		print("Player detected: ", body_detected)

func _on_Area2D_body_exited(body):
	if body.name == "NPC":
		print("NPC exited: ", body_detected)
	elif body.name == "Player":
		print("Player exited: ", body_detected)
