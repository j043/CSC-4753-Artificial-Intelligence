extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)
	else:
		print("PASS: " + message)
func frames(count: int) -> void:
	for i in count:
		await physics_frame
func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.start(false)
	await frames(10)
	var door = app.world.door_visuals[0]
	app.player.position = Vector3(0, 0.05, -16)
	app.player.camera.rotation = Vector3.ZERO
	await frames(3)
	check(app.player.interaction_target() == app.world.gates[0], "Closed sliding gate retains inspection prompt")
	app.world.unlock_gate(0)
	await frames(20)
	var partial: float = door.leaves[0].position.x
	check(partial < -0.75 and partial > -2.28, "Door visibly slides through intermediate positions")
	app.pause_game()
	await frames(20)
	check(is_equal_approx(partial, door.leaves[0].position.x), "Pause freezes sliding door")
	app.resume()
	await frames(90)
	check(is_equal_approx(door.leaves[0].position.x, -2.28), "Panel retracts fully outside doorway")
	check(not app.world.route(Vector3(0, 0, -16), Vector3(0, 0, -21)).is_empty(), "Open door navigation crosses threshold")
	Input.action_press("walk_forward")
	await frames(65)
	Input.action_release("walk_forward")
	check(app.player.position.z < -19, "Player walks through opened panel collision")
	app.start(true)
	await frames(10)
	check(app.world.maintenance_visual.opened and app.world.door_visuals[1].opened, "Tour/checkpoint assemblies start fully open")
	check(app.shadow.body.get_child_count() == 2, "Original humanoid silhouette restored")
	app.show_menu()
	await frames(3)
	print("Door/humanoid checks: %d failures" % failures)
	quit(failures)
