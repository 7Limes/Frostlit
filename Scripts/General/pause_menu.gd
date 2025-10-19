extends ColorRect

var paused = false

@onready var debug_panel = %DebugPanel
@onready var environment: WorldEnvironment = %Environment
@onready var player: Player = %Player

func update_pause():
	get_tree().paused = paused
	visible = paused
	
	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('pause'):
		paused = not paused
	update_pause()


func _on_resume_button_pressed() -> void:
	paused = false
	update_pause()


func _on_debug_button_pressed() -> void:
	debug_panel.visible = not debug_panel.visible


func _on_toggle_fog_pressed() -> void:
	if environment.environment.fog_density != 0:
		environment.environment.fog_density = 0
	else:
		environment.environment.fog_density = 0.1


func _on_toggle_speed_pressed() -> void:
	if player.max_speed != 20:
		player.max_speed = 20
	else:
		player.max_speed = 5
