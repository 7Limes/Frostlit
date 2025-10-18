extends Area3D


@onready var sections = %Sections

var section_number: int = 0



func _on_body_entered(body: Node3D) -> void:
	var locate_next_item = func():
		var section = sections.get_child(section_number)
		
		var item_node = section.item_node
		section_number += 1
		body.item_state = Player.ItemState.NONE
		var new_target = Vector2(item_node.position.x, item_node.position.z)
		body.update_compass_target(new_target)
		body.update_actionbar("Your compass is now pointing to the nearest part.")
		body.update_interact_function(null)
	
	if body is Player:
		if body.item_state == Player.ItemState.NEXT:
			body.update_actionbar("Press E to locate a part")
			body.update_interact_function(locate_next_item)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.update_actionbar("")
		body.update_interact_function(null)
