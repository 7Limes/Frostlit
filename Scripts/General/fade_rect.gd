extends ColorRect

@export var fade_duration = 0.5


func do_fade(to_black: bool, finish_callback: Callable):
	var tweener = create_tween()
	var final_val = 1.0 if to_black else 0.0
	tweener.tween_property(self, "color:a", final_val, fade_duration)
	tweener.tween_callback(finish_callback)
