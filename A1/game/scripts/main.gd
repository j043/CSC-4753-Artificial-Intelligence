extends Control
## Single owner for menus, pause, and mouse capture.
const Facility = preload("res://scripts/facility.gd")
const Player = preload("res://scripts/player.gd")
const NPC = preload("res://scripts/npc.gd")
const Progression = preload("res://scripts/progression.gd")
var progress: Node
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
var notice_is_exchange := false
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
	hud.custom_minimum_size.x = 1180
	hud.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt = label_at(Vector2(24, 145), 22)
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
	print("Blackwell M3 ready")

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
	notice_is_exchange = false
	hud.text = ""
	prompt.text = ""
	notice.text = ""
	notice_queue.clear()
	notice_time = 0
	clear_menu("BLACKWELL: LAST SHIFT", "M3 - complete objective skeleton\nWASD move / Mouse look / Shift sprint\nE interact or talk / F flashlight / Escape pause\nMeet Mara and Eli, restore power, isolate the chamber, and evacuate.")
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
	progress = Progression.new()
	progress.app = self
	world.add_child(progress)
	world.progression = progress
	player.object_selected.connect(interact_object)
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
	notice.show()
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
	notice_time = 3.0

func replace_interaction_feedback() -> void:
	# Replay an interrupted story line after the new feedback, never silently skip it.
	if notice_is_exchange and is_instance_valid(progress) and progress.active != "":
		progress.line_index = maxi(0, progress.line_index - 1)
	notice_is_exchange = false
	notice.text = ""
	notice_queue.clear()
	notice_time = 0
	notice_characters = 0

func update_notice(delta: float) -> void:
	if notice.text.is_empty():
		return
	if notice.visible_characters < notice.get_total_character_count():
		notice_characters += delta * 40.0
		notice.visible_characters = mini(int(notice_characters), notice.get_total_character_count())
	else:
		notice_time = maxf(0, notice_time - delta)
		if notice_time == 0:
			notice_is_exchange = false
			notice.text = ""
			if not notice_queue.is_empty():
				show_notice(notice_queue.pop_front())

func open_dialogue(npc: CharacterBody3D) -> void:
	if mode != "play":
		return
	replace_interaction_feedback()
	if not tour and progress.stage >= 6:
		show_notice("Evacuation underway. Meet both survivors at the lift.")
		return
	if not tour:
		progress.meet(npc)
	speaker = npc
	speaker.talking = true
	player.controls_enabled = false
	player.velocity = Vector3.ZERO
	mode = "dialogue"
	notice.hide()
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
	replace_interaction_feedback()
	speaker.command(command)
	close_dialogue()

func draw_dialogue() -> void:
	var engineer: bool = speaker.engineer
	var intro: String
	if tour:
		intro = "I handle machinery. My isolation panel is in observation; assign me there when you're ready." if engineer else "I handle access. My security override is in observation. The lift is west of security."
	else:
		match progress.stage:
			1:
				intro = "The lockdown cut our power, but containment is still active. I can repair the supply with the spare on the maintenance workbench, east of control. Speak to Eli too; he handles security access." if engineer else "Only Mara answered my call. Coolant is locked until she restores power; then I can authorize observation access. Speak to her too. Our exit is the lift west of security."
			2:
				intro = "Get the replacement component from the maintenance workbench, east of control. Then ask me to restore power; I'll install it at the repair station." if engineer else "Bring Mara the spare from maintenance, east of control. Once power is back, send me to the control-room security station to open observation."
			3:
				intro = "You've got the component. Send me to restore power at the maintenance station. I'll install it and open the coolant gate." if engineer else "Mara has what she needs. Ask her to restore power first; then I can authorize observation access from control."
			4:
				intro = "Power is stable and the coolant gate is open. Ask Eli to authorize observation access at the control-room station. We'll need all three of us for isolation." if engineer else "Power is back. Send me to authorize observation access; I'll operate the control-room security station and open the next gate."
			_:
				intro = "In observation, assign me to the maintenance panel and Eli to the security override. When we're both READY, activate the chamber console on the east side." if engineer else "Assign both of us to our observation stations. I'll hold the security override while Mara holds her panel. You activate chamber isolation, then we return to the lift west of security."
				if progress.warning_known:
					intro += " That voice was an imitation. Trust our isolation procedure."
	if dialogue_page == "context":
		intro = "The main supply failed while the containment alarm stayed on. That isn't a normal blackout. My job is to repair power and hold the maintenance panel during isolation. Check physical readings before trusting the intercom." if engineer else "Only Mara responded to the lockdown. Nobody goes alone. I handle locked routes and the isolation override. To evacuate, head south through coolant and control, then west from security to the lift."
	clear_menu(speaker.person, dialogue_line if dialogue_line != "" else speaker.person + ": " + intro)
	if dialogue_page == "context" or dialogue_line != "":
		button("Back", topic.bind("root"))
		return
	button("Wait here" if speaker.state in ["follow", "travel_to_task", "perform_task"] else "Follow me", order.bind("wait" if speaker.state in ["follow", "travel_to_task", "perform_task"] else "follow"))
	button("Isolation station" if tour or progress.stage >= 5 else ("Restore power" if engineer else "Authorize access"), order.bind("isolation" if tour or progress.stage >= 5 else "station"))
	button("More context", topic.bind("context"))

func _process(delta: float) -> void:
	if mode != "play" or not is_instance_valid(player):
		return
	hud.text = "%s\n%s\nF Flashlight: %s  |  E Interact  |  Esc Pause" % [world.area_name(player.position), "FACILITY TOUR - gates open" if tour else ("O%d/6: %s\n%s" % [mini(progress.stage, 6), progress.hint(), progress.readiness()]), "ON" if player.light.visible else "OFF"]
	prompt.position.y = hud.position.y + hud.size.y + 12
	var target: Object = player.interaction_target()
	prompt.text = "[E] " + str(target.get_meta("prompt")) if target else ""
	update_notice(delta)
	if not tour:
		progress.tick()

func interact_object(target: Object) -> void:
	replace_interaction_feedback()
	if tour:
		show_notice("Facility tour: inspection only; no component collected. Choose Start - initial lockdown to play objectives." if target.get_meta("object_id", "") == "Maintenance workbench" else str(target.get_meta("message")))
	else:
		progress.interact(target)

func show_success() -> void:
	mode = "success"
	player.controls_enabled = false
	get_tree().paused = true
	notice.text = ""
	notice_queue.clear()
	clear_menu("EVACUATION COMPLETE", "You, Mara, and Eli escaped. The chamber remains isolated.\nM3 playable skeleton complete. Narrative choices and timed escape arrive in M4.")
	button("New Game", func(): show_menu(); start(false))
	button("Return to Menu", show_menu)
