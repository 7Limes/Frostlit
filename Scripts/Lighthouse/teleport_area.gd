extends Area3D


@export var destination: Node3D
@export var actionbar_prompt: String

@export var interact_sfx: AudioStreamPlayer3D
@export var arrive_sfx: AudioStreamPlayer3D

@export var indoor_destination: bool = true

@onready var fade_rect = %FadeRect


func _on_body_entered(body: Node3D) -> void:
	var end_fade = func():
		body.toggle_can_interact(true)
		body.toggle_frozen(false)
		if arrive_sfx:
			arrive_sfx.play()
	
	var halfway = func():
		body.global_transform.origin = destination.global_transform.origin
		body.rotation = destination.rotation
		body.toggle_indoors(indoor_destination)
		fade_rect.do_fade(false, end_fade)
	
	var fade = func():
		fade_rect.do_fade(true, halfway)
		body.toggle_can_interact(false)
		body.toggle_frozen(true)
		if interact_sfx:
			interact_sfx.play()
	
	if body is Player:
		body.update_actionbar(actionbar_prompt)
		body.update_interact_function(fade)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.update_actionbar("")
		body.update_interact_function(null)
