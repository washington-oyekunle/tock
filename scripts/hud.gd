extends CanvasLayer
## Objective, the watch dial, the rewind wash and the two story cards.

var _tint_mat: ShaderMaterial
var _dial: Control
var _objective: Label
var _hint: Label
var _prompt: Label
var _rewind: Label
var _intro: Control
var _win: Control
var _death: ColorRect
var _strength := 0.0
var _death_target := 0.0


func _ready() -> void:
	layer = 5
	_tint_mat = ShaderMaterial.new()
	_tint_mat.shader = load("res://shaders/rewind_screen.gdshader")
	_tint_mat.set_shader_parameter("strength", 0.0)
	var tint := ColorRect.new()
	tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	tint.color = Color(1, 1, 1, 1)
	tint.material = _tint_mat
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tint)

	_death = ColorRect.new()
	_death.set_anchors_preset(Control.PRESET_FULL_RECT)
	_death.color = Color(0.45, 0.06, 0.10, 0.0)
	_death.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_death)

	var band := ColorRect.new()
	band.set_anchors_preset(Control.PRESET_TOP_WIDE)
	band.offset_bottom = 100
	band.color = Color(0.06, 0.05, 0.05, 0.32)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(band)

	_dial = load("res://scripts/sand_dial.gd").new()
	_dial.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_dial.offset_left = 28
	_dial.offset_top = -196
	_dial.offset_right = 180
	_dial.offset_bottom = -44
	_dial.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dial)

	var dial_label := _label("REWIND", 14, Color(0.96, 0.88, 0.7, 0.8))
	dial_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	dial_label.offset_left = 28
	dial_label.offset_top = -40
	dial_label.offset_right = 188
	dial_label.offset_bottom = -20
	dial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(dial_label)

	_objective = _label("", 27, Color(1.0, 0.94, 0.82))
	_objective.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_objective.offset_top = 26
	_objective.offset_bottom = 68
	_objective.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_objective)

	_rewind = _label("TIME RUNNING BACK", 22, Color(0.75, 0.85, 1.0))
	_rewind.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_rewind.offset_top = 72
	_rewind.offset_bottom = 108
	_rewind.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rewind.modulate.a = 0.0
	add_child(_rewind)

	_hint = _label("", 19, Color(0.94, 0.9, 0.82))
	_hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_hint.offset_top = -58
	_hint.offset_bottom = -24
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_hint)

	_prompt = _label("", 24, Color(1.0, 0.92, 0.62))
	_prompt.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_prompt.offset_top = -108
	_prompt.offset_bottom = -70
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_prompt)

	_build_intro()
	_build_win()


func _label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0.07, 0.05, 0.04, 0.9))
	l.add_theme_constant_override("outline_size", 7)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _panel(alpha: float) -> Array:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.06, 0.045, 0.05, alpha)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(box)
	return [root, box]


func _stack_label(box: VBoxContainer, text: String, font_size: int, color: Color) -> Label:
	var l := _label(text, font_size, color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	box.add_child(l)
	return l


func _build_intro() -> void:
	var parts := _panel(0.9)
	_intro = parts[0]
	var box: VBoxContainer = parts[1]
	_stack_label(box, "TOCK", 96, Color(1.0, 0.86, 0.55))
	_stack_label(box, "a boy, a broken pocket watch, and one courtyard\nthat refuses to stay broken", 24, Color(0.96, 0.91, 0.83))
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 26)
	box.add_child(gap)
	_stack_label(box, "WASD  move      SPACE  jump      MOUSE  look", 21, Color(0.86, 0.84, 0.8))
	_stack_label(box, "HOLD  R  to un-happen the last seconds", 23, Color(1.0, 0.8, 0.45))
	var gap2 := Control.new()
	gap2.custom_minimum_size = Vector2(0, 18)
	box.add_child(gap2)
	_stack_label(box, "press any key", 18, Color(0.72, 0.7, 0.66))


func _build_win() -> void:
	var parts := _panel(0.92)
	_win = parts[0]
	var box: VBoxContainer = parts[1]
	_stack_label(box, "THE CLOCK REMEMBERS", 62, Color(1.0, 0.86, 0.55))
	_stack_label(box, "You mended an hour that never had to happen.", 26, Color(0.96, 0.91, 0.83))
	_stack_label(box, "Press ENTER to walk it again.", 19, Color(0.72, 0.7, 0.66))
	_win.hide()


func _process(delta: float) -> void:
	var want := 1.0 if TimeControl.rewinding else 0.0
	_strength = lerpf(_strength, want, 1.0 - exp(-9.0 * delta))
	_tint_mat.set_shader_parameter("strength", _strength)
	_rewind.modulate.a = _strength
	var a := lerpf(_death.color.a, _death_target * 0.55, 1.0 - exp(-10.0 * delta))
	_death.color.a = a


func set_sand(value: float, maximum: float) -> void:
	_dial.value = value / maxf(maximum, 0.001)


func set_objective(text: String) -> void:
	_objective.text = text


func set_hint(text: String) -> void:
	_hint.text = text


func set_prompt(text: String) -> void:
	_prompt.text = text


func hide_intro() -> void:
	if not _intro.visible:
		return
	var tw := create_tween()
	tw.tween_property(_intro, "modulate:a", 0.0, 0.7)
	tw.tween_callback(_intro.hide)


func show_win() -> void:
	_win.show()
	_win.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(_win, "modulate:a", 1.0, 1.2)


func death_flash() -> void:
	_death_target = 1.0


func death_off() -> void:
	_death_target = 0.0
