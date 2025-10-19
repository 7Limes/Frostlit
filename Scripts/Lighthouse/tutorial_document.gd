extends Area3D

@onready var tutorial_ui = %TutorialUI

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		tutorial_ui.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		tutorial_ui.visible = false
