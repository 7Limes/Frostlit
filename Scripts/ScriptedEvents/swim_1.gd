extends Area3D

@onready var creature = %Creature
@export var start_pos: Node3D
@export var end_pos: Node3D
@export var item_state: Player.ItemState

const MOVE_DURATION = 1.0

var event_triggered = false
var moving = false
var move_timer = 0.0


func _on_body_entered(body: Node3D) -> void:
	if event_triggered:
		return
	
	if body is Player and body.item_state == item_state:
		creature.visible = true
		creature.position = start_pos.position
		event_triggered = true
		moving = true


func _process(delta: float) -> void:
	if moving:
		move_timer = move_toward(move_timer, MOVE_DURATION, delta)
		var t = remap(move_timer, 0.0, MOVE_DURATION, 0.0, 1.0)
		creature.position = start_pos.position.lerp(end_pos.position, t)
		if move_timer >= MOVE_DURATION:
			moving = false
			creature.visible = false
