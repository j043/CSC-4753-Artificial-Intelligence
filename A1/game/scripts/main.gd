extends Control
## Single owner for menus, pause, and mouse capture.
const Facility = preload("res://scripts/facility.gd")
const Player = preload("res://scripts/player.gd")
const NPC = preload("res://scripts/npc.gd")
var speaker: CharacterBody3D
var dialogue_page := "root"
var dialogue_line := ""
var previous_mode := "play"
var world: Node3D
var player: CharacterBody3D
var panel: CenterContainer
var menu: VBoxContainer
var choices: HBoxContainer
var hud: Label
var prompt: Label
var notice: Label
var crosshair: Label
var shade: ColorRect
var notice_time := 0.0
var notice_characters := 0.0
var notice_queue: Array[String] = []
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
	notice = label_at(Vector2.ZERO, 26)
	notice.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	notice.offset_left = 60
	notice.offset_right = -60
	notice.offset_top = -150
	notice.offset_bottom = -28
	notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	crosshair = Label.new()
	crosshair.text = "+"
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(crosshair)
	shade = ColorRect.new()
	shade.color = Color(0, 0, 0, 0.65)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
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
	print("Blackwell M2 ready")

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
	choices = null
	for child in menu.get_children():
		menu.remove_child(child)
		child.queue_free()
	var heading := Label.new()
	heading.text = title
	heading.add_theme_font_size_override("font_size", 32)
	menu.add_child(heading)
	var detail := Label.new()
	detail.text = description
	detail.custom_minimum_size.x = 1000 if mode == "dialogue" else 560
	detail.add_theme_font_size_override("font_size", 30 if mode == "dialogue" else 18)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	menu.add_child(detail)
	if mode == "dialogue":
		choices = HBoxContainer.new()
		choices.add_theme_constant_override("separation", 16)
		menu.add_child(choices)
		var hint := Label.new()
		hint.text = "Esc — close conversation"
		hint.add_theme_font_size_override("font_size", 18)
		menu.add_child(hint)
	panel.show()
	shade.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	crosshair.hide()

func button(text: String, callback: Callable) -> void:
	var item := Button.new()
	item.text = text
	item.custom_minimum_size = Vector2(0, 56) if choices else Vector2(510, 46)
	if choices:
		item.add_theme_font_size_override("font_size", 20)
		item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.pressed.connect(callback)
	var parent: Container = choices if choices else menu
	parent.add_child(item)
	if (choices and choices.get_child_count() == 1) or (not choices and menu.get_child_count() == 3):
		item.grab_focus()

func show_menu() -> void:
	get_tree().paused = false
	mode = "menu"
	if is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	player = null
	speaker = null
	previous_mode = "play"
	hud.text = ""
	prompt.text = ""
	notice.text = ""
	notice_queue.clear()
	notice_time = 0
	clear_menu("BLACKWELL: LAST SHIFT", "M2 - NPC interaction slice\nWASD move / Mouse look / Shift sprint\nE interact or talk / F flashlight / Escape pause\nMeet Mara and Eli in security. Objective progression arrives in M3.")
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
	player.npc_selected.connect(open_dialogue)
	for engineer in [true, false]:
		var npc := NPC.new()
		npc.engineer = engineer
		npc.person = "Mara Voss" if engineer else "Eli Ward"
		npc.player = player
		npc.facility = world
		npc.position = Vector3(-1.8 if engineer else 1.8, 0.05, 1)
		npc.announced.connect(show_notice)
		world.add_child(npc)
		world.npcs.append(npc)
	notice_time = 0
	notice.text = ""
	resume()

func resume() -> void:
	if mode == "pause" and previous_mode == "dialogue" and is_instance_valid(speaker):
		get_tree().paused = false
		mode = "dialogue"
		draw_dialogue()
		return
	mode = "play"
	if is_instance_valid(player):
		player.controls_enabled = true
	get_tree().paused = false
	panel.hide()
	shade.hide()
	crosshair.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func pause_game() -> void:
	previous_mode = mode
	mode = "pause"
	get_tree().paused = true
	clear_menu("PAUSED", "Simulation paused.\nWASD move / Shift sprint / E interact / F flashlight")
	button("Resume", resume)
	button("Return to Menu", show_menu)
	button("Quit", func(): get_tree().quit())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		if mode == "dialogue":
			close_dialogue()
		elif mode == "play":
			pause_game()
		elif mode == "pause":
			resume()
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and mode in ["play", "dialogue"]:
		pause_game()

func show_notice(message: String) -> void:
	if not notice.text.is_empty():
		notice_queue.append(message)
		return
	notice.text = message
	notice.visible_characters = 0
	notice_characters = 0
	notice_time = 5.0

func update_notice(delta: float) -> void:
	if notice.text.is_empty():
		return
	if notice.visible_characters < notice.get_total_character_count():
		notice_characters += delta * 40.0
		notice.visible_characters = mini(int(notice_characters), notice.get_total_character_count())
	else:
		notice_time = maxf(0, notice_time - delta)
		if notice_time == 0:
			notice.text = ""
			if not notice_queue.is_empty():
				show_notice(notice_queue.pop_front())

func open_dialogue(npc: CharacterBody3D) -> void:
	if mode != "play":
		return
	speaker = npc
	speaker.talking = true
	player.controls_enabled = false
	player.velocity = Vector3.ZERO
	mode = "dialogue"
	dialogue_page = "root"
	dialogue_line = ""
	prompt.text = ""
	draw_dialogue()

func close_dialogue() -> void:
	if is_instance_valid(speaker):
		speaker.talking = false
	speaker = null
	previous_mode = "play"
	resume()

func topic(page: String, line := "") -> void:
	dialogue_page = page
	dialogue_line = line
	draw_dialogue()

func order(command: String) -> void:
	speaker.command(command)
	close_dialogue()

func draw_dialogue() -> void:
	var engineer: bool = speaker.engineer
	var intro := "Let's inspect the repair station in maintenance." if engineer else "Stay together. I can inspect the security station in control."
	if speaker.task_ready:
		intro = "I'm in position. We need a replacement component before repairs." if engineer else "I'm in position. We need emergency power before authorization."
	clear_menu(speaker.person, dialogue_line if dialogue_line != "" else speaker.person + ": " + intro)
	if dialogue_line != "":
		button("Back", topic.bind(dialogue_page))
	elif dialogue_page == "root":
		button("Wait here" if speaker.state in ["follow", "travel_to_task", "perform_task"] else "Follow me", order.bind("wait" if speaker.state in ["follow", "travel_to_task", "perform_task"] else "follow"))
		button("Help me with something", topic.bind("help"))
	elif dialogue_page in ["help", "commands"]:
		button("Go to your isolation station" if tour else "Inspect your station", order.bind("isolation" if tour else "station"))
		button("Ask a question", topic.bind("questions"))
		button("Back", topic.bind("root"))
	elif dialogue_page == "questions":
		button("What happened?", topic.bind("situation"))
		button("What should we do?", topic.bind("expertise"))
		button("Back", topic.bind("help"))
	elif dialogue_page == "situation":
		button("What failed?" if engineer else "Any other survivors?", topic.bind("situation", speaker.person + ": " + ("The main supply failed, but the containment alarm stayed on. It wasn't a simple blackout." if engineer else "Only Mara answered. We search together; nobody goes alone.")))
		button("Can we fix it?" if engineer else "Why are the doors locked?", topic.bind("situation", speaker.person + ": " + ("We need a replacement component from maintenance. I can inspect the station first." if engineer else "Coolant needs power. Observation needs my authorization too.")))
		button("Back", topic.bind("questions"))
	elif dialogue_page == "expertise":
		button("How does isolation work?" if engineer else "How do we open observation?", topic.bind("expertise", speaker.person + ": " + ("Three people: me at maintenance, Eli at security, you at chamber control." if engineer else "Restore power first. Then I check the access panel and authorize the route.")))
		button("What worries you?" if engineer else "Where is the exit?", topic.bind("expertise", speaker.person + ": " + ("The alarms are out of sequence. Check physical readings before trusting the intercom." if engineer else "Back through coolant and control, then west from security to the lift.")))
		button("Back", topic.bind("questions"))

func _process(delta: float) -> void:
	if mode != "play" or not is_instance_valid(player):
		return
	hud.text = "%s\n%s\nF Flashlight: %s  |  E Interact  |  Esc Pause" % [world.area_name(player.position), "FACILITY TOUR - gates open" if tour else "LOCKDOWN - explore; power restoration arrives in M3", "ON" if player.light.visible else "OFF"]
	var target: Object = player.interaction_target()
	prompt.text = "[E] " + str(target.get_meta("prompt")) if target else ""
	update_notice(delta)
