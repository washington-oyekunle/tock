extends CharacterBody3D
## Tock. Runs, jumps, nudges heavy things, and remembers where he was.

const RUN_SPEED := 4.7
const ACCEL := 30.0
const AIR_ACCEL := 10.0
const GRAVITY := 19.0
const JUMP_VELOCITY := 5.4
const PUSH_FORCE := 420.0

var camera_rig: Node3D
var visual: Node3D
var active := true
var interactable: Node = null
var interact_area: Area3D
var _coyote := 0.0
var _buffer := 0.0
var _launch_grace := 0.0
func _ready() -> void:
	collision_layer = 2
	collision_mask = 5
	floor_max_angle = deg_to_rad(52.0)
	floor_snap_length = 0.4
	var shape_node := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.33
	capsule.height = 1.05
	shape_node.shape = capsule
	shape_node.position = Vector3(0, 0.54, 0)
	add_child(shape_node)
	visual = load("res://scripts/boy_visual.gd").new()
	add_child(visual)
	interact_area = Area3D.new()
	interact_area.collision_layer = 0
	interact_area.collision_mask = 8
	interact_area.monitoring = true
	var probe := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.4
	probe.shape = sphere
	probe.position = Vector3(0, 0.7, 0)
	interact_area.add_child(probe)
	add_child(interact_area)
	TimeControl.register(self)


func _exit_tree() -> void:
	TimeControl.unregister(self)


func set_active(value: bool) -> void:
	active = value
	if not active:
		velocity = Vector3.ZERO


func _physics_process(delta: float) -> void:
	if TimeControl.rewinding:
		visual.set_state(0.0, true, 0.0)
		return
	if not active:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	_find_interactable()

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var yaw := 0.0
	if camera_rig:
		yaw = camera_rig.yaw
	var dir := Basis(Vector3.UP, yaw) * Vector3(input.x, 0.0, input.y)
	var target := dir * RUN_SPEED
	var accel := ACCEL if is_on_floor() else AIR_ACCEL
	if _launch_grace > 0.0:
		_launch_grace = maxf(_launch_grace - delta, 0.0)
		accel = 1.5
	velocity.x = move_toward(velocity.x, target.x, accel * delta)
	velocity.z = move_toward(velocity.z, target.z, accel * delta)

	if is_on_floor():
		_coyote = 0.12
	else:
		_coyote = maxf(_coyote - delta, 0.0)
		velocity.y -= GRAVITY * delta
	_buffer = maxf(_buffer - delta, 0.0)
	if Input.is_action_just_pressed("jump"):
		_buffer = 0.13
	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		_buffer = 0.0
		_coyote = 0.0
	if Input.is_action_just_released("jump") and velocity.y > 2.2:
		velocity.y *= 0.55

	var horizontal := Vector2(velocity.x, velocity.z).length()
	if horizontal > 0.35:
		var want := atan2(-velocity.x, -velocity.z)
		rotation.y = lerp_angle(rotation.y, want, 1.0 - exp(-16.0 * delta))
	move_and_slide()
	_push_bodies()
	visual.set_state(horizontal, is_on_floor(), velocity.y)


func _find_interactable() -> void:
	var best: Node = null
	var best_d := 999.0
	for area in interact_area.get_overlapping_areas():
		if not area.has_method("use"):
			continue
		var on: Variant = area.get("enabled")
		if on == false:
			continue
		var d := global_position.distance_to(area.global_position)
		if d < best_d:
			best_d = d
			best = area
	interactable = best


func launch(impulse: Vector3) -> void:
	velocity = impulse
	_launch_grace = 0.95
	_coyote = 0.0
	_buffer = 0.0
	if absf(impulse.x) + absf(impulse.z) > 0.1:
		rotation.y = atan2(-impulse.x, -impulse.z)


func _push_bodies() -> void:
	for i in get_slide_collision_count():
		var c := get_slide_collision(i)
		var body := c.get_collider()
		if body and body.is_in_group("pushable"):
			body.sleeping = false
			body.apply_central_force(-c.get_normal() * PUSH_FORCE)


func rewind_capture() -> PackedFloat32Array:
	return PackedFloat32Array([
		global_position.x, global_position.y, global_position.z,
		rotation.y, velocity.x, velocity.y, velocity.z,
	])


func rewind_restore(data: PackedFloat32Array) -> void:
	if data.size() < 7:
		return
	global_position = Vector3(data[0], data[1], data[2])
	rotation.y = data[3]
	velocity = Vector3(data[4], data[5], data[6])
