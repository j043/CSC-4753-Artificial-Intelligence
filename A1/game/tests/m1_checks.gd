extends SceneTree
## Run with --headless --path A1/game --script res://tests/m1_checks.gd
var app: Control
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: " + description)
	else:
		push_error("FAIL: " + description)
		failures += 1

func frames(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame

func walk(action: String, count: int, sprint := false) -> void:
	Input.action_press(action)
	if sprint:
		Input.action_press("sprint")
	await frames(count)
	Input.action_release(action)
	Input.action_release("sprint")
	await frames(2)

func reach(destination: Vector3) -> void:
	for i in 1200:
		var offset: Vector3 = destination - app.player.position
		if Vector2(offset.x, offset.z).length() < 0.15:
			break
		for action in ["walk_left", "walk_right", "walk_forward", "walk_back"]:
			Input.action_release(action)
		if absf(offset.x) > 0.1:
			Input.action_press("walk_right" if offset.x > 0 else "walk_left")
		if absf(offset.z) > 0.1:
			Input.action_press("walk_back" if offset.z > 0 else "walk_forward")
		await frames(1)
	for action in ["walk_left", "walk_right", "walk_forward", "walk_back"]:
		Input.action_release(action)
	check(Vector2(app.player.position.x - destination.x, app.player.position.z - destination.z).length() < 0.2, "Walk route to " + str(destination))

func run() -> void:
	app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await frames(2)
	check(app.mode == "menu", "Main menu starts without gameplay")
	app.start(false)
	await frames(5)
	check(app.world.gates.size() == 2, "Both initial gates present")
	await walk("walk_forward", 500, true)
	check(app.player.position.z > -17.6 and app.player.position.z < -17.4, "Sprinting cannot pass Gate A")
	check(app.player.interaction_target() == app.world.gates[0], "Gate A is interactable in range")
	app.player.position = Vector3(0, 0.05, -20)
	await walk("walk_forward", 200, true)
	check(app.player.position.z > -29.6 and app.player.position.z < -29.4, "Sprinting cannot pass Gate B")
	app.player.position = Vector3(0, 0.05, 3)
	await frames(3)
	await walk("walk_back", 120, true)
	check(app.player.position.z < 5.7, "Outer wall prevents leaving level")
	app.player.position = Vector3(-3.6, 0.05, 0)
	await walk("walk_forward", 100, true)
	check(app.player.position.z > -1.7, "Desk collision blocks sprinting")
	check(app.player.interaction_target() == null, "Ray above desk does not offer false interaction")
	app.player.camera.look_at(Vector3(-3.6, 0.8, -2.5))
	check(app.player.interaction_target() != null, "Looking at desk offers interaction")
	app.player.position = Vector3(-3.6, 0.05, 3)
	app.player.camera.look_at(Vector3(-3.6, 0.8, -2.5))
	check(app.player.interaction_target() == null, "Out-of-range desk is not interactable")
	app.player.camera.rotation = Vector3.ZERO
	app.player.position = Vector3(0, 0.05, 3)
	await frames(3)
	var before: Vector3 = app.player.position
	await walk("walk_forward", 60)
	var walked: float = before.z - app.player.position.z
	app.player.position = before
	await walk("walk_forward", 60, true)
	var sprinted: float = before.z - app.player.position.z
	check(walked > 3.2 and walked < 3.7 and sprinted > walked * 1.5, "Walk and held sprint have expected speeds")
	var toggle := InputEventAction.new()
	toggle.action = "flashlight"
	toggle.pressed = true
	app.player._unhandled_input(toggle)
	check(not app.player.light.visible, "F action switches flashlight off")
	app.player._unhandled_input(toggle)
	check(app.player.light.visible, "F action switches flashlight on")
	app.pause_game()
	before = app.player.position
	await walk("walk_forward", 30)
	check(app.player.position == before and paused, "Pause freezes physics despite held movement")
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Pause releases pointer")
	app.resume()
	check(not paused and app.mode == "play", "Resume restores gameplay")
	app.show_menu()
	await frames(2)
	app.start(true)
	await frames(3)
	check(app.world.gates.is_empty(), "Tour opens both gates")
	await reach(Vector3(0, 0, -12))
	await reach(Vector3(12, 0, -12))
	check(app.world.area_name(app.player.position).contains("MAINTENANCE"), "Workshop label matches location")
	await reach(Vector3(0, 0, -12))
	await reach(Vector3(0, 0, -24))
	await reach(Vector3(0, 0, -36))
	await reach(Vector3(0, 0, 0))
	await reach(Vector3(-12, 0, 0))
	await reach(Vector3(0, 0, 0))
	await reach(Vector3(0, 0, 3))
	check(absf(app.player.position.y) < 0.1, "Floor collision holds across full route")
	app.show_menu()
	await frames(2)
	app.start(false)
	await frames(2)
	check(app.world.gates.size() == 2 and app.player.position.z > 2.9, "New run resets spawn and gates after tour")
	app.show_menu()
	await frames(2)
	print("M1 CHECKS COMPLETE: %d failures" % failures)
	quit(1 if failures else 0)
