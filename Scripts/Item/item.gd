extends Area3D


const ROTATE_SPEED = 3


func _on_body_entered(body: Node3D) -> void:
	if body is Player and body.item_state == Player.ItemState.NONE:
		body.item_state = Player.ItemState.HAS
		visible = false
		set_deferred('monitoring', false)
		
		body.update_compass_target(Vector2.ZERO)
		body.update_actionbar("Return to the lighthouse to use the repair part.")
		await get_tree().create_timer(5.0).timeout
		body.update_actionbar("")


func _process(delta: float) -> void:
	rotate_y(delta * ROTATE_SPEED)
