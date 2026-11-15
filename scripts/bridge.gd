extends AnimatableBody3D
## The drawbridge sits under the courtyard until the plate is weighted.

var progress := 0.0
var target := 0.0
var latched := false
var base_position := Vector3.ZERO
var travel := 3.4


func _ready() -> void:
	base_position = position
	TimeControl.register(self)


func _exit_tree() -> void:
	TimeControl.unregister(self)


func _physics_process(delta: float) -> void:
	if TimeControl.rewinding:
		return
	if latched:
		target = 1.0
	progress = move_toward(progress, target, delta * 1.15)
	_apply()


func _apply() -> void:
	position = base_position - Vector3(0, travel * (1.0 - progress), 0)


func rewind_capture() -> PackedFloat32Array:
	return PackedFloat32Array([progress])


func rewind_restore(data: PackedFloat32Array) -> void:
	if data.size() < 1:
		return
	progress = data[0]
	_apply()
