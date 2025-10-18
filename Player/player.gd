extends CharacterBody3D

@export var sensitivity = 0.1
@export var acceleration: float = 20.0
@export var max_speed: float = 3.0
@export var friction: float = 15.0
@export var gravity: float = 8.0

@onready var camera = $Camera
@onready var compass = $Camera/Compass

var mouse_motion: Vector2 = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = event.relative


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('pause'):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func look_tick():
	rotation_degrees.y -= mouse_motion.x * sensitivity
	
	# Rotate camera up/down (pitch)
	camera.rotation_degrees.x -= mouse_motion.y * sensitivity
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -89, 89)
	
	# Reset mouse motion after processing
	mouse_motion = Vector2.ZERO

	
func move_tick(delta: float):
	var accel_vector = Vector2.ZERO
	var look_vector = Vector2.UP.rotated(-rotation.y)
	var right_vector = Vector2.RIGHT.rotated(-rotation.y)
	
	var input_pressed = false
	
	if Input.is_action_pressed('forward'):
		accel_vector += look_vector
		input_pressed = true
	if Input.is_action_pressed('backward'):
		accel_vector -= look_vector
		input_pressed = true
	if Input.is_action_pressed('left'):
		accel_vector -= right_vector
		input_pressed = true
	if Input.is_action_pressed('right'):
		accel_vector += right_vector
		input_pressed = true
	
	if accel_vector.length() > 0:
		accel_vector = accel_vector.normalized()
	
	if input_pressed:
		velocity.x += accel_vector.x * acceleration * delta
		velocity.z += accel_vector.y * acceleration * delta
	else:
		var horizontal_velocity = Vector2(velocity.x, velocity.z)
		horizontal_velocity = horizontal_velocity.move_toward(Vector2.ZERO, friction * delta)
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.y
	
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	if horizontal_velocity.length() > max_speed:
		horizontal_velocity = horizontal_velocity.normalized() * max_speed
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.y
	
	velocity.y -= gravity * delta
	

func update_compass():
	compass.update_needle(-rotation.y)


func _process(delta: float) -> void:
	look_tick()
	move_tick(delta)
	move_and_slide()
	update_compass()
