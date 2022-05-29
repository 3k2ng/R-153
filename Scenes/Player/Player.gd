extends KinematicBody2D


onready var ray_left = $Raycasts/Left
onready var ray_right = $Raycasts/Right
onready var ray_up = $Raycasts/Up
onready var ray_down = $Raycasts/Down
onready var sprite = $Sprite

export (int) var speed = 400
export (int) var gravity_strength = 30
export (int) var roll_animation_speed = 10


var velocity = Vector2.ZERO
var gravity = Vector2.ZERO

var action = Action.IDLE
var state = State.FALLING

enum State {
	FLOOR,
	WALL_LEFT,
	WALL_RIGHT,
	CEILING,
	FALLING
}

enum Action {
	MOVE_LEFT,
	MOVE_RIGHT,
	MOVE_UP,
	MOVE_DOWN,
	IDLE
}


func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	_process_input()
	_process_gravity()
	velocity += gravity
	velocity = move_and_slide(velocity, Vector2.UP)
	print(str(state))
	_update_state()
	_update_animation()
	
	
func _process_input() -> void:
	
	# Player moves on x axis
	if state == State.FLOOR or state == State.CEILING or state == State.FALLING:
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
	
	# Player moves on y axis
	if state == State.WALL_LEFT or state == State.WALL_RIGHT:
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
			if _ray_up():
				_set_state(State.CEILING)
		if Input.is_action_pressed("Left") and state == State.WALL_RIGHT:
			if _ray_down():
				_set_state(State.FLOOR)
			if _ray_up():
				_set_state(State.CEILING)
	

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
	if !ray_left.is_colliding() \
		and !ray_right.is_colliding() \
		and !ray_up.is_colliding() \
		and !ray_down.is_colliding() \
		and !state == State.FALLING:
			state = State.FALLING
	
	if state == State.FALLING:
		if ray_down.is_colliding():
			state = State.FLOOR
		if ray_up.is_colliding():
			state = State.CEILING
		if ray_left.is_colliding():
			state = State.WALL_LEFT
		if ray_right.is_colliding():
			state = State.WALL_RIGHT

func _update_animation():
	if action == Action.MOVE_LEFT and !_ray_left():
		if state == State.FLOOR:
			sprite.rotate(deg2rad(-roll_animation_speed))
		if state == State.CEILING:
			sprite.rotate(deg2rad(roll_animation_speed))

	if action == Action.MOVE_RIGHT and !_ray_right():
		if state == State.FLOOR:
			sprite.rotate(deg2rad(roll_animation_speed))
		if state == State.CEILING:
			sprite.rotate(deg2rad(-roll_animation_speed))

	if action == Action.MOVE_UP and !_ray_up():
		if state == State.WALL_LEFT:
			sprite.rotate(deg2rad(-roll_animation_speed))
		if state == State.WALL_RIGHT:
			sprite.rotate(deg2rad(roll_animation_speed))

	if action == Action.MOVE_DOWN and !_ray_down():
		if state == State.WALL_LEFT:
			sprite.rotate(deg2rad(roll_animation_speed))
		if state == State.WALL_RIGHT:
			sprite.rotate(deg2rad(-roll_animation_speed))
	
	# TODO: Fix by using previous state
	if state == State.FALLING:
		if velocity.x > 0:
			sprite.rotate(deg2rad(roll_animation_speed))
		if velocity.x < 0:
			sprite.rotate(deg2rad(-roll_animation_speed))

#	if velocity.x > 0 and !_ray_right():
#		if state == State.CEILING:
#			sprite.rotate(deg2rad(-roll_animation_speed))
#		else:
#			sprite.rotate(deg2rad(roll_animation_speed))
#	if velocity.x < 0 and !_ray_left():
#		if state == State.CEILING:
#			sprite.rotate(deg2rad(roll_animation_speed))
#		else:
#			sprite.rotate(deg2rad(-roll_animation_speed))
	
	

func _ray_right() -> bool:
	return ray_right.is_colliding()

func _ray_left() -> bool:
	return ray_left.is_colliding()

func _ray_up() -> bool:
	return ray_up.is_colliding()

func _ray_down() -> bool:
	return ray_down.is_colliding()
		
func _set_state(state):
	self.state = state

func _set_action(action):
	self.action = action
	
func normalize_num(value) -> int:
	if value > 0: return 1
	elif value < 0: return -1
	else: return 0
	

