extends KinematicBody2D

# Determines the sprite's gravity and movement velocity
var velocity = Vector2()
# Determines the npc's starting direction
export (int) var  direction = 1
var nearby_bodies = null
var new_direction = null
var state = State.Computing
var alert = Alert.Normal
var de_agroTimer_running = false

enum Alert {
	Normal
	Question
	Caution
	Alert
}

enum State {
	Idle
	Computing
	Patrolling
	Chasing
	}

func _ready():
	if direction == 1:
		$NPCsprite.flip_h = true
		$DetectionBoxes.scale.x = $DetectionBoxes.scale.x * direction
	$AlertState.play("NotAware")

# Function that's called every frame. Basically modifies npc behavior in real time
func _physics_process(_delta):
	# Checks if the npc has hit a wall, facilitating a change in direction for movement
	chooseDirection()
	# Determines which animation should be played
	_animation()
	# Applies the horizontal movement speed in the intended direction
	_move_velocity()
	if $De_agroTimer.time_left == 0:
		alert = Alert.Caution
		print("It Worked")

func _move_velocity():
	# Constantly applies a gravity value
	velocity.y += 30
	if nearby_bodies != null:
		velocity.x = position.direction_to(nearby_bodies.position).x * 400
	# Apply the new velocity
	velocity = move_and_slide(velocity, Vector2.UP)

# Switches the direction of the NPC
func chooseDirection():
	# Switches if the NPC hits a wall
	if is_on_wall():
		# Switches the direction
		direction = direction * -1
		# Flips the sprite model
		$NPCsprite.flip_h = not $NPCsprite.flip_h
		#Flips the detection boxes
		$DetectionBoxes.scale.x = $DetectionBoxes.scale.x * -1
	if nearby_bodies != null:
		new_direction = position.direction_to(nearby_bodies.position).x
		new_direction = stepify(new_direction, 1)
		if new_direction != direction:
			direction = direction * -1
			$NPCsprite.flip_h = not $NPCsprite.flip_h
			$DetectionBoxes.scale.x = $DetectionBoxes.scale.x * -1


# Dictates which animation should be playing based on whether the state of NPC
#func animation():
#	# Animation for when the NPC is not moving
#	if velocity.x == 0:
#		# If the NPC is just hanging out
#		if state == State.Idle:
#			$NPCsprite.play("Idle")
#		#If the NPC is at a computer
#		elif state == State.Computing:
#			$NPCsprite.play("Computing")
#	# Animation for when the NPC is moving
#	elif velocity.x != 0:
#		if state == State.Patrolling:
#			$NPCsprite.play("Move")

func _animation():
	# Dictates the animation state of the NPC
	if state == State.Idle:
		$NPCsprite.play("Idling")
	elif state == State.Computing:
		$NPCsprite.play("Computing")
	elif state == State.Patrolling || state == State.Chasing:
		$NPCsprite.play("Move")
	
	# Dictates the alert level of the NPC
	if alert == Alert.Normal:
		$AlertState.play("NotAware")
	elif alert == Alert.Question:
		$AlertState.play("Question")
	elif alert == Alert.Caution:
		$AlertState.play("Caution")
	elif alert == Alert.Alert:
		$AlertState.play("Alert")

func _recognizing_player():
	$SpottedTimer.start()
	if nearby_bodies != null:
		state = Alert.Alert
	
# Detects if the player enters the NPCs field of sight
func _on_DetectionBoxes_body_entered(body):
	nearby_bodies = body
	state = Alert.Question
	print("Found: ", nearby_bodies)

# Detects if the player leaves the NPCs field of sight
func _on_DetectionBoxes_body_exited(body):
	nearby_bodies = null
	$De_agroTimer.start()
#	$De_agroTimer.stop()
	print("Exited: ", nearby_bodies)
