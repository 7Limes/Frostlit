extends Area3D

@onready var creature = %Creature
@onready var start_pos: Vector3 = creature.position
@onready var destination = $"../SwimDestination".position

const MOVE_DURATION = 1.0

var event_triggered = false
var moving = false
var move_timer = 0.0


func _on_body_entered(body: Node3D) -> void:
	if event_triggered:
		return
	
	if body is Player and body.item_state == Player.ItemState.HAS:
		print('triggered')
		creature.visible = true
		event_triggered = true
		moving = true


func _process(delta: float) -> void:
	if moving:
		move_timer = move_toward(move_timer, MOVE_DURATION, delta)
		var t = remap(move_timer, 0.0, MOVE_DURATION, 0.0, 1.0)
		creature.position = start_pos.lerp(destination, t)
		if move_timer >= MOVE_DURATION:
			moving = false
			creature.visible = false
