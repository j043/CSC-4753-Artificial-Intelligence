extends SceneTree
var app: Control
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(value: bool, message: String) -> void:
	checks += 1
	if value: print("PASS: " + message)
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
	app.start(false)
	await frames(5)
	app.shadow.rng.seed = 42
	check(app.shadow.try_sighting(), "Visible reachable exploration anchor produces a sighting")
	check(not app.shadow.chasing and app.shadow.sightings == 1 and app.mode == "play", "Exploration sighting is harmless")
	var seconds: float = app.shadow.sighting_time
	app.pause_game()
	await frames(30)
	check(app.shadow.sighting_time == seconds, "Pause freezes sighting lifetime")
	app.resume()
	await frames(130)
	check(not is_instance_valid(app.shadow.sighting), "Sighting disappears after a brief appearance")
	app.progress.stage = 6
	app.player.position = Vector3(0, 0.05, 3)
	app.shadow.start_chase()
	app.shadow.grace = 0
	await frames(60)
	check(app.shadow.position.z < -30, "Chase cannot route through locked gates")
	app.show_menu()
	app.start(true)
	app.tour = false
	await frames(5)
	app.progress.stage = 5
	app.progress.component = "consumed"
	app.progress.completed.assign(["briefing", "access", "warning"])
	app.player.position = Vector3(2, 0.05, -35)
	for i in 2:
		var npc = app.world.npcs[i]
		npc.position = Vector3(-2 if i == 0 else 2, 0.05, -38)
		npc.destination = npc.position
		npc.state = "perform_task"
		npc.task_id = "isolation"
		npc.task_ready = true
	app.narrative.save_checkpoint()
	app.show_decision()
	app.narrative.choose("isolate")
	check(app.shadow.chasing and app.shadow.grace == 6, "Isolation starts pursuit with a six-second head start")
	app.pause_game()
	var at: Vector3 = app.shadow.position
	await frames(30)
	check(app.shadow.position == at and app.shadow.grace == 6, "Pause freezes shadow and head start")
	app.resume()
	app.player.position = Vector3(0, 0.05, 3)
	for i in 1600:
		await frames(1)
		if app.mode == "ending": break
	check(app.mode == "ending" and app.menu.get_child(0).text == "YOU DIED", "Shadow follows real corridor navigation and catches a stationary player")
	check(app.shadow.position.z > -2, "Pursuer physically traverses observation gallery and control")
	app.retry_checkpoint()
	await frames(5)
	check(not app.shadow.chasing and app.shadow.grace == 6 and not app.shadow.body.visible, "Death retry resets shadow state")
	app.narrative.choose("isolate")
	# Walk the actual player with normal sprint input along the evacuation corridor.
	for destination in [Vector3(0, 0, -34), Vector3(0, 0, -12), Vector3(0, 0, 0), Vector3(-13, 0, 0)]:
		for i in 400:
			var direction: Vector3 = destination - app.player.position
			direction.y = 0
			if direction.length() < 0.45 or app.mode != "play": break
			app.player.rotation.y = atan2(-direction.x, -direction.z)
			Input.action_press("walk_forward")
			Input.action_press("sprint")
			await frames(1)
		Input.action_release("walk_forward")
		Input.action_release("sprint")
	check(app.mode == "play" and app.shadow.in_lift(), "Normal sprint controls outrun the chase all the way to the lift")
	app.shadow.position = app.player.position + Vector3(0.4, 0, 0)
	app.shadow.grace = 0
	await frames(10)
	check(app.mode == "play" and not app.shadow.caught(), "Lift interior protects player while waiting for survivors")
	app.player.position = Vector3(-10, 0.05, 0)
	app.shadow.position = Vector3(-9.5, 0.05, 0)
	await frames(2)
	check(app.mode == "ending", "Leaving the safe lift permits lethal capture")
	app.retry_checkpoint()
	await frames(5)
	app.narrative.choose("reconnect")
	check(not app.shadow.chasing and app.mode == "ending", "Breach ending never starts a chase")
	app.show_menu()
	app.start(false)
	await frames(5)
	check(not app.shadow.chasing and app.shadow.sightings == 0, "New game resets sightings and pursuit")
	app.show_menu()
	await frames(5)
	print("Shadow: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
