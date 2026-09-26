extends SceneTree
var app: Control
var failures := 0
var checks := 0
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("FAIL: " + description)
	else:
		print("PASS: " + description)
func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame
func object_named(id: String) -> Object:
	for child in app.world.get_children():
		if child.get_meta("object_id", "") == id:
			return child
	return null
func drain() -> void:
	# Advance subtitle reading time, preserving the production scheduler/effects.
	for i in 40:
		app.update_notice(100)
		app.progress.tick()
		await frames(1)
func run() -> void:
	app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.start(false)
	await frames(10)
	var p = app.progress
	var mara = app.world.npcs[0]
	var eli = app.world.npcs[1]
	var bench = object_named("Maintenance workbench")
	var console = object_named("Chamber control console")
	var lift = object_named("Lift call panel")
	p.interact(bench)
	p.interact(console)
	p.interact(lift)
	check(p.stage == 1 and p.component == "available", "Early interactions preserve objectives and component")
	check(mara.command("station").contains("component"), "Early repair explains component prerequisite")
	check(eli.command("station").contains("Power"), "Early access explains power prerequisite")
	app.open_dialogue(mara)
	app.close_dialogue()
	app.open_dialogue(eli)
	await drain()
	check(p.stage == 2 and p.completed.is_empty(), "Meeting both unlocks pickup while exchange waits for conversation")
	app.close_dialogue()
	app.replace_interaction_feedback()
	p.tick()
	check(app.notice_is_exchange and p.line_index == 1, "Briefing line begins on the shared subtitle channel")
	app.interact_object(bench)
	check(app.notice.text.begins_with("Replacement component collected.") and p.line_index == 0 and p.completed.is_empty(), "Clicked feedback replaces story line without silently completing it")
	app.open_dialogue(mara)
	check(app.menu.get_child(1).text.contains("You've got the component"), "Mara immediately acknowledges pickup before briefing finishes")
	check(p.command_reason(mara, "station") == "", "Repair is available immediately after pickup")
	app.close_dialogue()
	await drain()
	check(p.stage == 3 and p.completed.count("briefing") == 1, "Late briefing completion cannot regress collected component objective")
	p.interact(bench)
	p.interact(bench)
	check(p.stage == 3 and p.component == "held", "Repeated pickup gives one held component")
	mara.command("station")
	await frames(90)
	mara.command("wait")
	await frames(10)
	check(p.stage == 3 and p.component == "held", "Interrupted repair retains component")
	mara.command("station")
	await frames(850)
	check(p.stage == 4 and p.component == "consumed", "Actual Mara arrival restores power once")
	await frames(5)
	check(not app.world.route(Vector3.ZERO, Vector3(0, 0, -24)).is_empty(), "Power opens Gate A navigation")
	check(app.world.route(Vector3.ZERO, Vector3(0, 0, -36)).is_empty(), "Gate B remains blocked before Eli work")
	eli.command("station")
	await frames(600)
	await drain()
	await frames(5)
	check(p.stage == 5 and "access" in p.completed, "Access exchange completes Eli authorization")
	check(not app.world.route(Vector3.ZERO, Vector3(0, 0, -36)).is_empty(), "Authorization opens Gate B navigation")
	p.interact(console)
	check(p.stage == 5 and p.isolation_missing().contains("Mara") and p.isolation_missing().contains("Eli"), "Premature isolation names both missing participants")
	app.player.position = Vector3(0, 0.05, -24)
	await drain()
	check(p.warning_known and p.hint().contains("imitated"), "Remote labeled warning changes retained hint")
	await drain()
	check(p.completed.size() == 3, "Three distinct exchanges are one-shot")
	mara.command("isolation")
	eli.command("isolation")
	await frames(1000)
	check(p.isolation_missing() == "", "Both NPCs reach real isolation stations")
	mara.command("wait")
	p.interact(console)
	check(p.stage == 5 and p.isolation_missing().contains("Mara") and not p.isolation_missing().contains("Eli"), "Cancellation revokes only Mara readiness and prevents isolation")
	mara.command("isolation")
	await frames(10)
	p.interact(console)
	check(app.mode == "decision", "Reassignment permits final decision")
	app.narrative.choose("isolate")
	check(p.stage == 6, "Survivor choice commits cooperative isolation")
	p.interact(lift)
	check(p.stage == 6, "Lift waits for survivors")
	var before: Vector3 = mara.position
	app.pause_game()
	await frames(30)
	check(mara.position == before, "Pause freezes evacuation")
	app.resume()
	# Flow fixture waits inside the safe lift; chase navigation has its own tests.
	app.player.position = Vector3(-13, 0.05, -2)
	await frames(1500)
	check(p.ready_for(mara, "evacuate") and p.ready_for(eli, "evacuate"), "Both NPCs navigate entire evacuation route")
	app.player.position = Vector3(-13, 0.05, -2)
	p.interact(lift)
	check(p.stage == 7 and app.mode == "success", "Lift completes O6 and displays success")
	app.show_menu()
	app.start(false)
	await frames(10)
	check(app.progress.stage == 1 and app.progress.component == "available" and app.progress.completed.is_empty(), "Fresh run resets objectives item and exchanges")
	check(app.world.gates.size() == 2 and app.world.npcs[0].state == "idle", "Fresh run resets gates and NPC behavior")
	print("M3: %d checks, %d failures" % [checks, failures])
	app.show_menu()
	await frames(2)
	# Let the audio mixer release stopped playback buffers before engine teardown.
	await create_timer(0.2).timeout
	quit(1 if failures else 0)
