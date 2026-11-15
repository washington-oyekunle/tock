extends Control
## The boy's pocket watch, drawn in the corner: sand left for going back.

var value := 1.0
var _spin := 0.0


func _process(delta: float) -> void:
	_spin += delta * (-5.0 if TimeControl.rewinding else 0.5)
	queue_redraw()


func _draw() -> void:
	var c := size * 0.5
	var r := minf(c.x, c.y) - 10.0
	draw_circle(c, r + 7.0, Color(0.05, 0.04, 0.05, 0.55))
	draw_arc(c, r, 0.0, TAU, 64, Color(0.95, 0.86, 0.68, 0.16), 9.0, true)
	var start := -PI * 0.5
	var clamped := clampf(value, 0.0, 1.0)
	if clamped > 0.002:
		draw_arc(c, r, start, start + TAU * clamped, 64, Color(1.0, 0.78, 0.34, 0.95), 9.0, true)
	for i in 12:
		var a := start + TAU * float(i) / 12.0
		var p1 := c + Vector2(cos(a), sin(a)) * (r - 15.0)
		var p2 := c + Vector2(cos(a), sin(a)) * (r - 8.0)
		draw_line(p1, p2, Color(0.96, 0.88, 0.7, 0.45), 2.0)
	var hand := start + _spin + TAU * clamped
	var hp := c + Vector2(cos(hand), sin(hand)) * (r - 24.0)
	draw_line(c, hp, Color(1.0, 0.9, 0.7, 0.95), 3.0)
	draw_circle(c, 4.5, Color(1.0, 0.9, 0.7, 0.95))
