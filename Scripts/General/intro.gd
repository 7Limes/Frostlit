extends Control

@onready var text_label = %Text
@onready var fade_rect = $FadeRect
@onready var full_fade_rect = $FullFadeRect

var text_index = 0

const TEXTS = [
	"You are a researcher conducting tests at a remote lighthouse in the Pacific.",
	"Several days ago, the Sun was displaced due to an unknown cosmological phenomenon, plunging the Earth into an eternal winter.",
	"In the following days, the Earth’s oceans froze over and the planet became enveloped in a dense fog.",
	"You managed to survive, but the lighthouse beacon has been destroyed by the cold.",
	"You’ve received radio communication that rescuers are approaching your area, but they will be unable to locate you without the lighthouse beacon.",
	"Your only hope now is to salvage the repair parts from nearby ships trapped in the ice.",
	"Good luck."
]


func fade_next_text():
	var next_text = TEXTS[text_index]
	text_index += 1
	
	var next_scene = func():
		get_tree().change_scene_to_file("res://Scenes/main-scene.tscn")
	
	var full_fade = func():
		await get_tree().create_timer(2.0).timeout
		var full_fade_tween = create_tween()
		full_fade_tween.tween_property(full_fade_rect, 'color:a', 1.0, 3.0)
		full_fade_tween.tween_callback(next_scene)
	
	var fade_in = func():
		var fade_in_tween = create_tween()
		text_label.text = next_text
		fade_in_tween.tween_property(fade_rect, 'color:a', 0.0, 0.5)
		if text_index == len(TEXTS):
			fade_in_tween.tween_callback(full_fade)
	
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(fade_rect, 'color:a', 1.0, 0.5)
	fade_out_tween.tween_callback(fade_in)

func _ready() -> void:
	fade_next_text()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('interact') and text_index < len(TEXTS):
		fade_next_text()
