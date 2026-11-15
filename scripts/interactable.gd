extends Area3D
## Something Tock can use with E.

signal used(source)

var prompt := "Use"
var enabled := true
var one_shot := false
var kind := "generic"
var marker: Node3D
var _t := 0.0


func _ready() -> void:
	add_to_group("interactable")
	collision_layer = 8
	collision_mask = 2
	monitoring = true
	set_process(true)


func _process(delta: float) -> void:
	_t += delta
	if marker and is_instance_valid(marker):
		marker.visible = enabled
		marker.position.y = 1.35 + sin(_t * 2.4) * 0.08
		marker.rotation.y += delta * 1.6


func use(_player) -> void:
	if not enabled:
		return
	if one_shot:
		enabled = false
	used.emit(self)


func consume() -> void:
	visible = false
	monitorable = false
	monitoring = false
	enabled = false
