extends Control
## Resolution-independent nuclear-facility insignia and title wordmark.
var title_font := SystemFont.new()
const GOLD := Color("c3a15b")
const PALE := Color("e2e7df")

func _ready() -> void:
	custom_minimum_size = Vector2(560, 166)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_font.font_names = PackedStringArray(["Bahnschrift", "DejaVu Sans"])
	title_font.font_weight = 700
	resized.connect(queue_redraw)

func _draw() -> void:
	var center := Vector2(51, 68)
	draw_arc(center, 44, 0, TAU, 80, GOLD.darkened(0.5), 1.5, true)
	draw_arc(center, 39, -PI * 0.8, PI * 0.8, 64, GOLD, 2, true)
	draw_circle(center, 6, GOLD)
	for blade in 3:
		var points := PackedVector2Array()
		var angle := -PI / 2 + blade * TAU / 3
		for step in 17:
			points.append(center + Vector2.from_angle(angle + step * PI / 48) * 30)
		for step in range(16, -1, -1):
			points.append(center + Vector2.from_angle(angle + step * PI / 48) * 12)
		draw_colored_polygon(points, GOLD)
	draw_string(title_font, Vector2(113, 82), "BLACKWELL", HORIZONTAL_ALIGNMENT_LEFT, -1, 58, PALE)
	draw_string(title_font, Vector2(117, 111), "L A S T   S H I F T", HORIZONTAL_ALIGNMENT_LEFT, -1, 23, GOLD)
	draw_line(Vector2(0, 136), Vector2(size.x, 136), GOLD.darkened(0.6), 1, true)
	for i in 6:
		var x := float(i * 12)
		draw_colored_polygon(PackedVector2Array([Vector2(x, 134), Vector2(x + 6, 134), Vector2(x + 12, 138), Vector2(x + 6, 138)]), GOLD)
	draw_string(ThemeDB.fallback_font, Vector2(0, 159), "NUCLEAR RESEARCH DIVISION   /   CONTAINMENT LOST", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("82938e"))
