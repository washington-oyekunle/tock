extends Node3D
## Third-person camera: mouse orbit, gentle follow, spring arm for walls.

var yaw := 0.0
var pitch := -0.20
var distance := 4.9
var target: Node3D

var _arm: SpringArm3D
var _cam: Camera3D
var _shake := 0.0


func _ready() -> void:
	_arm = SpringArm3D.new()
	_arm.spring_length = distance
	_arm.collision_mask = 1
	_arm.margin = 0.3
	add_child(_arm)
	_cam = Camera3D.new()
	_cam.fov = 60.0
	_cam.near = 0.08
	_cam.far = 400.0
	_cam.current = true
	_arm.add_child(_cam)


func _process(delta: float) -> void:
	if target:
		var want := target.global_position + Vector3(0, 1.15, 0)
		global_position = global_position.lerp(want, 1.0 - exp(-11.0 * delta))
	rotation.y = yaw
	_arm.rotation.x = pitch + sin(_shake * 40.0) * 0.004 * _shake
	_shake = maxf(_shake - delta * 2.0, 0.0)


func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * 0.0032
		pitch = clampf(pitch - event.relative.y * 0.0022, -1.05, 0.18)
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
