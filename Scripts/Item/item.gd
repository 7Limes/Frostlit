extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player and body.item_state == Player.ItemState.NONE:
		body.item_state = Player.ItemState.HAS
		visible = false
		set_deferred('monitoring', false)
