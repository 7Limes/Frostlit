extends ColorRect

var paused = false


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
