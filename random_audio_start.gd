extends AudioStreamPlayer

func _ready():
	play()
	await get_tree().process_frame  # Wait one frame to ensure the stream is properly initialized
	
	var stream_length = stream.get_length()
	var random_position = randf() * stream_length
	seek(random_position)
