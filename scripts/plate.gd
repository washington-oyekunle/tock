extends Area3D
## Stone pressure plate. Whatever weighs it holds the drawbridge up.

signal pressed_changed(value: bool)

var pressed := false
var _rim: MeshInstance3D
var _rim_mat: StandardMaterial3D


func _ready() -> void:
	collision_layer = 0
	collision_mask = 4
	monitoring = true
	_rim = get_node_or_null("Rim")
	if _rim and _rim.material_override is StandardMaterial3D:
		_rim_mat = _rim.material_override


func _physics_process(_delta: float) -> void:
	var now := not get_overlapping_bodies().is_empty()
	if now != pressed:
		pressed = now
		pressed_changed.emit(pressed)


func set_lit(value: bool) -> void:
	if _rim_mat:
		_rim_mat.emission_energy_multiplier = 3.2 if value else 0.35
