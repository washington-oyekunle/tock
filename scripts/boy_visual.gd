extends Node3D
## A small hand-built boy: linen shirt, suspenders, patched shorts and a brass pocket watch.

const SKIN := Color(0.93, 0.74, 0.58)
const SHIRT := Color(0.94, 0.89, 0.77)
const SHORTS := Color(0.23, 0.30, 0.44)
const LEATHER := Color(0.42, 0.27, 0.17)
const HAIR := Color(0.23, 0.14, 0.09)
const BRASS := Color(0.95, 0.72, 0.30)

var _body: Node3D
var _head: Node3D
var _arm_l: Node3D
var _arm_r: Node3D
var _fore_l: Node3D
var _fore_r: Node3D
var _leg_l: Node3D
var _leg_r: Node3D
var _shin_l: Node3D
var _shin_r: Node3D
var _watch_mat: StandardMaterial3D
var _watch: Node3D

var _phase := 0.0
var _t := 0.0
var _speed := 0.0
var _grounded := true
var _vy := 0.0


func _ready() -> void:
	var skin := _mat(SKIN, 0.9)
	var shirt := _mat(SHIRT, 0.95)
	var shorts := _mat(SHORTS, 0.9)
	var leather := _mat(LEATHER, 0.75)
	var hair := _mat(HAIR, 0.85)
	var eye := _mat(Color(0.09, 0.07, 0.06), 0.4)
	_watch_mat = _mat(BRASS, 0.3, 0.85, 1.6)

	_body = Node3D.new()
	_body.position = Vector3(0, 0.62, 0)
	add_child(_body)

	var torso := CylinderMesh.new()
	torso.top_radius = 0.145
	torso.bottom_radius = 0.185
	torso.height = 0.42
	torso.radial_segments = 16
	_add_mesh(_body, torso, shirt, Vector3(0, 0.21, 0))

	var shorts_mesh := CylinderMesh.new()
	shorts_mesh.top_radius = 0.19
	shorts_mesh.bottom_radius = 0.175
	shorts_mesh.height = 0.19
	shorts_mesh.radial_segments = 16
	_add_mesh(_body, shorts_mesh, shorts, Vector3(0, -0.02, 0))

	var strap := BoxMesh.new()
	strap.size = Vector3(0.035, 0.36, 0.02)
	_add_mesh(_body, strap, leather, Vector3(-0.075, 0.24, -0.152))
	_add_mesh(_body, strap, leather, Vector3(0.075, 0.24, -0.152))

	var collar := CylinderMesh.new()
	collar.top_radius = 0.095
	collar.bottom_radius = 0.135
	collar.height = 0.07
	collar.radial_segments = 16
	_add_mesh(_body, collar, shirt, Vector3(0, 0.435, 0))

	var scarf := TorusMesh.new()
	scarf.inner_radius = 0.1
	scarf.outer_radius = 0.15
	scarf.rings = 16
	scarf.ring_segments = 6
	_add_mesh(_body, scarf, _mat(Color(0.70, 0.21, 0.17), 0.85), Vector3(0, 0.42, 0))
	var scarf_tail := BoxMesh.new()
	scarf_tail.size = Vector3(0.09, 0.24, 0.04)
	var tail := _add_mesh(_body, scarf_tail, _mat(Color(0.62, 0.18, 0.15), 0.85), Vector3(0.03, 0.29, 0.19))
	tail.rotation.x = 0.28

	var cord := BoxMesh.new()
	cord.size = Vector3(0.012, 0.22, 0.012)
	_add_mesh(_body, cord, leather, Vector3(0, 0.31, -0.158))

	_watch = Node3D.new()
	_watch.position = Vector3(0, 0.15, -0.168)
	_body.add_child(_watch)
	var watch_mesh := CylinderMesh.new()
	watch_mesh.top_radius = 0.052
	watch_mesh.bottom_radius = 0.052
	watch_mesh.height = 0.026
	watch_mesh.radial_segments = 16
	var w := _add_mesh(_watch, watch_mesh, _watch_mat, Vector3.ZERO)
	w.rotation.x = PI * 0.5
	var watch_face := CylinderMesh.new()
	watch_face.top_radius = 0.04
	watch_face.bottom_radius = 0.04
	watch_face.height = 0.03
	watch_face.radial_segments = 16
	var wf := _add_mesh(_watch, watch_face, _mat(Color(1.0, 0.93, 0.7), 0.5, 0.0, 2.4), Vector3(0, 0, -0.002))
	wf.rotation.x = PI * 0.5

	_head = Node3D.new()
	_head.position = Vector3(0, 0.44, 0)
	_body.add_child(_head)

	var skull := SphereMesh.new()
	skull.radius = 0.155
	skull.height = 0.31
	skull.radial_segments = 24
	skull.rings = 12
	_add_mesh(_head, skull, skin, Vector3(0, 0.15, 0))

	var hair_mesh := SphereMesh.new()
	hair_mesh.radius = 0.168
	hair_mesh.height = 0.27
	hair_mesh.radial_segments = 20
	hair_mesh.rings = 10
	_add_mesh(_head, hair_mesh, hair, Vector3(0, 0.18, 0.012))

	var fringe := BoxMesh.new()
	fringe.size = Vector3(0.26, 0.07, 0.10)
	_add_mesh(_head, fringe, hair, Vector3(0, 0.255, -0.105))

	for side in [-1.0, 1.0]:
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.024
		eye_mesh.height = 0.048
		eye_mesh.radial_segments = 10
		eye_mesh.rings = 6
		_add_mesh(_head, eye_mesh, eye, Vector3(0.058 * side, 0.15, -0.142))

	var nose := SphereMesh.new()
	nose.radius = 0.026
	nose.height = 0.052
	_add_mesh(_head, nose, skin, Vector3(0, 0.115, -0.155))

	_arm_l = _limb(_body, Vector3(-0.195, 0.34, 0), skin, shirt)
	_arm_r = _limb(_body, Vector3(0.195, 0.34, 0), skin, shirt)
	_fore_l = _forearm(_arm_l, -0.24, skin)
	_fore_r = _forearm(_arm_r, -0.24, skin)
	_leg_l = _leg(_body, Vector3(-0.085, 0.0, 0), skin, shorts)
	_leg_r = _leg(_body, Vector3(0.085, 0.0, 0), skin, shorts)
	_shin_l = _shin(_leg_l, -0.28, skin)
	_shin_r = _shin(_leg_r, -0.28, skin)


func _mat(col: Color, rough := 0.85, metal := 0.0, emit := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = rough
	m.metallic = metal
	if emit > 0.0:
		m.emission_enabled = true
		m.emission = col
		m.emission_energy_multiplier = emit
	return m


func _add_mesh(parent: Node3D, mesh: Mesh, mat: Material, pos: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	return mi


func _limb(parent: Node3D, at: Vector3, skin: Material, sleeve: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = at
	parent.add_child(pivot)
	var upper := CapsuleMesh.new()
	upper.radius = 0.048
	upper.height = 0.27
	upper.radial_segments = 10
	upper.rings = 4
	var mi := _add_mesh(pivot, upper, sleeve, Vector3(0, -0.135, 0))
	mi.name = "Sleeve"
	var cuff := CapsuleMesh.new()
	cuff.radius = 0.044
	cuff.height = 0.16
	cuff.radial_segments = 10
	cuff.rings = 4
	_add_mesh(pivot, cuff, skin, Vector3(0, -0.22, 0))
	return pivot


func _forearm(pivot: Node3D, y: float, skin: Material) -> Node3D:
	var joint := Node3D.new()
	joint.position = Vector3(0, y, 0)
	pivot.add_child(joint)
	var fore := CapsuleMesh.new()
	fore.radius = 0.04
	fore.height = 0.22
	fore.radial_segments = 10
	fore.rings = 4
	_add_mesh(joint, fore, skin, Vector3(0, -0.1, 0))
	var hand := SphereMesh.new()
	hand.radius = 0.05
	hand.height = 0.1
	hand.radial_segments = 10
	hand.rings = 6
	_add_mesh(joint, hand, skin, Vector3(0, -0.23, 0))
	return joint


func _leg(parent: Node3D, at: Vector3, skin: Material, trouser: Material) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = at
	parent.add_child(pivot)
	var thigh := CapsuleMesh.new()
	thigh.radius = 0.063
	thigh.height = 0.30
	thigh.radial_segments = 10
	thigh.rings = 4
	_add_mesh(pivot, thigh, trouser, Vector3(0, -0.13, 0))
	var shin_skin := CapsuleMesh.new()
	shin_skin.radius = 0.052
	shin_skin.height = 0.18
	shin_skin.radial_segments = 10
	shin_skin.rings = 4
	_add_mesh(pivot, shin_skin, skin, Vector3(0, -0.24, 0))
	return pivot


func _shin(pivot: Node3D, y: float, skin: Material) -> Node3D:
	var joint := Node3D.new()
	joint.position = Vector3(0, y, 0)
	pivot.add_child(joint)
	var shin := CapsuleMesh.new()
	shin.radius = 0.048
	shin.height = 0.24
	shin.radial_segments = 10
	shin.rings = 4
	_add_mesh(joint, shin, skin, Vector3(0, -0.12, 0))
	var foot := BoxMesh.new()
	foot.size = Vector3(0.105, 0.07, 0.20)
	_add_mesh(joint, foot, _mat(SKIN.darkened(0.12), 0.9), Vector3(0, -0.255, -0.045))
	return joint


func set_state(speed: float, grounded: bool, vy: float) -> void:
	_speed = clampf(speed / 4.6, 0.0, 1.0)
	_grounded = grounded
	_vy = vy


func _process(delta: float) -> void:
	_t += delta
	var rewinding: bool = TimeControl.rewinding
	if rewinding:
		_phase -= delta * 13.0
	elif _grounded:
		_phase += delta * (1.4 + _speed * 9.5)
	else:
		_phase += delta * 2.0

	var k := 1.0 - exp(-16.0 * delta)
	var swing: float = sin(_phase) * 0.95 * _speed
	var leg_l := 0.0
	var leg_r := 0.0
	var shin_l := 0.0
	var shin_r := 0.0
	var arm_l := 0.08
	var arm_r := 0.08
	var fore_l := -0.25
	var fore_r := -0.25
	var arm_l_z := -0.10
	var arm_r_z := 0.10
	var lean := -0.06 - 0.13 * _speed
	var bob := 0.0

	if rewinding:
		leg_l = 0.45
		leg_r = -0.35
		shin_l = -0.55
		shin_r = -0.25
		arm_l = -0.5
		arm_r = -0.5
		fore_l = -1.4
		fore_r = -1.4
		arm_l_z = -0.9
		arm_r_z = 0.9
		lean = 0.18
		bob = 0.03 + sin(_t * 40.0) * 0.006
	elif not _grounded:
		leg_l = 0.55
		leg_r = 0.20
		shin_l = -0.85
		shin_r = -0.45
		arm_l = -0.75
		arm_r = -0.75
		fore_l = -0.6
		fore_r = -0.6
		arm_l_z = -0.45
		arm_r_z = 0.45
		lean = -0.10
		bob = 0.0
	else:
		leg_l = swing
		leg_r = -swing
		shin_l = -maxf(0.0, sin(_phase)) * 0.95 * _speed - 0.05
		shin_r = -maxf(0.0, -sin(_phase)) * 0.95 * _speed - 0.05
		arm_l = -swing * 0.75 + 0.04
		arm_r = swing * 0.75 + 0.04
		fore_l = -0.30 - maxf(0.0, sin(_phase)) * 0.35 * _speed
		fore_r = -0.30 - maxf(0.0, -sin(_phase)) * 0.35 * _speed
		bob = absf(sin(_phase)) * 0.035 * _speed + sin(_t * 2.1) * 0.006 * (1.0 - _speed)

	_leg_l.rotation.x = lerpf(_leg_l.rotation.x, leg_l, k)
	_leg_r.rotation.x = lerpf(_leg_r.rotation.x, leg_r, k)
	_shin_l.rotation.x = lerpf(_shin_l.rotation.x, shin_l, k)
	_shin_r.rotation.x = lerpf(_shin_r.rotation.x, shin_r, k)
	_arm_l.rotation.x = lerpf(_arm_l.rotation.x, arm_l, k)
	_arm_r.rotation.x = lerpf(_arm_r.rotation.x, arm_r, k)
	_arm_l.rotation.z = lerpf(_arm_l.rotation.z, arm_l_z, k)
	_arm_r.rotation.z = lerpf(_arm_r.rotation.z, arm_r_z, k)
	_fore_l.rotation.x = lerpf(_fore_l.rotation.x, fore_l, k)
	_fore_r.rotation.x = lerpf(_fore_r.rotation.x, fore_r, k)
	_body.rotation.x = lerpf(_body.rotation.x, lean, k * 0.6)
	_body.position.y = lerpf(_body.position.y, 0.62 + bob, k)
	_body.rotation.z = sin(_phase) * 0.035 * _speed
	_head.rotation.y = sin(_t * 0.7) * 0.12 * (1.0 - _speed)
	_watch.rotation.z = sin(_t * 2.6) * 0.14
	_watch_mat.emission_energy_multiplier = lerpf(_watch_mat.emission_energy_multiplier, 4.0 if rewinding else 1.4, k)
