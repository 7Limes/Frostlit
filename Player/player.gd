class_name Player
extends CharacterBody3D

@export var sensitivity = 0.1
@export var acceleration: float = 20.0
@export var max_speed: float = 3.0
@export var friction: float = 15.0
@export var gravity: float = 8.0

@export var footstep_interval: float = 0.75  ## The time in seconds between footsteps.

@onready var camera = $Camera
@onready var compass = $Camera/Compass
@onready var actionbar = %Actionbar

const DEFAULT_GROUND_TYPE = "stone"

@onready var STEP_SOUND_LOOKUP = {
	"stone": $SFX/StoneFootstepSounds,
	"snow": $SFX/SnowFootstepSounds,
	"wood": $SFX/WoodFootstepSounds
}


var mouse_motion: Vector2 = Vector2.ZERO
var frozen: bool = false

var footstep_timer: float = 0.0
var current_ground_type: String = DEFAULT_GROUND_TYPE

var interact_function = null  # Callable or null
var can_interact: bool = true


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = event.relative


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('pause'):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Tick functions
func ground_tick():
	var space_state = get_world_3d().direct_space_state
	var origin = global_position
	var end = origin + Vector3.DOWN * 1000
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	var result = space_state.intersect_ray(query)
	if result:
		if result.collider.has_meta('ground'):
			current_ground_type = result.collider.get_meta('ground')
		else:
			current_ground_type = DEFAULT_GROUND_TYPE


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
		if is_on_floor():
			footstep_timer = move_toward(footstep_timer, footstep_interval, delta)
	else:
		var friction_velocity = Vector2(velocity.x, velocity.z)
		friction_velocity = friction_velocity.move_toward(Vector2.ZERO, friction * delta)
		velocity.x = friction_velocity.x
		velocity.z = friction_velocity.y
	
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	if horizontal_velocity.length() > max_speed:
		horizontal_velocity = horizontal_velocity.normalized() * max_speed
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.y
	
	velocity.y -= gravity * delta
	

func footstep_tick():
	var footstep_sounds: AudioStreamPlayer3D = STEP_SOUND_LOOKUP[current_ground_type]
	if footstep_timer == footstep_interval:
		footstep_sounds.play()
		footstep_timer = 0.0


func interact_tick():
	if can_interact and interact_function != null and Input.is_action_just_pressed('interact'):
		interact_function.call()


func update_compass():
	compass.update_needle(-rotation.y)


# External functions 
func update_actionbar(new_text: String):
	actionbar.text = new_text
	if new_text == "":
		actionbar.visible = false
	else:
		actionbar.visible = true


func update_interact_function(interact_func):
	interact_function = interact_func


func toggle_frozen(toggle_on: bool):
	frozen = toggle_on


func toggle_can_interact(toggle_on: bool):
	can_interact = toggle_on


func _process(delta: float) -> void:
	look_tick()
	move_tick(delta)
	
	if frozen:
		velocity = Vector3.ZERO
	
	move_and_slide()
	
	update_compass()
	interact_tick()
	
	ground_tick()
	footstep_tick()
