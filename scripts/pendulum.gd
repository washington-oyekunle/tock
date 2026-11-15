extends Node3D
## The great clock's pendulum: it swings across the tower hall, and back.

var phase := 0.0
var speed := 1.25
var amplitude := 0.52
var bob: Node3D


func _ready() -> void:
	TimeControl.register(self)
	_apply()


func _exit_tree() -> void:
	TimeControl.unregister(self)


func _physics_process(delta: float) -> void:
	if TimeControl.rewinding:
		return
	phase += delta * speed
	_apply()


func _apply() -> void:
	rotation.z = sin(phase) * amplitude


func bob_position() -> Vector3:
	return bob.global_position if bob else global_position


func rewind_capture() -> PackedFloat32Array:
	return PackedFloat32Array([phase])


func rewind_restore(data: PackedFloat32Array) -> void:
	if data.size() < 1:
		return
	phase = data[0]
	_apply()
