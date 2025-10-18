extends Area3D


@onready var fix_sound: AudioStreamPlayer3D = $FixSound

func _on_body_entered(body: Node3D) -> void:
	var add_part = func():
		body.item_state = Player.ItemState.NEXT
		fix_sound.play()
		body.update_actionbar("Added part. Return to the radar to locate the next item.")
		
	
	if body is Player:
		if body.item_state == Player.ItemState.HAS:
			body.update_actionbar("Press E to add part")
			body.update_interact_function(add_part)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.update_actionbar("")
		body.update_interact_function(null)
