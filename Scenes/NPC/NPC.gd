extends KinematicBody2D

# Particle node for death animation
onready var particle_system = $ParticleSystem
# Linking the Terminal autoloader
onready var terminal = $"/root/TerminalAutoload"

# Determines the npc's default starting direction
export(int) var  direction = 1
export(bool) var dead = false
var finding_computer = false
# Empty direction variable for checking for differences in direction
var new_direction = null
# Initiate velocity to a 2D vector
var velocity = Vector2()

# Empty variable for passing player body information
var nearby_bodies = null
# Empty variable for passing computer body information
var computers = null

# Empty Boolean for detection status
var detected = null



# if this computer emit explode, then die
var nearby_computer = ""
var rng = RandomNumberGenerator.new()

# Alert states
enum Alert {
	Normal 		# Index = 0
	Question	# Index = 1
	Caution		# Index = 2
	Alert		# Index = 3
}

# Action states
enum State {
	Idle		# Index = 0
	Computing	# Index = 1
	Patrolling	# Index = 2
	Chasing		# Index = 3
	Dead		# Index = 4
	}
# Variable indicating the NPC action state
export(State) var state = State.Patrolling
# Variable for indicating the NPC alert state
var alert = Alert.Normal

# Runs before the program starts
func _ready():
	# Positions the edge detection according to the starting direction
	$FloorLine.position.x = ($NPCcollisionBox.shape.get_extents().x / 5) * direction
	# Checks if the sprite needs to be flipped
	if direction == 1:
		$NPCsprite.flip_h = true
	# Connect emit signals
	terminal.connect("die", self, "die")
	rng.randomize()
	if state == State.Computing:
		finding_computer = true

# Function that's called every frame. Basically modifies npc behavior in real time
func _physics_process(_delta):
	if not dead:
		_random_change()
		# Check for a change in state
		_change_state()
		# Checks if the npc has hit a wall, facilitating a change in direction for movement
		chooseDirection()
		# Determines which animation should be played
		_animation()
		# Applies the horizontal movement in the intended direction
		_move_velocity()
		_toggle_zone()
		if finding_computer == true:
			if computers != null:
				state = State.Computing
		# Stops the de_agro timer if it was running
		if $De_agroTimer.time_left < 0.2:
			$De_agroTimer.stop()
		# If there is a Player in the detection areas, check for detection
		if nearby_bodies:
			detect()

##################################################################################
func _random_change():
	if state != State.Chasing && alert == Alert.Normal:
		if $random_timer.is_stopped():
				$random_timer.start()
		if $random_timer.time_left < 0.1:
			$random_timer.stop()
			var num = stepify(rng.randf_range(0,100), 1)
			if num >= 1 && num <= 15:
				state = State.Idle
				finding_computer = false
			elif num >= 20 && num <= 30:
				state = State.Patrolling
				find_computer()
			elif num >= 80 && num <= 100:
				state = State.Patrolling
				finding_computer = false
			elif num >= 50 && num <= 60:
				finding_computer = false
				_switch_directions()
##################################################################################

# Change action states
func _change_state():
	# For every other state than active chase state
	if state != State.Chasing:
		# If the NPC sees the player
		if detected:
			finding_computer = false
			# NPC questions what he sees
			alert = Alert.Question
			# Wait buffer
			yield(get_tree().create_timer(1.0), "timeout")
			# Confirms it's Player
			alert = Alert.Alert
			# Chases player
			state = State.Chasing

	# If was patrolling and the agro cooldown has expired
	if state == State.Patrolling && $De_agroTimer.is_stopped() && alert == Alert.Caution:
		# Return to normal alert
		alert = Alert.Normal

# Switches the direction of the NPC
func chooseDirection():
	# Determines direction when the NPC is actively patrolling
	if state == State.Patrolling:
		# Changes the direction when the NPC either hits a wall or approaches an edge
		if is_on_wall() || not $FloorLine.is_colliding():
			_switch_directions()
	
	# Determines direction when the NPC is chasing the player
	if state == State.Chasing:
		# If the player is within detection range, sets direction towards the player
		if nearby_bodies:
			new_direction = stepify(position.direction_to(nearby_bodies.position).x, 1)
		# If player is above the NPC
		if new_direction == 0:
			$NPCsprite.play("Idle")
		# If the NPC detects the player in the opposite direction to which it's facing
		elif new_direction != direction:
			_switch_directions()
		# If the NPC hits wall or ledge when chasing the player, just stops
		if is_on_wall() || not $FloorLine.is_colliding():
			$NPCsprite.play("Idle")
		# If the NPC is still on alert but player leaves detection
		else:
			if !detected:
				# Waits 2 seconds before NPC becomes confused
				yield(get_tree().create_timer(2.0), "timeout")
			# NPC has lost the player, becomes confused
			if !detected:
				alert = Alert.Question
			if !detected:
				# Another wait
				yield(get_tree().create_timer(1.0), "timeout")
			if !detected:
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
	if state == State.Chasing || alert == Alert.Caution:
		velocity.x = direction * 70
	elif state == State.Patrolling:
		velocity.x = direction * 20
	# If the NPC is in a stationary state
	if state == State.Idle || state == State.Computing || state == State.Dead:
		velocity.x = 0
	# Apply the new velocity
	velocity = move_and_slide(velocity, Vector2.UP)


# Play animations depending on the state and alertness of NPC
func _animation():
	# Plays if the NPC is just hanging out
	if state == State.Idle || state == State.Dead:
		$NPCsprite.play("Idle")
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
	# Flips the edge detection
	$FloorLine.position.x = $FloorLine.position.x * -1

func _toggle_zone():
	if direction == 1 && (state == State.Patrolling || state == State.Chasing):
		$Detection_Radius/DetectRight.set_disabled(false)
		$Detection_Radius/DetectLeft.set_disabled(true)
	elif direction == -1 && (state == State.Patrolling || state == State.Chasing):
		$Detection_Radius/DetectLeft.set_disabled(false)
		$Detection_Radius/DetectRight.set_disabled(true)
	elif state == State.Computing:
		$Detection_Radius/DetectRight.set_disabled(true)
		$Detection_Radius/DetectLeft.set_disabled(true)
	elif state == State.Idle || direction == 0:
		$Detection_Radius/DetectRight.set_disabled(false)
		$Detection_Radius/DetectLeft.set_disabled(false)

# Check if the player is within line of sight
func detect():
	var space_state = get_world_2d().direct_space_state
	# Cast a raycast2d towards the body
	var result = space_state.intersect_ray(position, nearby_bodies.position, [self], collision_mask)
	# If it makes contact with something
	if result:
		if result.collider.name == "Player":
			detected = true
		else:
			detected = false

# Uses 2 raycasts to find the computer to return to
func find_computer():
	finding_computer = true
	# If the computer is to the right
	if $SearchComputerRight.is_colliding() && $SearchComputerRight.get_collider().get_name() == "ComputerBody":
		# Change direction towards it
		new_direction = stepify(position.direction_to(nearby_bodies.position).x, 1)
		if direction != new_direction:
			_switch_directions()
	# If the computer is to the left
	elif $SearchComputerLeft.is_colliding() && $SearchComputerLeft.get_collider().get_name() == "ComputerBody":
		# Change directions towards it
		new_direction = stepify(position.direction_to(nearby_bodies.position).x, 1)
		if direction != new_direction:
			_switch_directions()

# Death function
func die(exploded_system):
	# Check if this is the intended target
	if exploded_system == nearby_computer:
		# NPC is dead, velocity is 0 
		state = State.Dead
		_move_velocity()
		_animation()
		# Fade out the sprite
		$AnimationPlayer.play("die")
		self.set_collision_layer_bit(2, false)
		self.set_collision_mask_bit(1, false)
		Sounds.npc_explode.play()
		yield(get_node("AnimationPlayer"), "animation_finished")
		$"/root/BodyCheck".check_bodies()

# If a player enters the detection radius
func _on_Detection_Radius_body_entered(body):
	nearby_bodies = body

# If the player leaves the radius
func _on_Detection_Radius_body_exited(body):
	nearby_bodies = null
	detected = false

# If the player falls into the "kill" range of the NPC
func _on_Killzone_body_entered(body):
	if body in get_tree().get_nodes_in_group("player") and not dead:
		# Emit the death signal with the Player's corresponding ID
		TerminalAutoload.emit_signal("explode", "_player")

# Check for computer being dead center aligned with NPC
func _on_Compute_area_entered(area):
	if area in get_tree().get_nodes_in_group("computer"):
		computers = area

# Computer no longer centered on NPC
func _on_Compute_area_exited(area):
	computers = null

func set_nearby(system_name):
	nearby_computer = system_name
