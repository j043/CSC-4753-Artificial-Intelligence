extends Control
## Single owner for menus, pause, and mouse capture.
const Facility = preload("res://scripts/facility.gd")
const Player = preload("res://scripts/player.gd")
var world: Node3D
var player: CharacterBody3D
var panel: CenterContainer
var menu: VBoxContainer
var hud: Label
var prompt: Label
var notice: Label
var crosshair: Label
var notice_time := 0.0
var mode := "menu"
var tour := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for binding in [["walk_forward", KEY_W], ["walk_back", KEY_S], ["walk_left", KEY_A], ["walk_right", KEY_D], ["sprint", KEY_SHIFT], ["interact", KEY_E], ["flashlight", KEY_F], ["pause", KEY_ESCAPE]]:
		if not InputMap.has_action(binding[0]):
			InputMap.add_action(binding[0])
			var event := InputEventKey.new()
			event.physical_keycode = binding[1]
			InputMap.action_add_event(binding[0], event)
	hud = label_at(Vector2(24, 20), 20)
	prompt = label_at(Vector2(24, 112), 22)
	notice = label_at(Vector2(24, 160), 20)
	crosshair = Label.new()
	crosshair.text = "+"
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(crosshair)
	panel = CenterContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	var background := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.045, 0.055, 0.065, 1)
	background.add_theme_stylebox_override("panel", style)
	panel.add_child(background)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	background.add_child(margin)
	menu = VBoxContainer.new()
	menu.add_theme_constant_override("separation", 14)
	margin.add_child(menu)
	show_menu()
	print("Blackwell M1 ready")

func label_at(offset: Vector2, size: int) -> Label:
	var label := Label.new()
	label.position = offset
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func clear_menu(title: String, description: String) -> void:
	for child in menu.get_children():
		menu.remove_child(child)
		child.queue_free()
	var heading := Label.new()
	heading.text = title
	heading.add_theme_font_size_override("font_size", 32)
	menu.add_child(heading)
	var detail := Label.new()
	detail.text = description
	menu.add_child(detail)
	panel.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	crosshair.hide()

func button(text: String, callback: Callable) -> void:
	var item := Button.new()
	item.text = text
	item.custom_minimum_size = Vector2(510, 46)
	item.pressed.connect(callback)
	menu.add_child(item)
	if menu.get_child_count() == 3:
		item.grab_focus()

func show_menu() -> void:
	get_tree().paused = false
	mode = "menu"
	if is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	player = null
	hud.text = ""
	prompt.text = ""
	notice.text = ""
	clear_menu("BLACKWELL: LAST SHIFT", "M1 - Walkable facility\nWASD move / Mouse look / Shift sprint\nE interact / F flashlight / Escape pause\nNPCs and objective progression arrive in later milestones.")
	button("Start - initial lockdown", start.bind(false))
	button("Facility tour - gates open", start.bind(true))
	button("Quit", func(): get_tree().quit())

func start(open_gates: bool) -> void:
	tour = open_gates
	world = Facility.new()
	world.process_mode = Node.PROCESS_MODE_PAUSABLE
	world.tour = tour
	add_child(world)
	move_child(world, 0)
	player = Player.new()
	world.add_child(player)
	player.position = Vector3(0, 0.1, 3)
	player.interacted.connect(show_notice)
	notice_time = 0
	notice.text = ""
	resume()

func resume() -> void:
	mode = "play"
	get_tree().paused = false
	panel.hide()
	crosshair.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func pause_game() -> void:
	mode = "pause"
	get_tree().paused = true
	clear_menu("PAUSED", "Simulation paused.\nWASD move / Shift sprint / E interact / F flashlight")
	button("Resume", resume)
	button("Return to Menu", show_menu)
	button("Quit", func(): get_tree().quit())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		if mode == "play":
			pause_game()
		elif mode == "pause":
			resume()
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and mode == "play":
		pause_game()

func show_notice(message: String) -> void:
	notice.text = message
	notice_time = 5.0

func _process(delta: float) -> void:
	if mode != "play" or not is_instance_valid(player):
		return
	hud.text = "%s\n%s\nF Flashlight: %s  |  E Interact  |  Esc Pause" % [world.area_name(player.position), "FACILITY TOUR - gates open" if tour else "LOCKDOWN - explore; power restoration arrives in M3", "ON" if player.light.visible else "OFF"]
	var target: Object = player.interaction_target()
	prompt.text = "[E] " + str(target.get_meta("prompt")) if target else ""
	notice_time = maxf(0.0, notice_time - delta)
	if notice_time == 0:
		notice.text = ""
