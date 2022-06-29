extends KinematicBody2D


onready var ray_left = $Raycasts/Left
onready var ray_right = $Raycasts/Right
onready var ray_up = $Raycasts/Up
onready var ray_down = $Raycasts/Down
onready var sprite = $AnimatedSprite
onready var camera = $Camera2D
onready var audio_player = $AudioStreamPlayer2D
onready var particle_system = $ParticleSystem
onready var animation_player = $AnimationPlayer
onready var terminal = $"/root/TerminalAutoload"

export (float) var speed = 50
export (float) var gravity_strength = 7.5
export (float) var jump_strength = 100
export (float) var roll_animation_speed = 5
export (float) var zoom_speed = 0.01
export (float) var min_zoom = 0.1
export (float) var max_zoom = 1.0;


var velocity = Vector2.ZERO
var gravity = Vector2.ZERO


var action = Action.IDLE
var state = State.FALLING
var prev_state = State.FALLING
var falling_from_ceiling = false
var jumped = false
var sticked = false

var _disabled_input = false

# if this computer emit explode, then die
var nearby_computer = ""

var _game_over_screen

enum State {
	FLOOR,
	WALL_LEFT,
	WALL_RIGHT,
	CEILING,
	FALLING,
	HACKING
}

enum Action {
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_UP,
	MOVE_DOWN,
	IDLE,
	TRANSFORM_ROBOT,
	TRANSFORM_BALL
}


func _ready() -> void:
	sprite.speed_scale = roll_animation_speed
	terminal.connect("hack", self, "_hack")
	terminal.connect("exit_hacking", self, "_exit_hacking")
	terminal.connect("explode", self, "explode")
	terminal.connect("die", self, "die")
	
	for node in get_tree().get_nodes_in_group("game_end_screens"):
		match node.name:
			"GameOverScreen":
				_game_over_screen = node



func _physics_process(delta: float) -> void:
	if not _disabled_input:
		_process_input()
	_process_gravity()
	velocity += gravity
	velocity = move_and_slide(velocity, Vector2.UP)
	_update_state()
	_update_animation()
	_update_sounds()
	
func _process_input() -> void:
	
	# Player moves on x axis
	if state != State.HACKING:
		if state == State.FLOOR or state == State.CEILING or state == State.FALLING:
			jumped = false
			if state != State.FALLING:
				velocity.x = 0
	#		velocity.x = (Input.get_action_strength("Right") - Input.get_action_strength("Left")) * speed
			if Input.get_action_strength("Right"):
				velocity.x = speed
				action = Action.MOVE_RIGHT
			elif Input.get_action_strength("Left"):
				velocity.x = -speed
				action = Action.MOVE_LEFT
			else:
				action = Action.IDLE
			if Input.is_action_pressed("Up") and state == State.FLOOR:
				if _ray_right():
					_set_state(State.WALL_RIGHT)
				if _ray_left():
					_set_state(State.WALL_LEFT)
			if Input.is_action_pressed("Down") and state == State.CEILING:
				if _ray_right():
					_set_state(State.WALL_RIGHT)
				elif _ray_left():
					_set_state(State.WALL_LEFT)
				else:
					_set_state(State.FALLING)
					falling_from_ceiling = true
		
		# Player moves on y axis
		if state == State.WALL_LEFT or state == State.WALL_RIGHT:
			jumped = false
	#		velocity.y = (Input.get_action_strength("Down") - Input.get_action_strength("Up")) * speed
			velocity.y = 0
			if Input.get_action_strength("Down"):
				velocity.y = speed
				action = Action.MOVE_DOWN
			elif Input.get_action_strength("Up"):
				velocity.y = -speed
				action = Action.MOVE_UP
			else:
				action = Action.IDLE
			if Input.is_action_pressed("Right") and state == State.WALL_LEFT:
				if _ray_down():
					_set_state(State.FLOOR)
				elif _ray_up():
					_set_state(State.CEILING)
				else:
					_set_state(State.FALLING)
					jumped = true
			if Input.is_action_pressed("Left") and state == State.WALL_RIGHT:
				if _ray_down():
					_set_state(State.FLOOR)
				elif _ray_up():
					_set_state(State.CEILING)
				else:
					_set_state(State.FALLING)
					jumped = true
		
			# Jump
		if Input.is_action_pressed("Up") and state == State.FLOOR:
			velocity.y = -jump_strength
			jumped = true
		
		# Camera Zooming
		if Input.is_action_just_released("ZoomIn") or Input.is_action_pressed("ZoomIn"):
			camera.zoom.x = clamp(camera.zoom.x - zoom_speed, min_zoom, max_zoom)
			camera.zoom.y = clamp(camera.zoom.y - zoom_speed, min_zoom, max_zoom)
#			camera.position.y = -200 * camera.zoom.y
		if Input.is_action_just_released("ZoomOut") or Input.is_action_pressed("ZoomOut"):
			camera.zoom.x = clamp(camera.zoom.x + zoom_speed, min_zoom, max_zoom)
			camera.zoom.y = clamp(camera.zoom.y + zoom_speed, min_zoom, max_zoom)
#			camera.position.y = -200 * camera.zoom.y
#	else:
#		if Input.is_action_just_pressed("Exit"):
#			action = Action.TRANSFORM_BALL	
		

func _process_gravity():
	if state == State.WALL_RIGHT:
		gravity = Vector2(gravity_strength, 0)
#		gravity = Vector2.RIGHT * gravity_strength
	elif state == State.WALL_LEFT:
		gravity = Vector2(-gravity_strength, 0)
	elif state == State.CEILING:
		gravity = Vector2(0, -gravity_strength)
	else:
		gravity = Vector2(0, gravity_strength)

func _update_state():
	if !_ray_left() \
		and !_ray_right() \
		and !_ray_up() \
		and !_ray_down() \
		and !state == State.FALLING:
			_set_state(State.FALLING)
	
	if state == State.FALLING:
		if ray_down.is_colliding():
			_set_state(State.FLOOR)
			falling_from_ceiling = false
		if _ray_up():
			_set_state(State.CEILING)
		if _ray_left() and Input.is_action_pressed("Left"):
			_set_state(State.WALL_LEFT)
		if _ray_right() and Input.is_action_pressed("Right"):
			_set_state(State.WALL_RIGHT)
	else:
		jumped = false

func _update_animation():
	
	if action == Action.TRANSFORM_ROBOT:
		sprite.play("transform")
	elif action == Action.TRANSFORM_BALL:
		sprite.play("transform", true)
		# For some reason frame doesnt get to 0??? so I gotta do this weird code
#		yield(sprite, "finished") # yield also doesnt work when reversing animation
		if sprite.frame == 1:
			sprite.frame = 0
			action = Action.IDLE
			state = State.FLOOR		
	else:
		if velocity.x > 0:			
			if state == State.CEILING or falling_from_ceiling:
				sprite.play("roll", true)
			else:
				sprite.play("roll")
		elif velocity.x < 0:
			if state == State.CEILING or falling_from_ceiling:
				sprite.play("roll")
			else:
				sprite.play("roll", true)
		elif velocity.y > 0:
			if state == State.WALL_LEFT:
				sprite.play("roll")
			elif state == State.WALL_RIGHT:
				sprite.play("roll", true)
		elif velocity.y < 0:
			if state == State.WALL_LEFT:
				sprite.play("roll", true)
			elif state == State.WALL_RIGHT:
				sprite.play("roll")
		else:
			sprite.stop()

func _update_sounds():
	if jumped:
		if not audio_player.playing:
			audio_player.play()
#	if sticked:
#		audio_player.play()
			
		

func _ray_right() -> bool:
	return ray_right.is_colliding()

func _ray_left() -> bool:
	return ray_left.is_colliding()

func _ray_up() -> bool:
	return ray_up.is_colliding()

func _ray_down() -> bool:
	return ray_down.is_colliding()
		
func _set_state(state):
#	print("previous state: ", State.keys()[self.state])
#	print("state: ", State.keys()[state])	
#	print("--------------")
	prev_state = self.state
	self.state = state
	
	if prev_state == State.FALLING and state != State.FALLING:
#		print("sticked!")
		sticked = true
	else:
		sticked = false
	
	

func _set_action(action):
	self.action = action
	
#func normalize_num(value) -> int:
#	if value > 0: return 1
#	elif value < 0: return -1
#	else: return 0

func _hack() -> void:
	state = State.HACKING
	action = Action.TRANSFORM_ROBOT	

func _exit_hacking() -> void:
	print("exit hack")
	action = Action.TRANSFORM_BALL

func is_hacking() -> bool:
	return state == State.HACKING

func die() -> void:
	_disabled_input = true
	_game_over_screen.show()
	particle_system.emitting = true
	animation_player.play("fade_out")
	yield(get_tree().create_timer(1.5), "timeout")

func explode(target_system) -> void:
	if target_system == "_player":
		die()
	elif target_system == nearby_computer:
		die()

func set_nearby(system_name):
	nearby_computer = system_name

