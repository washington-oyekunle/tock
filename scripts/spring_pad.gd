extends Area3D
## A wound clock spring under the stones. Stand on it and Tock goes up.

signal launched

var launch_velocity := Vector3(4.2, 15.4, 0.0)
var cooldown := 0.6
var _cool := 0.0
var _squash := 0.0
var visual: Node3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true


func _physics_process(delta: float) -> void:
	_cool = maxf(_cool - delta, 0.0)
	if TimeControl.rewinding or _cool > 0.0:
		return
	for b in get_overlapping_bodies():
		if b.has_method("launch"):
			b.launch(launch_velocity)
			_cool = cooldown
			_squash = 1.0
			launched.emit()
			break


func _process(delta: float) -> void:
	_squash = maxf(_squash - delta * 2.6, 0.0)
	if visual:
		visual.scale = Vector3(1.0 + _squash * 0.28, 1.0 - _squash * 0.55, 1.0 + _squash * 0.28)
