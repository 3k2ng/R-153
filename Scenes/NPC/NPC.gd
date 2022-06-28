extends KinematicBody2D

# Determines the sprite's gravity and movement velocity
var velocity = Vector2()
# Determines the npc's starting direction
export (int) var  direction = 1
onready var particle_system = $ParticleSystem
var nearby_bodies = null
var computers = null
var new_direction = null
var detected = null
var hit_pos = null
var detection = null
var state = State.Idle
var alert = Alert.Normal
signal kill

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
	Dead
	}

# Runs before the program starts
func _ready():
	# Positions the edge detection according to the starting direction
	$FloorLine.position.x = ($NPCcollisionBox.shape.get_extents().x / 5) * direction
	# Checks if the sprite needs to be flipped
	if direction == 1:
		$NPCsprite.flip_h = true


# Function that's called every frame. Basically modifies npc behavior in real time
func _physics_process(_delta):
	_change_state()
	# Checks if the npc has hit a wall, facilitating a change in direction for movement
	chooseDirection()
	# Determines which animation should be played
	_animation()
	# Applies the horizontal movement speed in the intended direction
	_move_velocity()
	
	if $De_agroTimer.time_left < 0.2:
		$De_agroTimer.stop()
	if nearby_bodies:
		detect()


func _change_state():
	if state != State.Chasing:
		if detected:
			alert = Alert.Question
			yield(get_tree().create_timer(1.0), "timeout")
			alert = Alert.Alert
			state = State.Chasing
	if state == State.Patrolling && $De_agroTimer.is_stopped():
		alert = Alert.Normal
		if computers != null:
			state = State.Computing
		
		############ HOW TO INTERACT WITH COMPUTER NOW THAT IT IS AN AREA2D?#########


# Switches the direction of the NPC
func chooseDirection():
	# Determines direction when the NPC is actively patrolling
	if state == State.Patrolling:
		# Changes the direction when the NPC either hits a wall or approaches an edge
		if is_on_wall() || not $FloorLine.is_colliding():
			_switch_directions()
		if $De_agroTimer.is_stopped():
			find_computer()

	# Determines direction when the NPC is chasing the player
	if state == State.Chasing:
		# If the NPC hits wall or ledge when chasing the player, just stops
		if is_on_wall() || not $FloorLine.is_colliding():
			$NPCsprite.play("Idle")
		# If the player is within detection range, sets direction towards the player
		if detected:
			new_direction = stepify(position.direction_to(nearby_bodies.position).x, 1)
			if new_direction == 0:
				$NPCsprite.play("Idle")
			elif new_direction != direction:
				_switch_directions()
		
		# If the NPC is still on alert but player leaves detection
		else:
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
		velocity.x = direction * 50
	# If the NPC is in a stationary state
	if state == State.Idle || state == State.Computing || state == State.Dead:
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
	# Plays when the NPC dies
	elif state == State.Dead:
		die()
	
	# Normal phase
	if alert == Alert.Normal || state == State.Dead:
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
	# Flips the edge detection
	$FloorLine.position.x = $FloorLine.position.x * -1


func detect():
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(position, nearby_bodies.position, [self], collision_mask)
	if result:
		hit_pos = result.position
		if result.collider.name == "Player":
			detected = true
		else:
			yield(get_tree().create_timer(4), "timeout")
			detected = false

func find_computer():
	if $SearchComputerRight.is_colliding() && $SearchComputerRight.get_collider().get_name() == "ComputerBody":
		new_direction = stepify(position.direction_to(nearby_bodies.position).x, 1)
		if direction != new_direction:
			_switch_directions()
	elif $SearchComputerLeft.is_colliding() && $SearchComputerLeft.get_collider().get_name() == "ComputerBody":
		new_direction = stepify(position.direction_to(nearby_bodies.position).x, 1)
		if direction != new_direction:
			_switch_directions()

func die():
	state = State.Dead
	particle_system.emitting = true
	$AnimationPlayer.play("fade_out")
	yield(get_tree().create_timer(1.5), "timeout")
	queue_free()


func _on_Detection_Radius_body_entered(body):
	nearby_bodies = body

func _on_Detection_Radius_body_exited(body):
	nearby_bodies = null
	detected = false


func _on_Compute_body_entered(body):
	if body.get_name() == "ComputerBody":
		computers = body
		


func _on_Compute_body_exited(body):
	computers = null


func _on_Killzone_body_entered(body):
	if body.get_name() == "Player":
		emit_signal("kill")
