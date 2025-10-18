extends Area3D


@export var destination: Node3D
@export var actionbar_prompt: String

@export var interact_sfx: AudioStreamPlayer3D
@export var arrive_sfx: AudioStreamPlayer3D

@onready var fade_rect = %FadeRect
@onready var player = %Player


func _on_body_entered(body: Node3D) -> void:
	var end_fade = func():
		player.toggle_can_interact(true)
		player.toggle_frozen(false)
		if arrive_sfx:
			arrive_sfx.play()
	
	var halfway = func():
		body.global_transform.origin = destination.global_transform.origin
		body.rotation = destination.rotation
		fade_rect.do_fade(false, end_fade)
	
	var fade = func():
		fade_rect.do_fade(true, halfway)
		player.toggle_can_interact(false)
		player.toggle_frozen(true)
		if interact_sfx:
			interact_sfx.play()
	
	if body is Player:
		body.update_actionbar(actionbar_prompt)
		body.update_interact_function(fade)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.update_actionbar("")
		body.update_interact_function(null)
