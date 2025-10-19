extends Area3D

@export var sounds: Array[AudioStreamPlayer3D]
@export var item_state: Player.ItemState = Player.ItemState.HAS
@onready var crack = $"../Crack"

var event_triggered = false

func _on_body_entered(body: Node3D) -> void:
	if event_triggered:
		return
	
	if body is Player and body.item_state == item_state:
		for sound in sounds:
			sound.play()
		crack.visible = true
		event_triggered = true
