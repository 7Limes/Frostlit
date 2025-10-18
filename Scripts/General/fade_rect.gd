extends ColorRect

@export var fade_duration = 0.5

var fading = false
var fade_to_black = false
var fade_timer = 0.0
var on_finish: Callable


func do_fade(to_black: bool, finish_callback: Callable):
	on_finish = finish_callback
	fading = true
	fade_to_black = to_black
	fade_timer = 0.0


func _process(delta: float) -> void:
	if fading:
		fade_timer = move_toward(fade_timer, fade_duration, delta)
		if fade_timer >= fade_duration:
			fading = false
			on_finish.call()
		else:
			var alpha: float
			if fade_to_black:
				alpha = remap(fade_timer, 0, fade_duration, 0.0, 1.0)
			else:
				alpha = remap(fade_timer, 0, fade_duration, 1.0, 0.0)
			color.a = alpha
