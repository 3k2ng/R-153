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

# Runs before the program starts
func _ready():
	# Checks if the sprite needs to be flipped
	if direction == 1:
		$NPCsprite.flip_h = true
	# Positions the edge detection according to the starting direction
	$DetectionLines/FloorLine.position.x = ($NPCcollisionBox.shape.get_extents().x / 5)
	# Shifts the detection nodes according to the starting direction
	$DetectionLines.scale.x = $DetectionLines.scale.x * direction


# Function that's called every frame. Basically modifies npc behavior in real time
func _physics_process(_delta):
	_change_state()
	# Checks if the npc has hit a wall, facilitating a change in direction for movement
	chooseDirection()
	# Determines which animation should be played
	_animation()
	# Applies the horizontal movement speed in the intended direction
	_move_velocity()
	if state == State.Patrolling:
		print($De_agroTimer.time_left)
	if $De_agroTimer.time_left < 0.2:
		$De_agroTimer.stop()


func _change_state():
	if state != State.Chasing:
		if $DetectionLines/DetectionLine.is_colliding() && $DetectionLines/DetectionLine.get_collider().get_name() == "Player":
			alert = Alert.Question
			yield(get_tree().create_timer(1.0), "timeout")
			alert = Alert.Alert
			state = State.Chasing
	if state == State.Patrolling && $De_agroTimer.is_stopped():
		alert = Alert.Normal
		############ HOW TO INTERACT WITH COMPUTER NOW THAT IT IS AN AREA2D?#########


# Switches the direction of the NPC
func chooseDirection():
	# Determines direction when the NPC is actively patrolling
	if state == State.Patrolling:
		# Changes the direction when the NPC either hits a wall or approaches an edge
		if is_on_wall() || not $DetectionLines/FloorLine.is_colliding():
			_switch_directions()


	# Determines direction when the NPC is chasing the player
	if state == State.Chasing:
		# If the player is within detection range, sets direction towards the player
		if $DetectionLines/DetectionLine.is_colliding() && $DetectionLines/DetectionLine.get_collider().get_name() == "Player":
			direction = stepify(position.direction_to($DetectionLines/DetectionLine.get_collider().position).x, 1)
		# If the NPC hits wall or ledge when chasing the player, just stops
		elif is_on_wall() || not $DetectionLines/FloorLine.is_colliding():
			$NPCsprite.play("Idle")
		# If the NPC is still on alert but player leaves detection
		elif alert != Alert.Caution:
			# Waits 2 seconds before NPC becomes confused
			yield(get_tree().create_timer(2.0), "timeout")
			# NPC has lost the player, becomes confused
			alert = Alert.Question
			# Another wait
			yield(get_tree().create_timer(1.0), "timeout")
			# Goes on caution
			alert = Alert.Caution
			# Goes on Patrolling state
			state = State.Patrolling
			# Countdown timer begins. Returns to normal once timer ends.
			$De_agroTimer.start()


# Apply movement to the NPC
func _move_velocity():
	# Constantly applies a gravity value
	velocity.y += 30
	# If the NPC is in a moving state
	if state == State.Patrolling || state == State.Chasing:
		velocity.x = direction * 400
	# If the NPC is in a stationary state
	if state == State.Idle || state == State.Computing:
		velocity.x = 0
	# Apply the new velocity
	velocity = move_and_slide(velocity, Vector2.UP)


# Play animations depending on the state and alertness of NPC
func _animation():
	# Plays if the NPC is just hanging out
	if state == State.Idle:
		$NPCsprite.play("Idling")
	# Plays when the NPC is using a computer
	elif state == State.Computing:
		$NPCsprite.play("Computing")
	# Plays when the NPC is moving
	elif state == State.Patrolling || state == State.Chasing && !is_on_wall():
		$NPCsprite.play("Move")
	
	# Normal phase
	if alert == Alert.Normal:
		$AlertState.play("NotAware")
	# Sees something or is confused
	elif alert == Alert.Question:
		$AlertState.play("Question")
	# Is on high alert for player
	elif alert == Alert.Caution:
		$AlertState.play("Caution")
	# OMG there's a robot
	elif alert == Alert.Alert:
		$AlertState.play("Alert")


# Switches the direction of the NPC
func _switch_directions():
	# Switches the direction
	direction = direction * -1
	# Flips the sprite model
	$NPCsprite.flip_h = not $NPCsprite.flip_h
	# Flips the detection boxes
	$DetectionLines.scale.x = $DetectionLines.scale.x * -1


# Detects if the player enters the NPCs field of sight
#func _on_DetectionBoxes_body_entered(body):
#	nearby_bodies = body
#	state = Alert.Question
#	print("Found: ", nearby_bodies)


# Detects if the player leaves the NPCs field of sight
#func _on_DetectionBoxes_body_exited(body):
#	nearby_bodies = null
#	$De_agroTimer.start()
#	$De_agroTimer.stop()
#	print("Exited: ", nearby_bodies)
