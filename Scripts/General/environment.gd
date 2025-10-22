class_name FogEnvironment
extends WorldEnvironment

@export var outdoor_fog_density = 0.1
@export var indoor_fog_density = 0.01


func toggle_fog(indoor: bool):
	if indoor:
		environment.fog_density = indoor_fog_density
	else:
		environment.fog_density = outdoor_fog_density
