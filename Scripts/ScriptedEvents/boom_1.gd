extends Area3D

@onready var boom_sound = $"../BoomSound"
@onready var crack = $"../Crack"
var event_triggered = false

func _on_body_entered(body: Node3D) -> void:
	if event_triggered:
		return
	
	if body is Player and body.item_state == Player.ItemState.HAS:
		boom_sound.play()
		crack.visible = true
		event_triggered = true
