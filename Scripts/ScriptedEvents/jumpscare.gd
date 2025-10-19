extends Area3D


@onready var creature = %RealCreature
@onready var fade_rect = %FadeRect
@export var end_pos: Node3D

var event_triggered = false


func _on_body_entered(body: Node3D) -> void:
	if event_triggered:
		return
	
	if body is Player and body.item_state == Player.ItemState.HAS:
		event_triggered = true
		creature.visible = true
		body.jumpscare_sound.play()
		var tweener = create_tween()
		tweener.tween_property(creature, 'position', end_pos.position, 0.5)
		tweener.tween_callback(func():
			fade_rect.color.a = 1.0
			body.wind_sound.volume_db = -80.0
			body.toggle_frozen(true)
			await get_tree().create_timer(5.0).timeout
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			get_tree().change_scene_to_file('res://Scenes/title.tscn')
		)
		
