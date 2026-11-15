extends Node3D
## Tock: a boy who can un-happen the world, in a courtyard that keeps happening.

var world
var player
var cam
var hud
var sfx
var music: AudioStreamPlayer
var _env: Environment

var state := "intro"
var checkpoint := 0

var _objective := ""
var _invulnerable := 0.0
var _respawn_timer := 0.0
var _auto_dying := false
var _zone := -1
var _intro_clock := 0.0
var _interact_was := false


func _ready() -> void:
	_setup_environment()

	world = load("res://scripts/world_builder.gd").new()
	world.name = "World"
	add_child(world)

	player = load("res://scripts/player.gd").new()
	player.name = "Tock"
	player.position = world.checkpoints[0]
	add_child(player)

	cam = load("res://scripts/camera_rig.gd").new()
	cam.name = "CameraRig"
	cam.target = player
	cam.yaw = 0.0
	add_child(cam)
	player.camera_rig = cam

	hud = load("res://scripts/hud.gd").new()
	hud.name = "HUD"
	add_child(hud)

	sfx = load("res://scripts/sfx.gd").new()
	sfx.name = "Sfx"
	add_child(sfx)

	music = AudioStreamPlayer.new()
	var track: AudioStream = load("res://library/sounds/game-music/Apple Cider.mp3")
	if track:
		if track is AudioStreamMP3:
			track.loop = true
		music.stream = track
		music.volume_db = -21.0
		add_child(music)
		music.play()

	TimeControl.sand_changed.connect(hud.set_sand)
	TimeControl.rewind_started.connect(_on_rewind_started)
	TimeControl.rewind_stopped.connect(_on_rewind_stopped)
	world.plate.pressed_changed.connect(_on_plate_pressed)
	world.pad.launched.connect(_on_pad_launched)
	for node in get_tree().get_nodes_in_group("interactable"):
		node.used.connect(_on_interactable_used)

	hud.set_sand(TimeControl.sand, TimeControl.max_sand)
	hud.set_hint("WASD move  |  SPACE jump  |  E use  |  HOLD R to un-happen")
	player.set_active(false)


func _setup_environment() -> void:
	var packed: PackedScene = load("res://library/lighting/golden-hour/golden_hour.tscn")
	var rig: Node3D = packed.instantiate()
	add_child(rig)
	var sun := rig.get_node_or_null("Sun") as DirectionalLight3D
	if sun:
		sun.rotation_degrees = Vector3(-48.0, 22.0, 0.0)
		sun.light_energy = 2.15
		sun.light_color = Color(1.0, 0.80, 0.56)
		sun.shadow_enabled = true
		sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
		sun.directional_shadow_max_distance = 70.0
		sun.shadow_blur = 1.4
		sun.shadow_bias = 0.04
	var we := rig.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if we and we.environment:
		var env := we.environment
		env.fog_density = 0.0026
		env.fog_light_color = Color(0.94, 0.72, 0.52)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.58, 0.64, 0.76)
		env.ambient_light_energy = 0.5
		env.glow_intensity = 0.7
		env.glow_bloom = 0.12
		env.adjustment_saturation = 1.12
		env.adjustment_contrast = 1.06
		env.ssao_radius = 1.4
		env.ssao_intensity = 1.6
		env.tonemap_exposure = 0.9
		if env.sky and env.sky.sky_material is ProceduralSkyMaterial:
			var sky := env.sky.sky_material as ProceduralSkyMaterial
			sky.sky_top_color = Color(0.19, 0.36, 0.66)
			sky.sky_horizon_color = Color(0.98, 0.70, 0.44)
			sky.ground_horizon_color = Color(0.86, 0.55, 0.34)
			sky.ground_bottom_color = Color(0.16, 0.13, 0.12)
			sky.sky_energy_multiplier = 0.95
		_env = env


func _unhandled_input(event: InputEvent) -> void:
	if state == "intro" and (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		_start_play()
	elif state == "won" and event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
		get_tree().reload_current_scene()


func _start_play() -> void:
	if state != "intro":
		return
	state = "play"
	player.set_active(true)
	hud.hide_intro()
	hud.set_objective("Climb the stair. The clock is waiting.")


func _process(delta: float) -> void:
	if state == "won":
		cam.yaw += delta * 0.22
	if _env:
		var sat := 0.5 if TimeControl.rewinding else 1.12
		var expo := 1.08 if TimeControl.rewinding else 0.9
		var k := 1.0 - exp(-9.0 * delta)
		_env.adjustment_saturation = lerpf(_env.adjustment_saturation, sat, k)
		_env.tonemap_exposure = lerpf(_env.tonemap_exposure, expo, k)
	if state == "intro":
		_intro_clock += delta
		if _intro_clock > 8.0:
			_start_play()


func _physics_process(delta: float) -> void:
	if state == "dying":
		if _auto_dying:
			return
		_respawn_timer -= delta
		if _respawn_timer <= 0.0:
			_respawn()
		return
	if state != "play":
		return

	_invulnerable = maxf(_invulnerable - delta, 0.0)
	_handle_rewind()
	if state != "play":
		return
	_handle_interact()
	_check_hazards()
	_update_checkpoint()
	_update_objective()
	_update_hint_zone()


func _handle_rewind() -> void:
	var want := Input.is_action_pressed("rewind")
	if want and not TimeControl.rewinding:
		TimeControl.start_rewind()
	elif not want and TimeControl.rewinding:
		TimeControl.stop_rewind()


func _handle_interact() -> void:
	var near: Node = player.interactable
	if near:
		hud.set_prompt("E     " + str(near.get("prompt")))
	else:
		hud.set_prompt("")
	var pressed := Input.is_action_pressed("interact")
	if near and pressed and not _interact_was:
		near.use(player)
		sfx.play("confirm", -14.0)
	_interact_was = pressed


func _on_interactable_used(source) -> void:
	if state != "play":
		return
	match str(source.get("kind")):
		"clock":
			_win()
		"windlass":
			world.bridge.latched = true
			world.spin_windlass()
			sfx.play("door_open", -3.0)
			hud.set_objective("The bridge is up. Cross the pit.")
		"hourglass":
			TimeControl.add_sand(3.0)
			sfx.play("confirm", -5.0)
			if source.has_method("consume"):
				source.consume()
			hud.set_objective("You pocketed the sand. More time to spend.")


func _on_pad_launched() -> void:
	sfx.play("boing", -4.0)
	cam.shake(0.5)


func _check_hazards() -> void:
	if _invulnerable > 0.0:
		return
	if player.global_position.y < -3.6:
		_die("In the dark of the pit, the watch turns back.")
		return
	if world.boulder.active():
		var bp: Vector3 = world.boulder.global_position
		if _chest().distance_to(bp) < 1.68:
			_die("The stone had other plans.")
			return
	var bob: Vector3 = world.pendulum.bob_position()
	if _chest().distance_to(bob) < 1.35:
		_die("The pendulum keeps its own time.")


func _chest() -> Vector3:
	return player.global_position + Vector3(0, 0.75, 0)


func _update_checkpoint() -> void:
	if checkpoint < 1 and player.global_position.z < -2.6 and player.is_on_floor():
		checkpoint = 1
	if checkpoint < 2 and player.global_position.z < -17.0:
		checkpoint = 2


func _update_objective() -> void:
	var z: float = player.global_position.z
	var text := ""
	if z > -2.0:
		text = "Climb the stair. The clock is waiting."
	elif z > -11.4:
		if world.bridge.latched:
			text = "The bridge is up. Cross the pit."
		else:
			text = "The drawbridge sleeps. Something heavy must wake it."
	elif z > -16.4:
		text = "Cross the bridge into the tower."
	else:
		text = "Reach the heart of the clock."
	if text != _objective:
		_objective = text
		hud.set_objective(text)


func _update_hint_zone() -> void:
	var z: float = player.global_position.z
	var zone := 0
	if z < -16.0:
		zone = 3
	elif z < -11.4:
		zone = 12 if world.bridge.latched else 2
	elif player.global_position.distance_to(Vector3(9.2, 0.0, 9.5)) < 3.6:
		zone = 4
	elif z < -1.5:
		zone = 1
	if zone == _zone:
		return
	_zone = zone
	match zone:
		0:
			hud.set_hint("HOLD R to rewind time  |  every stone, crate and pendulum goes back with you")
		1:
			hud.set_hint("The stone rolls down the stair. Time it, or hold R and send it back up.")
		2:
			hud.set_hint("Something heavy must hold the glowing plate to raise the bridge.")
		12:
			hud.set_hint("The windlass holds the bridge up. Cross, then face the pendulum.")
		4:
			hud.set_hint("The brass ring is a wound spring. Stand on it and it throws you up to the balcony.")
		3:
			hud.set_hint("Wait for the pendulum to swing away, then run to the clock and press E.")


func _die(reason: String) -> void:
	if state != "play":
		return
	state = "dying"
	player.set_active(false)
	hud.death_flash()
	sfx.play("thud", -3.0)
	cam.shake(1.4)
	_auto_dying = TimeControl.auto_rewind(1.7)
	if not _auto_dying:
		_respawn_timer = 1.0
		hud.set_objective(reason)


func _on_rewind_started() -> void:
	sfx.play("tick", -18.0, 0.8)


func _on_rewind_stopped() -> void:
	if state == "dying":
		state = "play"
		player.set_active(true)
		_invulnerable = 0.9
		hud.death_off()
		_auto_dying = false


func _respawn() -> void:
	state = "play"
	_auto_dying = false
	player.global_position = world.checkpoints[checkpoint]
	player.velocity = Vector3.ZERO
	_invulnerable = 1.0
	TimeControl.stop_rewind()
	TimeControl.clear_history()
	hud.death_off()
	player.set_active(true)
	sfx.play("confirm", -10.0)


func _on_plate_pressed(pressed: bool) -> void:
	if not world.bridge.latched:
		world.bridge.target = 1.0 if pressed else 0.0
	world.plate.set_lit(pressed)
	if pressed:
		sfx.play("door_open", -6.0)
		hud.set_objective("The bridge is rising. Cross it.")
	else:
		sfx.play("door_close", -12.0)


func _win() -> void:
	state = "won"
	player.set_active(false)
	TimeControl.set_frozen(true)
	hud.set_prompt("")
	hud.show_win()
	sfx.play("bell", -2.0)
	cam.shake(0.6)
