extends Node3D

@onready var needle = $Needle

func update_needle(angle: float):
	needle.rotation.y = angle
