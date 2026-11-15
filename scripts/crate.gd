extends RigidBody3D
## A heavy oak crate. Its whole history is on the watch.

func _ready() -> void:
	add_to_group("pushable")
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	continuous_cd = true
	TimeControl.register(self)


func _exit_tree() -> void:
	TimeControl.unregister(self)


func rewind_capture() -> PackedFloat32Array:
	var q := global_transform.basis.get_rotation_quaternion()
	var p := global_position
	return PackedFloat32Array([p.x, p.y, p.z, q.x, q.y, q.z, q.w])


func rewind_restore(data: PackedFloat32Array) -> void:
	if data.size() < 7:
		return
	global_transform = Transform3D(
		Basis(Quaternion(data[3], data[4], data[5], data[6])),
		Vector3(data[0], data[1], data[2])
	)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
