extends Node
## Tock's pocket watch. It records the whole world ~60 times a second and plays it back.

signal sand_changed(value: float, maximum: float)
signal rewind_started
signal rewind_stopped

const RATE := 60
const HISTORY_SECONDS := 12.0
const MAX_SAND := 9.0
const SAND_REGEN := 0.22
const REWIND_SPEED := 1.9

var sand := MAX_SAND
var max_sand := MAX_SAND
var rewinding := false
var frozen := false
var nodes: Array = []
var frames: Array = []

var _accum := 0.0
var _auto_frames := 0
var _bodies: Array = []
var _node_count := -1


func _ready() -> void:
	process_physics_priority = 1000


func register(node: Node) -> void:
	if nodes.has(node):
		return
	nodes.append(node)
	if node is RigidBody3D:
		_bodies.append(node)


func unregister(node: Node) -> void:
	nodes.erase(node)
	_bodies.erase(node)


func clear_history() -> void:
	frames.clear()
	_accum = 0.0
	_node_count = nodes.size()


func set_frozen(value: bool) -> void:
	frozen = value
	if value:
		stop_rewind()


func _physics_process(delta: float) -> void:
	if frozen:
		return
	if nodes.size() != _node_count:
		clear_history()
	if rewinding:
		_rewind_step(delta)
		return
	_accum += delta * RATE
	var steps := int(_accum)
	if steps > 0:
		_accum -= steps
		for i in steps:
			_record()
	if sand < max_sand:
		sand = minf(max_sand, sand + SAND_REGEN * delta)
		sand_changed.emit(sand, max_sand)


func add_sand(amount: float) -> void:
	max_sand += amount
	sand = max_sand
	sand_changed.emit(sand, max_sand)


func _record() -> void:
	var frame: Array = []
	for n in nodes:
		frame.append(n.rewind_capture())
	frames.append(frame)
	var limit := int(HISTORY_SECONDS * RATE)
	while frames.size() > limit:
		frames.pop_front()


func can_rewind() -> bool:
	return not rewinding and not frozen and sand > 0.04 and frames.size() > 3


func start_rewind() -> void:
	if not can_rewind():
		return
	rewinding = true
	_accum = 0.0
	_auto_frames = 0
	_set_bodies_frozen(true)
	rewind_started.emit()


func stop_rewind() -> void:
	if not rewinding:
		return
	rewinding = false
	_accum = 0.0
	_auto_frames = 0
	_set_bodies_frozen(false)
	rewind_stopped.emit()


func auto_rewind(seconds: float) -> bool:
	## Called when the boy dies: un-happen the last moment for him automatically.
	if frames.size() < 12 or sand < 0.35:
		return false
	start_rewind()
	if not rewinding:
		return false
	_auto_frames = int(minf(seconds, sand * 1.5) * RATE)
	return true


func _set_bodies_frozen(value: bool) -> void:
	for b in _bodies:
		if is_instance_valid(b):
			if value:
				b.freeze = true
			else:
				b.linear_velocity = Vector3.ZERO
				b.angular_velocity = Vector3.ZERO
				b.freeze = false


func _rewind_step(delta: float) -> void:
	sand -= delta
	if sand <= 0.0:
		sand = 0.0
		sand_changed.emit(sand, MAX_SAND)
		stop_rewind()
		return
	_accum += delta * RATE * REWIND_SPEED
	var steps := int(_accum)
	_accum -= steps
	for i in steps:
		if frames.size() <= 1:
			stop_rewind()
			break
		frames.pop_back()
		var frame: Array = frames[frames.size() - 1]
		for idx in nodes.size():
			if idx >= frame.size():
				break
			var n = nodes[idx]
			if is_instance_valid(n):
				n.rewind_restore(frame[idx])
		if _auto_frames > 0:
			_auto_frames -= 1
			if _auto_frames <= 0:
				stop_rewind()
				break
	sand_changed.emit(sand, MAX_SAND)
