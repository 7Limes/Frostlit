extends Area3D

@onready var creature = %Creature
@export var start_pos: Node3D
@export var end_pos: Node3D
@export var item_state: Player.ItemState
@export var swim_time: float = 1.0

var event_triggered = false
var moving = false
var move_timer = 0.0


func _on_body_entered(body: Node3D) -> void:
	if event_triggered:
		return
	
	if body is Player and body.item_state == item_state:
		creature.visible = true
		creature.global_position = start_pos.global_position
		creature.rotation = start_pos.rotation
		event_triggered = true
		moving = true


func _process(delta: float) -> void:
	if moving:
		move_timer = move_toward(move_timer, swim_time, delta)
		var t = remap(move_timer, 0.0, swim_time, 0.0, 1.0)
		creature.global_position = start_pos.global_position.lerp(end_pos.global_position, t)
		if move_timer >= swim_time:
			moving = false
			creature.visible = false
