extends Node3D
## The tower's stone, rolling down the courtyard on its own schedule.

var radius := 0.95
var t := 0.0
var wait := 0.0
var speed := 0.085
var mesh: Node3D

const START_Z := -2.2
const END_Z := 7.5


func _ready() -> void:
	TimeControl.register(self)
	_apply()


func _exit_tree() -> void:
	TimeControl.unregister(self)


func _physics_process(delta: float) -> void:
	if TimeControl.rewinding:
		return
	if wait > 0.0:
		wait -= delta
		if wait <= 0.0:
			t = 0.0
			_apply()
		return
	t += speed * delta
	if t >= 1.0:
		t = 1.0
		wait = 1.6
	_apply()


func _apply() -> void:
	var z := lerpf(START_Z, END_Z, t)
	global_position = Vector3(0, ground_height(z) + radius, z)
	if mesh:
		mesh.rotation.x = -t * (END_Z - START_Z) / maxf(radius, 0.1)
		mesh.scale = Vector3.ONE * (0.72 if wait > 0.0 else 1.0)


func ground_height(z: float) -> float:
	if z >= 1.5:
		return 0.0
	if z <= -1.5:
		return 1.0
	return (1.5 - z) / 3.0


func active() -> bool:
	return wait <= 0.0


func rewind_capture() -> PackedFloat32Array:
	return PackedFloat32Array([t, wait])


func rewind_restore(data: PackedFloat32Array) -> void:
	if data.size() < 2:
		return
	t = data[0]
	wait = data[1]
	_apply()
