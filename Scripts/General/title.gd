extends Node3D

@onready var fade_rect = $FadeRect
@onready var wind_sound = $WindSound

func _on_play_button_pressed() -> void:
	var fade_tweener = create_tween()
	fade_tweener.tween_property(fade_rect, 'color:a', 1.0, 1.0)
	fade_tweener.tween_callback(func(): get_tree().change_scene_to_file("res://Scenes/main-scene.tscn"))
	var volume_tweener = create_tween()
	volume_tweener.tween_property(wind_sound, 'volume_db', -40.0, 1.0)
