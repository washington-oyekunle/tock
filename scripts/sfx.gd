extends Node
## Clock sounds built from scratch, plus a handful of CC0 library clips.

const SFX := "res://library/sounds/rpg-sound-effects/"

var _players: Array = []
var _cursor := 0
var _cache := {}
var _loop: AudioStreamPlayer
var _tick_player: AudioStreamPlayer
var _tick_accum := 0.0


func _ready() -> void:
	for i in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_cache["door_open"] = load(SFX + "doorOpen_2.ogg")
	_cache["door_close"] = load(SFX + "doorClose_4.ogg")
	_cache["wood"] = load(SFX + "impactWood_light_002.ogg")
	_cache["confirm"] = load(SFX + "confirmation_002.ogg")
	_cache["error"] = load(SFX + "error_006.ogg")
	_cache["drop"] = load(SFX + "drop_002.ogg")
	_cache["bell"] = _bell()
	_cache["thud"] = _thud()
	_cache["boing"] = _boing()
	_loop = AudioStreamPlayer.new()
	_loop.stream = _whoosh()
	_loop.volume_db = -10.0
	add_child(_loop)
	_tick_player = AudioStreamPlayer.new()
	_tick_player.stream = _tick()
	_tick_player.volume_db = -18.0
	add_child(_tick_player)
	TimeControl.rewind_started.connect(_on_rewind_started)
	TimeControl.rewind_stopped.connect(_on_rewind_stopped)


func play(sound: String, db := 0.0, pitch := 1.0) -> void:
	var stream: AudioStream = _cache.get(sound, null)
	if stream == null:
		return
	var p: AudioStreamPlayer = _players[_cursor]
	_cursor = (_cursor + 1) % _players.size()
	p.stream = stream
	p.volume_db = db
	p.pitch_scale = pitch
	p.play()


func _on_rewind_started() -> void:
	_loop.play()


func _on_rewind_stopped() -> void:
	_loop.stop()


func _process(delta: float) -> void:
	if not TimeControl.rewinding:
		return
	_tick_accum += delta
	if _tick_accum > 0.085:
		_tick_accum = 0.0
		_tick_player.pitch_scale = 1.0 + randf() * 0.1
		_tick_player.play()


func _wav(samples: PackedFloat32Array, rate := 22050) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)
	for i in samples.size():
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	return wav


func _whoosh() -> AudioStreamWAV:
	var rate := 22050
	var length := 1.6
	var n := int(rate * length)
	var s := PackedFloat32Array()
	s.resize(n)
	var lp := 0.0
	var lp2 := 0.0
	for i in n:
		var t := float(i) / rate
		var u := t / length
		var env := sin(PI * u)
		var cut := 0.03 + 0.22 * (1.0 - absf(u - 0.5) * 2.0)
		var white := randf() * 2.0 - 1.0
		lp += (white - lp) * cut
		lp2 += (lp - lp2) * cut
		var tone := sin(TAU * (150.0 + 380.0 * u) * t) * 0.22
		s[i] = (lp2 * 1.5 + tone) * env * 0.55
	return _wav(s, rate)


func _tick() -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * 0.07)
	var s := PackedFloat32Array()
	s.resize(n)
	for i in n:
		var t := float(i) / rate
		var env := exp(-t * 75.0)
		s[i] = (sin(TAU * 2100.0 * t) * 0.5 + sin(TAU * 3450.0 * t) * 0.25) * env * 0.6
	return _wav(s, rate)


func _bell() -> AudioStreamWAV:
	var rate := 22050
	var length := 3.4
	var n := int(rate * length)
	var s := PackedFloat32Array()
	s.resize(n)
	var partials := [1.0, 2.02, 2.98, 4.06, 5.42]
	for i in n:
		var t := float(i) / rate
		var v := 0.0
		for k in partials.size():
			var f: float = 196.0 * float(partials[k])
			var amp := 0.55 / (1.0 + float(k) * 1.5)
			v += sin(TAU * f * t) * amp * exp(-t * (1.0 + float(k) * 0.9))
		s[i] = v * 0.45
	return _wav(s, rate)


func _thud() -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * 0.45)
	var s := PackedFloat32Array()
	s.resize(n)
	for i in n:
		var t := float(i) / rate
		var env := exp(-t * 16.0)
		s[i] = (sin(TAU * 78.0 * t) * 0.7 + sin(TAU * 132.0 * t) * 0.25) * env * 0.8
	return _wav(s, rate)


func _boing() -> AudioStreamWAV:
	var rate := 22050
	var n := int(rate * 0.55)
	var s := PackedFloat32Array()
	s.resize(n)
	var phase := 0.0
	for i in n:
		var t := float(i) / rate
		var f := 200.0 + 540.0 * minf(t / 0.3, 1.0)
		phase += TAU * f / rate
		s[i] = sin(phase) * exp(-t * 6.5) * 0.5
	return _wav(s, rate)
