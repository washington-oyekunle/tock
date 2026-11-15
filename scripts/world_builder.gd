extends Node3D
## Builds the clockmaker's courtyard, the tower and everything Tock can un-happen.

const TEX := "res://assets/library/village/"
const PROP := "res://assets/library/village/"

const HALF_W := 15.0
const Z_SOUTH := 16.0
const Z_FACADE := -16.0
const TERRACE_Y := 1.0
const PIT_Z0 := -12.0
const PIT_Z1 := -15.55
const STAIR_Z0 := 1.5
const STAIR_Z1 := -1.5

var cobble: StandardMaterial3D
var mortar: StandardMaterial3D
var step_stone: StandardMaterial3D
var wall_mat: StandardMaterial3D
var wood: StandardMaterial3D
var grass: StandardMaterial3D
var dirt: StandardMaterial3D
var slate: StandardMaterial3D
var brass: StandardMaterial3D
var glow: StandardMaterial3D
var clock_face: StandardMaterial3D
var iron: StandardMaterial3D
var dark_stone: StandardMaterial3D

var boulder: Node3D
var pendulum: Node3D
var bridge: AnimatableBody3D
var plate: Area3D
var pad: Area3D
var windlass_drum: Node3D
var checkpoints := [
	Vector3(0.0, 0.25, 12.5),
	Vector3(0.0, 1.2, -4.0),
	Vector3(0.0, 1.2, -17.4),
]

var _lights: Array = []
var _time := 0.0
var _windlass_spin := 0.0
var _windlass_target := 0.0


func _ready() -> void:
	_load_materials()
	_build_backdrop()
	_build_floors()
	_build_walls()
	_build_tower()
	_build_pit_and_bridge()
	_build_plate_and_crate()
	_build_boulder()
	_build_pendulum()
	_build_great_clock()
	_build_court_details()
	_build_balcony()
	_build_pad()
	_build_dressing()


func _process(delta: float) -> void:
	_time += delta
	if _windlass_spin < _windlass_target:
		_windlass_spin = minf(_windlass_spin + delta * 7.0, _windlass_target)
		if windlass_drum:
			windlass_drum.rotation.z = -_windlass_spin
	for i in _lights.size():
		var l: OmniLight3D = _lights[i]
		if is_instance_valid(l):
			l.light_energy = l.get_meta("base", 1.0) * (0.9 + sin(_time * (3.0 + i * 0.7) + i) * 0.06)


func _tex_mat(file: String, tile_m: float, tint := Color.WHITE) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(TEX + file)
	m.albedo_color = tint
	m.roughness = 0.94
	m.uv1_triplanar = true
	m.uv1_scale = Vector3(1.0 / tile_m, 1.0 / tile_m, 1.0 / tile_m)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return m


func _load_materials() -> void:
	cobble = _tex_mat("castle-village-scene_Image_3.jpg", 1.7, Color(1.04, 0.98, 0.9))
	mortar = StandardMaterial3D.new()
	mortar.albedo_color = Color(0.30, 0.26, 0.23)
	mortar.roughness = 1.0
	step_stone = StandardMaterial3D.new()
	step_stone.albedo_color = Color(0.66, 0.60, 0.53)
	step_stone.roughness = 0.95
	wall_mat = _tex_mat("castle-village-scene_Image_4.jpg", 2.1, Color(0.92, 0.88, 0.82))
	wood = _tex_mat("castle-village-scene_Image_13.jpg", 1.7)
	grass = _tex_mat("castle-village-scene_Image_1.jpg", 2.0)
	dirt = _tex_mat("castle-village-scene_Image_8.jpg", 2.8)
	slate = _tex_mat("castle-village-scene_Image_2.jpg", 2.2, Color(0.52, 0.55, 0.66))
	dark_stone = _tex_mat("castle-village-scene_Image_2.jpg", 3.0, Color(0.68, 0.66, 0.63))

	brass = StandardMaterial3D.new()
	brass.albedo_color = Color(0.93, 0.71, 0.32)
	brass.metallic = 0.9
	brass.roughness = 0.28
	brass.emission_enabled = true
	brass.emission = Color(1.0, 0.72, 0.32)
	brass.emission_energy_multiplier = 0.35

	glow = StandardMaterial3D.new()
	glow.albedo_color = Color(1.0, 0.95, 0.78)
	glow.emission_enabled = true
	glow.emission = Color(1.0, 0.84, 0.55)
	glow.emission_energy_multiplier = 2.6

	clock_face = StandardMaterial3D.new()
	clock_face.albedo_color = Color(0.95, 0.91, 0.81)
	clock_face.roughness = 0.65
	clock_face.emission_enabled = true
	clock_face.emission = Color(1.0, 0.85, 0.6)
	clock_face.emission_energy_multiplier = 0.5

	iron = StandardMaterial3D.new()
	iron.albedo_color = Color(0.16, 0.16, 0.19)
	iron.metallic = 0.7
	iron.roughness = 0.4


func _build_backdrop() -> void:
	var ground := StandardMaterial3D.new()
	ground.albedo_texture = load(TEX + "castle-village-scene_Image_8.jpg")
	ground.albedo_color = Color(0.72, 0.66, 0.56)
	ground.roughness = 1.0
	ground.uv1_triplanar = true
	ground.uv1_scale = Vector3(0.22, 0.22, 0.22)
	_box(Vector3(150.0, 0.7, 260.0), Vector3(HALF_W + 76.0, -0.9, 0.0), ground, false)
	_box(Vector3(150.0, 0.7, 260.0), Vector3(-HALF_W - 76.0, -0.9, 0.0), ground, false)
	_box(Vector3(260.0, 0.7, 130.0), Vector3(0.0, -0.9, Z_SOUTH + 66.0), ground, false)
	_box(Vector3(260.0, 0.7, 130.0), Vector3(0.0, -0.9, -26.0 - 66.0), ground, false)

	var hill_far := StandardMaterial3D.new()
	hill_far.albedo_color = Color(0.34, 0.38, 0.38)
	hill_far.roughness = 1.0
	var hill_near := StandardMaterial3D.new()
	hill_near.albedo_color = Color(0.30, 0.34, 0.26)
	hill_near.roughness = 1.0
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 12:
		var a := TAU * float(i) / 12.0 + rng.randf_range(-0.14, 0.14)
		var far := i % 2 == 0
		var dist := rng.randf_range(110.0, 165.0) if far else rng.randf_range(80.0, 110.0)
		var mi := MeshInstance3D.new()
		var sp := SphereMesh.new()
		sp.radius = 1.0
		sp.height = 2.0
		sp.radial_segments = 14
		sp.rings = 6
		mi.mesh = sp
		mi.material_override = hill_far if far else hill_near
		var sx := rng.randf_range(36.0, 68.0)
		var sy := rng.randf_range(14.0, 26.0)
		mi.scale = Vector3(sx, sy, sx * rng.randf_range(0.7, 1.1))
		mi.position = Vector3(cos(a) * dist, -8.0, sin(a) * dist)
		add_child(mi)

	var tree_near := StandardMaterial3D.new()
	tree_near.albedo_color = Color(0.17, 0.26, 0.15)
	tree_near.roughness = 1.0
	var tree_far := StandardMaterial3D.new()
	tree_far.albedo_color = Color(0.24, 0.32, 0.24)
	tree_far.roughness = 1.0
	var cone := CylinderMesh.new()
	cone.top_radius = 0.0
	cone.bottom_radius = 1.0
	cone.height = 4.2
	cone.radial_segments = 6
	cone.rings = 3
	for band in 2:
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_3D
		mm.mesh = cone
		mm.instance_count = 90
		for i in 90:
			var a := rng.randf() * TAU
			var d := rng.randf_range(25.0, 46.0) if band == 0 else rng.randf_range(46.0, 78.0)
			var s := rng.randf_range(1.0, 2.4) if band == 0 else rng.randf_range(1.6, 3.0)
			var tree_basis := Basis().scaled(Vector3(s, s, s)).rotated(Vector3.UP, rng.randf() * TAU)
			mm.set_instance_transform(i, Transform3D(tree_basis, Vector3(cos(a) * d, -0.55 + 2.1 * s - 0.3, sin(a) * d)))
		var mmi := MultiMeshInstance3D.new()
		mmi.multimesh = mm
		mmi.material_override = tree_near if band == 0 else tree_far
		add_child(mmi)


func _box(size: Vector3, pos: Vector3, mat: Material, collide := true, rot := Vector3.ZERO, parent: Node3D = null) -> MeshInstance3D:
	var host: Node3D = parent if parent else self
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	host.add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		body.position = pos
		body.rotation = rot
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		cs.shape = shape
		body.add_child(cs)
		host.add_child(body)
	return mi


func _cylinder(radius: float, height: float, pos: Vector3, mat: Material, rot := Vector3.ZERO, segments := 24, collide := false, parent: Node3D = null) -> MeshInstance3D:
	var host: Node3D = parent if parent else self
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = segments
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	host.add_child(mi)
	if collide:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		body.position = pos
		body.rotation = rot
		var cs := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
		cs.shape = shape
		body.add_child(cs)
		host.add_child(body)
	return mi


func _collider(size: Vector3, pos: Vector3) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = pos
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	cs.shape = shape
	body.add_child(cs)
	add_child(body)


func _light(pos: Vector3, energy: float, color := Color(1.0, 0.78, 0.5), range_m := 9.0) -> OmniLight3D:
	var l := OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = range_m
	l.omni_attenuation = 1.4
	l.shadow_enabled = false
	l.set_meta("base", energy)
	add_child(l)
	_lights.append(l)
	return l


func _build_floors() -> void:
	_box(Vector3(HALF_W * 2.0, 0.8, 15.0), Vector3(0, -0.48, 9.0), mortar, false)
	_collider(Vector3(HALF_W * 2.0, 1.0, 15.0), Vector3(0, -0.5, 9.0))
	_box(Vector3(HALF_W * 2.0, 0.8, 10.5), Vector3(0, 0.52, -6.75), mortar, false)
	_collider(Vector3(HALF_W * 2.0, 1.0, 10.5), Vector3(0, 0.5, -6.75))
	_slab_field(-14.75, 14.75, 1.55, 17.9, 0.0, 7)
	_slab_field(-14.75, 14.75, -11.85, -1.65, 1.0, 13)
	for i in 5:
		var h := 0.2 * float(i + 1)
		var z := STAIR_Z0 - 0.6 * float(i) - 0.3
		_box(Vector3(5.6, h, 0.62), Vector3(0, h * 0.5, z), step_stone)
	var stair_sides := [
		Vector3(-3.4, 0.85, 0.0), Vector3(3.4, 0.85, 0.0),
		Vector3(-3.4, 0.85, -1.0), Vector3(3.4, 0.85, -1.0),
	]
	for p in stair_sides:
		_box(Vector3(1.2, 1.7, 3.6), p, wall_mat)
	for side in [-1.0, 1.0]:
		_box(Vector3(11.6, 1.7, 3.4), Vector3(side * 9.4, 0.85, 0.0), wall_mat)
		_box(Vector3(11.6, 0.18, 3.4), Vector3(side * 9.4, 1.79, 0.0), grass, false)
	# terrace edge above the pit
	_box(Vector3(HALF_W * 2.0, 8.6, 0.7), Vector3(0, -3.2, PIT_Z0 - 0.35), wall_mat)
	_box(Vector3(HALF_W * 2.0, 0.5, 3.9), Vector3(0, -7.2, (PIT_Z0 + PIT_Z1) * 0.5), dirt, false)
	# landing in front of the tower doorway
	_box(Vector3(5.4, 1.0, 1.7), Vector3(0, 0.5, -16.35), wall_mat)


func _build_walls() -> void:
	for side in [-1.0, 1.0]:
		_box(Vector3(0.9, 7.2, 32.0), Vector3(side * (HALF_W + 0.45), 2.4, 0.0), wall_mat)
		for i in 9:
			var z := -14.0 + float(i) * 3.5
			_box(Vector3(0.9, 0.75, 1.0), Vector3(side * (HALF_W + 0.45), 6.35, z), wall_mat, false)
		for i in 5:
			var z := -12.0 + float(i) * 6.0
			_box(Vector3(0.7, 6.4, 1.1), Vector3(side * (HALF_W - 0.2), 2.1, z), wall_mat)
	_box(Vector3(HALF_W * 2.0 + 1.8, 7.2, 0.9), Vector3(0, 2.4, Z_SOUTH), wall_mat)
	for i in 9:
		_box(Vector3(1.0, 0.75, 0.9), Vector3(-13.0 + float(i) * 3.25, 6.35, Z_SOUTH), wall_mat, false)
	# south gateway the boy came through
	_box(Vector3(3.0, 5.6, 0.9), Vector3(-2.6, 2.4, Z_SOUTH - 0.02), wall_mat)
	_box(Vector3(3.0, 5.6, 0.9), Vector3(2.6, 2.4, Z_SOUTH - 0.02), wall_mat)
	_box(Vector3(3.2, 0.7, 0.95), Vector3(0, 5.05, Z_SOUTH - 0.02), wall_mat)
	for i in 9:
		var a := PI * float(i) / 8.0
		_box(Vector3(0.5, 0.5, 0.9), Vector3(cos(a) * 1.6, 4.75 + sin(a) * 1.1, Z_SOUTH - 0.02), dark_stone, false, Vector3(0, 0, a))
	_box(Vector3(3.2, 3.4, 0.25), Vector3(0, 1.7, Z_SOUTH - 0.35), wood)
	for side in [-1.0, 1.0]:
		_box(Vector3(10.0, 13.0, 0.9), Vector3(side * 10.0, -0.4, Z_FACADE), wall_mat)


func _build_tower() -> void:
	# facade
	_box(Vector3(3.0, 17.0, 0.9), Vector3(-3.5, 9.5, Z_FACADE - 0.45), wall_mat)
	_box(Vector3(3.0, 17.0, 0.9), Vector3(3.5, 9.5, Z_FACADE - 0.45), wall_mat)
	_box(Vector3(10.0, 12.0, 0.9), Vector3(0, 12.0, Z_FACADE - 0.45), wall_mat)
	for side in [-1.0, 1.0]:
		_box(Vector3(0.9, 17.0, 10.4), Vector3(side * 4.55, 9.5, -21.4), wall_mat)
	_box(Vector3(10.0, 17.0, 0.9), Vector3(0, 9.5, -26.0), wall_mat)
	_box(Vector3(10.0, 0.8, 10.0), Vector3(0, 0.52, -21.4), mortar, false)
	_collider(Vector3(10.0, 1.0, 10.0), Vector3(0, 0.5, -21.4))
	_slab_field(-3.95, 3.95, -25.2, -16.35, 1.0, 41)
	_box(Vector3(10.0, 0.5, 10.2), Vector3(0, 8.85, -21.4), dark_stone, false)
	# roof
	var roof := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.05
	cone.bottom_radius = 7.9
	cone.height = 6.4
	cone.radial_segments = 4
	roof.mesh = cone
	roof.material_override = slate
	roof.position = Vector3(0, 21.2, -21.4)
	roof.rotation.y = PI * 0.25
	add_child(roof)
	# doorway trim
	for side in [-1.0, 1.0]:
		_box(Vector3(0.45, 5.4, 0.45), Vector3(side * 2.2, 3.6, Z_FACADE + 0.12), dark_stone, false)
	_box(Vector3(4.9, 0.45, 0.45), Vector3(0, 6.25, Z_FACADE + 0.12), dark_stone, false)
	# the great clock face on the facade
	_build_clock_face(Vector3(0, 13.2, Z_FACADE - 0.02))
	# open door panels against the inner walls
	for side in [-1.0, 1.0]:
		_box(Vector3(0.2, 4.6, 1.9), Vector3(side * 2.2, 3.3, Z_FACADE - 1.15), wood)
	# balcony ring under the clock
	for side in [-1.0, 1.0]:
		_box(Vector3(1.1, 0.35, 0.9), Vector3(side * 2.9, 9.6, Z_FACADE + 0.35), dark_stone, false)
	_box(Vector3(6.2, 0.35, 0.9), Vector3(0, 9.6, Z_FACADE + 0.35), dark_stone, false)


func _build_clock_face(center: Vector3) -> void:
	var face := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 2.65
	disc.bottom_radius = 2.65
	disc.height = 0.18
	disc.radial_segments = 48
	face.mesh = disc
	face.material_override = clock_face
	face.position = center
	face.rotation.x = PI * 0.5
	add_child(face)

	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 2.6
	torus.outer_radius = 2.95
	torus.rings = 48
	torus.ring_segments = 12
	ring.mesh = torus
	ring.material_override = brass
	ring.position = center + Vector3(0, 0, 0.12)
	add_child(ring)

	for i in 12:
		var a := TAU * float(i) / 12.0
		var tick := _box(
			Vector3(0.16, 0.42, 0.1),
			center + Vector3(sin(a) * 2.2, cos(a) * 2.2, 0.16),
			brass, false, Vector3(0, 0, -a)
		)
		tick.name = "Tick%d" % i

	var hour_hand := Node3D.new()
	hour_hand.position = center + Vector3(0, 0, 0.2)
	add_child(hour_hand)
	_box(Vector3(0.26, 1.5, 0.08), Vector3(0, 0.68, 0), iron, false, Vector3.ZERO, hour_hand)
	hour_hand.rotation.z = -0.9

	var minute_hand := Node3D.new()
	minute_hand.position = center + Vector3(0, 0, 0.3)
	add_child(minute_hand)
	_box(Vector3(0.14, 2.1, 0.08), Vector3(0, 0.95, 0), iron, false, Vector3.ZERO, minute_hand)
	minute_hand.rotation.z = 2.1
	var cap := MeshInstance3D.new()
	var cap_mesh := SphereMesh.new()
	cap_mesh.radius = 0.22
	cap_mesh.height = 0.44
	cap.mesh = cap_mesh
	cap.material_override = brass
	cap.position = center + Vector3(0, 0, 0.34)
	add_child(cap)
	_light(center + Vector3(0, -1.0, 2.4), 2.4, Color(1.0, 0.8, 0.45), 16.0)


func _build_pit_and_bridge() -> void:
	bridge = AnimatableBody3D.new()
	bridge.set_script(load("res://scripts/bridge.gd"))
	bridge.name = "Drawbridge"
	bridge.collision_layer = 1
	bridge.collision_mask = 0
	bridge.position = Vector3(0, 0.75, (PIT_Z0 + PIT_Z1) * 0.5)
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(4.2, 0.5, 4.0)
	mi.mesh = mesh
	mi.material_override = dark_stone
	bridge.add_child(mi)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4.2, 0.5, 4.0)
	cs.shape = shape
	bridge.add_child(cs)
	for side in [-1.0, 1.0]:
		for i in 3:
			var post := MeshInstance3D.new()
			var pm := CylinderMesh.new()
			pm.top_radius = 0.09
			pm.bottom_radius = 0.11
			pm.height = 0.95
			pm.radial_segments = 8
			post.mesh = pm
			post.material_override = brass
			post.position = Vector3(side * 1.95, 0.7, -1.5 + float(i) * 1.5)
			bridge.add_child(post)
	add_child(bridge)
	# bridge housing on the far side
	_box(Vector3(5.4, 3.0, 0.8), Vector3(0, -2.2, PIT_Z1 - 0.4), wall_mat)
	for i in 4:
		_box(Vector3(1.4, 0.9, 1.2), Vector3(-6.0 + float(i) * 4.0, -6.6, -13.6), dark_stone, false, Vector3(0.1 * float(i), 0.4 * float(i), 0))


func _build_plate_and_crate() -> void:
	plate = Area3D.new()
	plate.set_script(load("res://scripts/plate.gd"))
	plate.name = "Plate"
	plate.position = Vector3(-8.0, TERRACE_Y + 0.28, -8.0)
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.9, 0.56, 1.9)
	cs.shape = shape
	plate.add_child(cs)
	var base := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(1.9, 0.1, 1.9)
	base.mesh = bm
	base.material_override = dark_stone
	base.position = Vector3(0, -0.25, 0)
	plate.add_child(base)
	var rim := MeshInstance3D.new()
	var rm := BoxMesh.new()
	rm.size = Vector3(1.45, 0.06, 1.45)
	rim.mesh = rm
	var rim_mat := StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.95, 0.74, 0.34)
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(1.0, 0.72, 0.28)
	rim_mat.emission_energy_multiplier = 0.35
	rim.material_override = rim_mat
	rim.position = Vector3(0, -0.21, 0)
	rim.name = "Rim"
	plate.add_child(rim)
	add_child(plate)

	var crate := RigidBody3D.new()
	crate.set_script(load("res://scripts/crate.gd"))
	crate.name = "Crate"
	crate.mass = 34.0
	crate.linear_damp = 0.9
	crate.angular_damp = 4.0
	var crate_phys := PhysicsMaterial.new()
	crate_phys.friction = 1.4
	crate_phys.bounce = 0.0
	crate.physics_material_override = crate_phys
	crate.collision_layer = 4
	crate.collision_mask = 1
	crate.position = Vector3(-10.6, TERRACE_Y + 0.5, -4.9)
	var crate_mesh := MeshInstance3D.new()
	var cm := BoxMesh.new()
	cm.size = Vector3(0.92, 0.92, 0.92)
	crate_mesh.mesh = cm
	crate_mesh.material_override = wood
	crate.add_child(crate_mesh)
	for i in 3:
		var band := MeshInstance3D.new()
		var bmesh := BoxMesh.new()
		bmesh.size = Vector3(0.97, 0.1, 0.97)
		band.mesh = bmesh
		var band_mat := StandardMaterial3D.new()
		band_mat.albedo_color = Color(0.32, 0.3, 0.3)
		band_mat.metallic = 0.8
		band_mat.roughness = 0.45
		band.material_override = band_mat
		band.position = Vector3(0, -0.32 + float(i) * 0.32, 0)
		crate.add_child(band)
	var crate_shape := CollisionShape3D.new()
	var crate_box := BoxShape3D.new()
	crate_box.size = Vector3(0.92, 0.92, 0.92)
	crate_shape.shape = crate_box
	crate.add_child(crate_shape)
	add_child(crate)


func _build_boulder() -> void:
	boulder = Node3D.new()
	boulder.set_script(load("res://scripts/boulder.gd"))
	boulder.name = "Boulder"
	var mesh_root := Node3D.new()
	mesh_root.name = "Mesh"
	boulder.add_child(mesh_root)
	var sphere := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.95
	sm.height = 1.9
	sm.radial_segments = 24
	sm.rings = 12
	sphere.mesh = sm
	sphere.material_override = dark_stone
	mesh_root.add_child(sphere)
	for i in 3:
		var band := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = 0.88
		tm.outer_radius = 1.0
		tm.rings = 24
		tm.ring_segments = 8
		band.mesh = tm
		band.material_override = brass
		band.rotation.x = PI * 0.5
		band.position = Vector3(0, 0.6 - 0.6 * float(i), 0)
		mesh_root.add_child(band)
	boulder.set("mesh", mesh_root)
	add_child(boulder)


func _build_pendulum() -> void:
	pendulum = Node3D.new()
	pendulum.set_script(load("res://scripts/pendulum.gd"))
	pendulum.name = "Pendulum"
	pendulum.position = Vector3(0, 8.35, -20.6)
	var rod := MeshInstance3D.new()
	var rm := CylinderMesh.new()
	rm.top_radius = 0.07
	rm.bottom_radius = 0.09
	rm.height = 6.2
	rm.radial_segments = 10
	rod.mesh = rm
	rod.material_override = brass
	rod.position = Vector3(0, -3.1, 0)
	pendulum.add_child(rod)
	var bob := Node3D.new()
	bob.position = Vector3(0, -6.2, 0)
	pendulum.add_child(bob)
	var bob_mesh := MeshInstance3D.new()
	var bm := SphereMesh.new()
	bm.radius = 0.86
	bm.height = 1.72
	bm.radial_segments = 24
	bm.rings = 12
	bob_mesh.mesh = bm
	var bob_mat := StandardMaterial3D.new()
	bob_mat.albedo_color = Color(0.28, 0.28, 0.32)
	bob_mat.metallic = 0.9
	bob_mat.roughness = 0.32
	bob_mesh.material_override = bob_mat
	bob.add_child(bob_mesh)
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.82
	tm.outer_radius = 0.95
	tm.rings = 28
	tm.ring_segments = 10
	ring.mesh = tm
	ring.material_override = brass
	bob.add_child(ring)
	for i in 6:
		var spike := MeshInstance3D.new()
		var sp := CylinderMesh.new()
		sp.top_radius = 0.0
		sp.bottom_radius = 0.1
		sp.height = 0.55
		sp.radial_segments = 6
		spike.mesh = sp
		spike.material_override = brass
		var a := TAU * float(i) / 6.0
		spike.position = Vector3(cos(a) * 0.95, 0, sin(a) * 0.95)
		spike.rotation = Vector3(0, -a, PI * 0.5)
		bob.add_child(spike)
	pendulum.set("bob", bob)
	add_child(pendulum)
	# axle mount
	_box(Vector3(1.4, 0.6, 1.4), Vector3(0, 8.6, -20.6), brass, false)
	_light(Vector3(0, 7.0, -20.6), 1.6, Color(1.0, 0.78, 0.45), 12.0)


func _build_great_clock() -> void:
	var back := Vector3(0, 3.3, -25.4)
	var face := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 2.45
	disc.bottom_radius = 2.45
	disc.height = 0.2
	disc.radial_segments = 48
	face.mesh = disc
	face.material_override = clock_face
	face.position = back
	face.rotation.x = PI * 0.5
	add_child(face)
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 2.42
	torus.outer_radius = 2.78
	torus.rings = 48
	torus.ring_segments = 12
	ring.mesh = torus
	ring.material_override = brass
	ring.position = back + Vector3(0, 0, 0.16)
	add_child(ring)
	for i in 16:
		var a := TAU * float(i) / 16.0
		var tooth := _box(Vector3(0.34, 0.34, 0.16), back + Vector3(cos(a) * 2.92, sin(a) * 2.92, 0.1), brass, false, Vector3(0, 0, a))
		tooth.name = "Tooth%d" % i
	_box(Vector3(0.22, 2.2, 0.12), back + Vector3(0, 0.9, 0.24), iron, false)
	_box(Vector3(0.9, 0.14, 0.12), back + Vector3(0.2, 0.2, 0.26), iron, false, Vector3(0, 0, 0.6))
	_light(back + Vector3(0, 0, 2.4), 3.0, Color(1.0, 0.85, 0.6), 12.0)

	var clock := _make_interactable(back + Vector3(0, -0.8, 1.5), 2.3, "Wind the great clock", "clock", true)
	clock.name = "ClockHeart"
	_light(back + Vector3(0, -0.6, 1.2), 1.6, Color(1.0, 0.8, 0.5), 7.0)


func _prop(file: String, pos: Vector3, rot_y := 0.0, s := 1.0) -> Node3D:
	var packed: PackedScene = load(PROP + file)
	if packed == null:
		return null
	var inst := packed.instantiate()
	inst.position = pos
	inst.rotation.y = rot_y
	inst.scale = Vector3.ONE * s
	add_child(inst)
	return inst


func _build_court_details() -> void:
	# a giant brass clock inlaid in the plaza
	var inlay := MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 3.5
	ring.outer_radius = 3.68
	ring.rings = 48
	ring.ring_segments = 8
	inlay.mesh = ring
	inlay.material_override = brass
	inlay.position = Vector3(0, 0.03, 8.4)
	inlay.scale = Vector3(1, 1, 1)
	add_child(inlay)
	for i in 12:
		var a := TAU * float(i) / 12.0
		_box(Vector3(0.14, 0.03, 0.62), Vector3(sin(a) * 3.0, 0.03, 8.4 + cos(a) * 3.0), brass, false, Vector3(0, a, 0))
	var hub := MeshInstance3D.new()
	var hub_mesh := CylinderMesh.new()
	hub_mesh.top_radius = 0.5
	hub_mesh.bottom_radius = 0.5
	hub_mesh.height = 0.04
	hub_mesh.radial_segments = 24
	hub.mesh = hub_mesh
	hub.material_override = brass
	hub.position = Vector3(0, 0.03, 8.4)
	add_child(hub)
	_light(Vector3(0, 1.4, 8.4), 0.9, Color(1.0, 0.7, 0.4), 7.0)
	# wall torches
	for side in [-1.0, 1.0]:
		for z in [-8.0, 0.0, 8.0, 14.0]:
			var x: float = side * 14.75
			_box(Vector3(0.5, 0.1, 0.1), Vector3(x, 3.25, z), dark_stone, false)
			_cylinder(0.17, 0.26, Vector3(x - side * 0.2, 3.42, z), dark_stone, Vector3.ZERO, 10)
			var flame := MeshInstance3D.new()
			var fm := SphereMesh.new()
			fm.radius = 0.14
			fm.height = 0.34
			fm.radial_segments = 8
			fm.rings = 6
			flame.mesh = fm
			flame.material_override = glow
			flame.position = Vector3(x - side * 0.2, 3.66, z)
			add_child(flame)
			_light(Vector3(x - side * 0.6, 3.7, z), 1.5, Color(1.0, 0.66, 0.34), 9.0)


func _build_dressing() -> void:
	# courtyard props
	_prop("stall-cart-empty.glb", Vector3(-11.6, 0.0, 8.6), 0.5)
	_prop("cart.glb", Vector3(10.6, 0.0, 6.2), -1.1)
	_prop("bench.glb", Vector3(12.4, 0.0, 12.4), -0.6)
	_prop("anvil.glb", Vector3(-13.2, 0.0, 13.4), 0.9)
	_prop("barrels.glb", Vector3(-13.4, 0.0, 4.0), 0.3)
	_prop("barrel.glb", Vector3(12.9, 0.0, 9.4), 0.0)
	_prop("barrel.glb", Vector3(-12.6, 0.0, 11.2), 1.1)
	_prop("chest-closed.glb", Vector3(12.2, 0.0, 14.4), 0.4)
	# terrace props
	_prop("bench.glb", Vector3(-12.6, TERRACE_Y, -6.4), 1.5)
	_prop("barrel.glb", Vector3(12.8, TERRACE_Y, -6.0), 0.2)
	_prop("candle-stick-stand.glb", Vector3(-3.4, TERRACE_Y, -10.6), 0.0)
	# tower hall
	_prop("candle-stick-stand.glb", Vector3(-3.4, TERRACE_Y, -18.2), 0.0)
	_prop("candle-stick-stand.glb", Vector3(3.4, TERRACE_Y, -18.2), 0.0)
	_prop("chest-closed.glb", Vector3(-3.2, TERRACE_Y, -24.6), 0.7)
	_light(Vector3(-3.4, 2.4, -18.2), 1.5, Color(1.0, 0.76, 0.45), 8.0)
	_light(Vector3(3.4, 2.4, -18.2), 1.5, Color(1.0, 0.76, 0.45), 8.0)
	_light(Vector3(-3.4, 2.4, -10.6), 1.2, Color(1.0, 0.76, 0.45), 7.0)
	# banners on the courtyard walls
	for side in [-1.0, 1.0]:
		for z in [6.0, -6.0]:
			var banner := _prop("banner-1.glb", Vector3(side * (HALF_W - 0.35), 4.9, z), -side * PI * 0.5, 1.25)
			if banner:
				banner.rotation.y = side * PI * 0.5
	# stone skirting along the wall feet
	for side in [-1.0, 1.0]:
		_box(Vector3(0.45, 0.65, 14.3), Vector3(side * 14.73, 0.32, 8.6), dark_stone)
		_box(Vector3(0.45, 0.65, 10.2), Vector3(side * 14.73, 1.32, -6.8), dark_stone)
	# stone bollards flanking the stairs
	for side in [-1.0, 1.0]:
		for i in 2:
			_cylinder(0.22, 1.1, Vector3(side * 3.0, 0.55, STAIR_Z0 - 0.4 - float(i) * 1.1), dark_stone, Vector3.ZERO, 10, true)
	# rubble and moss in the pit
	for i in 6:
		var p := Vector3(-11.0 + float(i) * 4.4, -6.6, -13.9 + sin(float(i)) * 0.6)
		_box(Vector3(1.2, 0.9, 1.4), p, dark_stone, false, Vector3(0.2 * float(i), 0.7 * float(i), 0.1))


func _slab_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(TEX + "castle-village-scene_Image_3.jpg")
	m.vertex_color_use_as_albedo = true
	m.roughness = 0.92
	m.metallic_specular = 0.4
	m.uv1_triplanar = true
	m.uv1_scale = Vector3(0.8, 0.8, 0.8)
	return m


func _slab_field(x0: float, x1: float, z0: float, z1: float, y: float, seed_value: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var step := 1.14
	var nx := maxi(1, int(round((x1 - x0) / step)))
	var nz := maxi(1, int(round((z1 - z0) / step)))
	var cell_x := (x1 - x0) / float(nx)
	var cell_z := (z1 - z0) / float(nz)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	var box := BoxMesh.new()
	box.size = Vector3(1.0, 0.14, 1.0)
	mm.mesh = box
	mm.instance_count = nx * nz
	var idx := 0
	for iz in nz:
		for ix in nx:
			var px := x0 + cell_x * (float(ix) + 0.5) + rng.randf_range(-0.02, 0.02)
			var pz := z0 + cell_z * (float(iz) + 0.5) + rng.randf_range(-0.02, 0.02)
			var rot := rng.randf_range(-0.035, 0.035)
			var sx := cell_x - 0.07
			var sz := cell_z - 0.07
			var jitter := rng.randf_range(-0.012, 0.006)
			mm.set_instance_transform(idx, Transform3D(
				Basis(Vector3.UP, rot).scaled(Vector3(sx, 1.0, sz)),
				Vector3(px, y - 0.07 + jitter, pz)
			))
			var tone := 0.70 + rng.randf_range(-0.07, 0.09)
			mm.set_instance_color(idx, Color(tone * 1.05, tone * 0.98, tone * 0.87))
			idx += 1
	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = _slab_material()
	add_child(mmi)


func _make_interactable(pos: Vector3, radius: float, prompt: String, kind: String, one_shot: bool) -> Area3D:
	var a := Area3D.new()
	a.set_script(load("res://scripts/interactable.gd"))
	a.position = pos
	var cs := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = radius
	cs.shape = shape
	a.add_child(cs)
	a.set("prompt", prompt)
	a.set("kind", kind)
	a.set("one_shot", one_shot)
	var marker := Node3D.new()
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.16, 0.16, 0.16)
	mi.mesh = bm
	mi.material_override = brass
	mi.rotation.z = PI * 0.25
	marker.add_child(mi)
	marker.position = Vector3(0, 1.35, 0)
	a.add_child(marker)
	a.set("marker", marker)
	add_child(a)
	return a


func _build_balcony() -> void:
	var y := 5.62
	_box(Vector3(2.7, 0.26, 8.4), Vector3(13.3, y, 9.5), wood)
	_box(Vector3(0.34, 0.34, 8.4), Vector3(12.02, y - 0.3, 9.5), dark_stone, false)
	for i in 5:
		var z := 5.7 + float(i) * 1.9
		_box(Vector3(0.16, 1.0, 0.16), Vector3(12.08, y + 0.62, z), wood, false)
	_box(Vector3(0.18, 0.14, 8.1), Vector3(12.08, y + 1.1, 9.5), wood, false)
	for z in [5.55, 13.45]:
		_box(Vector3(2.6, 0.14, 0.18), Vector3(13.35, y + 1.1, z), wood, false)
		_box(Vector3(0.16, 1.0, 0.16), Vector3(14.4, y + 0.62, z), wood, false)
	for i in 4:
		_box(Vector3(0.55, 1.6, 0.55), Vector3(14.5, y - 1.0, 6.4 + float(i) * 2.1), dark_stone, false)
	_light(Vector3(13.0, y + 1.9, 9.5), 1.3, Color(1.0, 0.72, 0.42), 7.0)
	_build_windlass(Vector3(13.35, y + 0.13, 11.5))
	_build_hourglass(Vector3(13.35, y + 0.13, 7.3))


func _build_windlass(pos: Vector3) -> void:
	_box(Vector3(0.3, 1.1, 0.3), pos + Vector3(0, 0.55, -0.8), wood)
	_box(Vector3(0.3, 1.1, 0.3), pos + Vector3(0, 0.55, 0.8), wood)
	windlass_drum = Node3D.new()
	windlass_drum.position = pos + Vector3(0, 1.12, 0)
	var drum := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.3
	cyl.bottom_radius = 0.3
	cyl.height = 1.55
	cyl.radial_segments = 16
	drum.mesh = cyl
	drum.material_override = wood
	drum.rotation.x = PI * 0.5
	windlass_drum.add_child(drum)
	var arm := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.1, 0.72, 0.1)
	arm.mesh = bm
	arm.material_override = brass
	arm.position = Vector3(0.0, 0.0, 0.88)
	windlass_drum.add_child(arm)
	add_child(windlass_drum)
	var it := _make_interactable(pos + Vector3(0, 1.0, 0), 1.8, "Turn the windlass", "windlass", false)
	it.name = "Windlass"


func spin_windlass() -> void:
	_windlass_target = _windlass_spin + TAU * 1.4


func _build_hourglass(pos: Vector3) -> void:
	_box(Vector3(0.7, 1.0, 0.7), pos + Vector3(0, 0.5, 0), dark_stone)
	var it := _make_interactable(pos + Vector3(0, 1.0, 0), 1.6, "Pocket the sand", "hourglass", true)
	it.name = "Hourglass"
	var top := MeshInstance3D.new()
	var tm := CylinderMesh.new()
	tm.top_radius = 0.3
	tm.bottom_radius = 0.02
	tm.height = 0.44
	tm.radial_segments = 12
	top.mesh = tm
	top.material_override = glow
	top.position = Vector3(0, 0.24, 0)
	it.add_child(top)
	var lower := MeshInstance3D.new()
	var bm2 := CylinderMesh.new()
	bm2.top_radius = 0.02
	bm2.bottom_radius = 0.26
	bm2.height = 0.38
	bm2.radial_segments = 12
	lower.mesh = bm2
	lower.material_override = glow
	lower.position = Vector3(0, -0.16, 0)
	it.add_child(lower)
	var frame := MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 0.26
	ring.outer_radius = 0.34
	ring.rings = 20
	ring.ring_segments = 6
	frame.mesh = ring
	frame.material_override = brass
	frame.rotation.x = PI * 0.5
	it.add_child(frame)
	_light(pos + Vector3(0, 1.3, 0), 1.1, Color(1.0, 0.82, 0.5), 5.0)


func _build_pad() -> void:
	var pos := Vector3(9.2, 0.0, 9.5)
	var target := Vector3(12.7, 6.35, 9.5)
	pad = Area3D.new()
	pad.set_script(load("res://scripts/spring_pad.gd"))
	pad.name = "SpringPad"
	pad.position = pos
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.8, 0.7, 1.8)
	cs.shape = shape
	cs.position = Vector3(0, 0.35, 0)
	pad.add_child(cs)
	var vis := Node3D.new()
	pad.add_child(vis)
	for i in 3:
		var ring := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = 0.74 - float(i) * 0.21
		tm.outer_radius = 0.8 - float(i) * 0.21
		tm.rings = 28
		tm.ring_segments = 6
		ring.mesh = tm
		ring.material_override = brass
		ring.position.y = 0.06
		vis.add_child(ring)
	var core := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.3
	cm.bottom_radius = 0.34
	cm.height = 0.12
	cm.radial_segments = 18
	core.mesh = cm
	core.material_override = glow
	core.position.y = 0.05
	vis.add_child(core)
	pad.set("visual", vis)
	var d := target - pos
	var flat := Vector3(d.x, 0.0, d.z)
	var hspeed := 3.9
	var t := maxf(flat.length() / hspeed, 0.35)
	var vy := (d.y + 0.5 * 19.0 * t * t) / t
	pad.set("launch_velocity", flat.normalized() * hspeed + Vector3(0, vy, 0))
	add_child(pad)
	_light(pos + Vector3(0, 1.1, 0), 1.1, Color(1.0, 0.75, 0.4), 6.0)
