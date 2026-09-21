extends SceneTree
var app: Control
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, text: String) -> void:
	if condition:
		print("PASS: " + text)
	else:
		push_error("FAIL: " + text)
		failures += 1

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func run() -> void:
	app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.start(false)
	await frames(10)
	var mara = app.world.npcs[0]
	var eli = app.world.npcs[1]
	check(app.world.navigation_ready, "Navigation bake synchronized")
	check(app.world.route(Vector3.ZERO, Vector3(12, 0, -12)).size() > 0, "Maintenance route exists")
	check(app.world.route(Vector3.ZERO, Vector3(0, 0, -24)).is_empty(), "Gate A disconnects navigation")
	check(app.world.route(Vector3(0, 0, -24), Vector3(0, 0, -36)).is_empty(), "Gate B disconnects navigation")
	check(mara.person != eli.person and mara.engineer != eli.engineer, "NPC identities and roles differ")
	app.player.camera.look_at(mara.position + Vector3(0, 1.4, 0))
	app.player.position = Vector3(-1.8, 0.05, 2)
	app.player.camera.look_at(mara.position + Vector3(0, 1.4, 0))
	await frames(2)
	check(app.player.interaction_target() == mara, "Camera ray targets Mara")
	app.open_dialogue(mara)
	var initial: Vector3 = app.player.position
	Input.action_press("walk_forward")
	await frames(30)
	Input.action_release("walk_forward")
	check(app.player.position == initial and not app.player.controls_enabled, "Dialogue freezes player movement")
	var look := InputEventMouseMotion.new()
	look.relative = Vector2(100, 100)
	var camera_rotation: Vector3 = app.player.camera.rotation
	app.player._unhandled_input(look)
	check(app.player.camera.rotation == camera_rotation, "Dialogue prevents camera look")
	app.topic("expertise", "Mara Voss: test line")
	app.pause_game()
	await frames(5)
	app.resume()
	check(app.mode == "dialogue" and app.dialogue_page == "expertise" and not app.player.controls_enabled, "Pause/resume preserves dialogue and input mode")
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Dialogue resume leaves pointer visible")
	app.close_dialogue()
	check(app.mode == "play" and app.player.controls_enabled and not mara.talking, "Conversation exit restores controls")
	app.open_dialogue(mara)
	app.topic("situation")
	var escape := InputEventAction.new()
	escape.action = "pause"
	escape.pressed = true
	app._input(escape)
	check(app.mode == "play" and not paused and app.player.controls_enabled and not mara.talking, "Escape closes nested dialogue without pausing")
	app._input(escape)
	check(app.mode == "pause" and paused, "Next Escape opens pause after dialogue closes")
	app._input(escape)
	check(app.mode == "play" and not paused, "Escape resumes from pause")
	check(mara.command("isolation").contains("No reachable route"), "Locked isolation task rejected")
	check(mara.command("repair").contains("component"), "Repair explains missing prerequisite")
	check(eli.command("repair").contains("Power"), "Authorization explains missing prerequisite")
	mara.command("station")
	eli.command("station")
	await frames(15)
	initial = mara.position
	app.pause_game()
	await frames(60)
	check(mara.position == initial, "Pause freezes NPC task travel")
	app.resume()
	await frames(700)
	print("Stations: ", mara.position, " ", mara.state, " / ", eli.position, " ", eli.state)
	check(mara.task_ready and mara.position.distance_to(Vector3(13, 0, -12)) < 0.6, "Mara walks to maintenance station")
	check(eli.task_ready and eli.position.distance_to(Vector3(-2, 0, -12)) < 0.6, "Eli walks to security station")
	mara.command("wait")
	initial = mara.position
	await frames(60)
	check(not mara.task_ready and mara.position == initial, "Wait clears readiness and holds position")
	app.player.position = Vector3(0, 0.05, 1)
	mara.command("follow")
	eli.command("follow")
	await frames(700)
	print("Follow: ", mara.position, " ", mara.state, " / ", eli.position, " ", eli.state)
	check(mara.position.distance_to(mara.follow_target()) < 1, "Mara follows around doorway and obstacles")
	check(eli.position.distance_to(eli.follow_target()) < 1, "Eli follows to separate offset")
	check(mara.position.distance_to(eli.position) > 0.65, "NPCs do not overlap at shared destination")
	var mara_stopped: Vector3 = mara.position
	var eli_stopped: Vector3 = eli.position
	for turn in 4:
		app.player.rotation.y += PI / 2
		await frames(60)
	check(mara.position.distance_to(mara_stopped) < 0.05 and eli.position.distance_to(eli_stopped) < 0.05, "Turning in place does not move followers out of view")
	app.player.rotation.y = 0
	app.open_dialogue(mara)
	for page in ["root", "help", "questions", "situation", "expertise"]:
		app.topic(page)
		var choices := 0
		for child in app.choices.get_children():
			if child is Button:
				choices += 1
				check(child.text != "End conversation", "Escape replaces exit button: " + page)
		check(choices > 0 and choices <= 3, "Limited horizontal dialogue options: " + page)
	app.close_dialogue()
	Input.action_press("walk_forward")
	await frames(220)
	Input.action_release("walk_forward")
	await frames(200)
	check(mara.position.distance_to(mara.follow_target()) < 1 and eli.position.distance_to(eli.follow_target()) < 1, "Both NPCs track a walking player through a doorway")
	mara.command("station")
	await frames(20)
	mara.command("wait")
	initial = mara.position
	await frames(60)
	check(mara.position == initial and not mara.task_ready, "Travel interruption cancels readiness and motion")
	# Enclose Mara after path planning to force physical-obstruction recovery.
	for offset in [Vector3(0.7, 0, 0), Vector3(-0.7, 0, 0), Vector3(0, 0, 0.7), Vector3(0, 0, -0.7)]:
		var size := Vector3(0.2, 2, 1.6) if offset.x != 0 else Vector3(1.6, 2, 0.2)
		var barrier = app.world.box(mara.position + offset + Vector3(0, 1, 0), size, Color.GRAY)
		barrier.add_to_group("test_barriers")
	mara.command("station")
	await frames(500)
	check(mara.state == "wait" and not mara.task_ready, "Persistent obstruction cancels travel safely")
	for barrier in get_nodes_in_group("test_barriers"):
		barrier.queue_free()
	await frames(3)
	mara.command("station")
	await frames(700)
	check(mara.task_ready, "Clearing obstacle and reassigning recovers without restart")
	# Open one gate and rebake; the other must remain disconnected.
	app.world.gates[0].queue_free()
	await frames(3)
	app.world.build_navigation()
	await frames(5)
	check(not app.world.route(Vector3.ZERO, Vector3(0, 0, -24)).is_empty(), "Rebake connects opened Gate A")
	check(app.world.route(Vector3.ZERO, Vector3(0, 0, -36)).is_empty(), "Rebake preserves locked Gate B")
	app.show_menu()
	await frames(3)
	app.start(true)
	await frames(10)
	mara = app.world.npcs[0]
	eli = app.world.npcs[1]
	mara.command("isolation")
	eli.command("isolation")
	await frames(1100)
	check(mara.task_ready and eli.task_ready, "Both NPCs traverse open gates to isolation anchors")
	app.open_dialogue(mara)
	app.order("follow")
	check(app.mode == "play" and not mara.talking and mara.state == "follow", "Command closes dialogue and releases NPC immediately")
	app.notice.text = ""
	app.notice_queue.clear()
	app.show_notice("Mara: Ready.")
	app.update_notice(0.1)
	check(app.notice.visible_characters == 4 and app.notice_time == 5, "Bottom feedback types before hold timer starts")
	app.update_notice(1)
	app.update_notice(4.9)
	check(not app.notice.text.is_empty(), "Completed feedback remains for five seconds")
	app.show_notice("Eli: Understood.")
	app.update_notice(0.11)
	check(app.notice.text == "Eli: Understood." and app.notice.visible_characters == 0, "Overlapping feedback queues without erasing current line")
	app.update_notice(1)
	app.update_notice(5)
	check(app.notice.text.is_empty(), "Feedback disappears after hold timer")
	app.show_menu()
	await frames(3)
	print("M2 CHECKS COMPLETE: %d failures" % failures)
	quit(1 if failures else 0)
