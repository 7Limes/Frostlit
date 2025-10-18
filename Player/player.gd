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
@onready var snow_particles = $SnowParticles
@onready var environment: WorldEnvironment = $"../Environment"

const DEFAULT_GROUND_TYPE = "stone"

@onready var step_sound_lookup = {
	"stone": $SFX/StoneFootstepSounds,
	"snow": $SFX/SnowFootstepSounds,
	"wood": $SFX/WoodFootstepSounds
}
@onready var wind_sound = $SFX/WindSound


var mouse_motion: Vector2 = Vector2.ZERO
var frozen: bool = false

var footstep_timer: float = 0.0
var current_ground_type: String = DEFAULT_GROUND_TYPE

var interact_function = null  # Callable or null
var can_interact: bool = true

var compass_target: Vector2 = Vector2.ZERO

enum ItemState {
	NONE,  # No item, compass targeted 
	HAS,   # Has item, compass targeted
	NEXT   # No item, compass not targeted
}
var item_state: ItemState = ItemState.NEXT


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	toggle_indoors(true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_motion = event.relative


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
	var footstep_sounds: AudioStreamPlayer3D = step_sound_lookup[current_ground_type]
	if footstep_timer == footstep_interval:
		footstep_sounds.play()
		footstep_timer = 0.0


func interact_tick():
	if can_interact and interact_function != null and Input.is_action_just_pressed('interact'):
		interact_function.call()


func compass_tick():
	if item_state != ItemState.NEXT:
		var position_vector2 = Vector2(global_position.x, global_position.z)
		var direction_to_target = compass_target - position_vector2
		var angle_to_target = atan2(direction_to_target.x, direction_to_target.y)
		var relative_angle = angle_to_target - rotation.y
		compass.update_needle(relative_angle + PI)


# External functions 
func update_actionbar(new_text: String):
	actionbar.text = new_text
	if new_text == "":
		actionbar.visible = false
	else:
		actionbar.visible = true


func update_interact_function(interact_func):
	interact_function = interact_func


func update_compass_target(new_target: Vector2):
	compass_target = new_target


func toggle_frozen(toggle_on: bool):
	frozen = toggle_on


func toggle_can_interact(toggle_on: bool):
	can_interact = toggle_on


func toggle_indoors(indoors: bool):
	snow_particles.visible = not indoors
	
	# Handle wind audio
	var bus_idx = AudioServer.get_bus_index("Ambience")
	var effect = AudioServer.get_bus_effect(bus_idx, 0)
	var tween = create_tween()
	tween.set_parallel(true) # Allow both tweens to run simultaneously
	
	if indoors:
		tween.tween_method(func(value): effect.cutoff_hz = value, 20000.0, 2000.0, 2.0)
		tween.tween_property(wind_sound, "volume_db", -10, 2.0)
		environment.environment.fog_density = 0.01
	else:
		tween.tween_method(func(value): effect.cutoff_hz = value, 2000.0, 20000.0, 2.0)
		tween.tween_property(wind_sound	, "volume_db", 0.0, 2.0)
		environment.environment.fog_density = 0.135


func _process(delta: float) -> void:
	look_tick()
	move_tick(delta)
	
	if frozen:
		velocity = Vector3.ZERO
	
	move_and_slide()
	
	compass_tick()
	interact_tick()
	
	ground_tick()
	footstep_tick()
