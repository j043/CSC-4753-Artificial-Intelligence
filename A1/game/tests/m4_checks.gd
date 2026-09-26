extends SceneTree
var app: Control
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	if value:
		print("PASS: " + message)
	else:
		failures += 1
		push_error("FAIL: " + message)
func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame
func run() -> void:
	app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.preferences.path = "res://../builds/m4-test-settings.cfg"
	app.start(false)
	await frames(5)
	check(app.narrative.checkpoint.is_empty(), "No checkpoint at new game")
	for id in app.narrative.CLUES:
		app.narrative.collect(id)
		check(app.mode == "journal" and paused and not app.player.controls_enabled, "Clue opens readable paused journal: " + id)
		app.resume()
	app.narrative.collect("Voice warning")
	check(app.narrative.clues.size() == 3, "Rereading never duplicates clues")
	app.resume()
	app.progress.stage = 5
	app.progress.component = "consumed"
	app.progress.warning_known = true
	app.progress.completed.assign(["briefing", "access", "warning"])
	app.world.unlock_gate(0)
	await frames(5)
	app.world.unlock_gate(1)
	await frames(5)
	app.player.position = Vector3(0, 0.05, -24)
	app.narrative.tick(0)
	check("lights" in app.narrative.fired and app.narrative.light_time > 0, "Occupied gallery triggers lighting event")
	app.narrative.tick(3)
	app.narrative.tick(0)
	check(app.narrative.fired.count("lights") == 1 and app.narrative.light_time == 0, "Lighting restores and does not retrigger")
	app.player.position = Vector3(0, 0.05, -36)
	app.player.rotation.y = 0
	app.narrative.tick(0)
	check(is_instance_valid(app.narrative.figure), "Window figure appears when approached facing window")
	app.narrative.tick(2)
	await frames(2)
	check(not is_instance_valid(app.narrative.figure) and app.narrative.fired.count("figure") == 1, "Window figure vanishes once")
	for i in 2:
		var npc = app.world.npcs[i]
		npc.position = Vector3(-2, 0.05, -36) if i == 0 else Vector3(2, 0.05, -38)
		npc.destination = npc.position
		npc.state = "perform_task"
		npc.task_id = "isolation"
		npc.task_ready = true
	app.player.position = Vector3(2, 0.05, -35)
	app.narrative.save_checkpoint()
	var baseline: Dictionary = app.narrative.checkpoint.duplicate(true)
	app.show_decision()
	check(paused and app.narrative.remaining == 120 and app.progress.stage == 5, "Pre-decision checkpoint freezes readiness with full inactive timer")
	app.confirm_reconnect()
	check(app.mode == "decision" and app.narrative.decision == "", "Reconnect requires explicit confirmation")
	app.narrative.choose("reconnect")
	check(app.mode == "ending" and app.progress.stage == 5 and app.narrative.decision == "reconnect", "Reconnect produces distinct breach ending without isolation")
	for iteration in 3:
		app.retry_checkpoint()
		await frames(5)
		check(app.mode == "decision" and app.progress.stage == 5 and app.narrative.remaining == 120 and app.narrative.decision == "", "Retry resets decision and timer: " + str(iteration))
		check(app.player.position == baseline.player and app.progress.isolation_missing() == "", "Retry restores player and both ready NPCs: " + str(iteration))
		check(app.narrative.clues.size() == 3 and app.narrative.fired == baseline.fired and app.world.gates.is_empty(), "Retry restores notes/events and open gates: " + str(iteration))
		check(not is_instance_valid(app.narrative.alarm) and app.notice.text.is_empty(), "Retry clears alarm and stale subtitle state: " + str(iteration))
		app.narrative.choose("isolate")
		check(app.progress.stage == 6 and app.narrative.alarm.playing and app.narrative.fired.count("alarm") == 1, "Isolation triggers alarm and evacuation once: " + str(iteration))
		app.pause_game()
		var remaining: float = app.narrative.remaining
		await frames(20)
		check(app.narrative.remaining == remaining, "Pause freezes countdown: " + str(iteration))
		app.resume()
		app.narrative.tick(121)
		check(app.mode == "ending" and app.narrative.remaining == 0 and not app.narrative.alarm.playing, "Timeout shows failure and stops alarm: " + str(iteration))
	app.retry_checkpoint()
	await frames(5)
	app.narrative.choose("isolate")
	app.retry_checkpoint()
	app.narrative.choose("isolate")
	await frames(10)
	check(app.world.npcs[0].task_id == "evacuate" and app.world.npcs[1].task_id == "evacuate", "Immediate retry choice waits for rebuilt navigation and then evacuates")
	app.pause_game()
	for control in app.menu.get_children():
		if control is HSlider:
			control.value = 0
	check(AudioServer.get_bus_volume_linear(0) == 0, "Pause volume control mutes the Master bus used by the alarm")
	AudioServer.set_bus_volume_linear(0, 1)
	app.resume()
	app.narrative.remaining = 0
	for npc in app.world.npcs:
		npc.task_id = "evacuate"
		npc.task_ready = true
		npc.state = "perform_task"
		npc.destination = npc.position
	for child in app.world.get_children():
		if child.get_meta("object_id", "") == "Lift call panel":
			app.progress.interact(child)
	check(app.mode == "ending" and app.progress.stage == 6, "Zero-time lift cannot win timeout race")
	app.show_menu()
	app.start(false)
	await frames(5)
	check(app.narrative.clues.is_empty() and app.narrative.fired.is_empty() and app.narrative.checkpoint.is_empty(), "New game clears clues events and checkpoint")
	app.show_menu()
	await frames(5)
	print("M4: %d checks, %d failures" % [checks, failures])
	# Let the audio mixer release stopped playback buffers before engine teardown.
	await create_timer(0.2).timeout
	quit(1 if failures else 0)
