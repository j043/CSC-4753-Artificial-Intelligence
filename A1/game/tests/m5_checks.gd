extends SceneTree
var app: Control
var failures := 0
var checks := 0
func _initialize() -> void:
	call_deferred("run")
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
	app.preferences.path = "res://../builds/m5-test-settings.cfg"
	app.show_settings()
	check(app.mode == "settings" and paused, "Main menu settings opens safely without a world")
	app.change_setting("sensitivity", 1.5)
	app.change_setting("volume", 0.35)
	app.change_setting("brightness", 1.3)
	app.change_setting("low", true)
	app.change_setting("resolution", 2)
	var copy = app.Preferences.new()
	copy.path = app.preferences.path
	copy.load_settings()
	check(copy.sensitivity == 1.5 and copy.volume == 0.35 and copy.brightness == 1.3 and copy.low and copy.resolution == 2, "All preferences persist through config save and reload")
	app.close_settings()
	check(app.mode == "menu" and not paused, "Settings Back returns to main menu")
	app.start(false)
	await frames(5)
	check(is_equal_approx(app.player.sensitivity, 0.00345) and not app.player.light.shadow_enabled, "New run applies sensitivity and low preset")
	for child in app.world.get_children():
		if child is WorldEnvironment:
			check(is_equal_approx(child.environment.ambient_light_energy, 0.091), "Brightness changes ambient lighting")
	app.open_dialogue(app.world.npcs[0])
	app.pause_game()
	app.show_settings()
	app.change_setting("volume", 0)
	check(AudioServer.get_bus_volume_linear(0) == 0, "Mute applies to all Master-routed audio")
	app.close_settings()
	check(app.mode == "pause" and paused, "Settings returns to paused game")
	app.resume()
	check(app.mode == "dialogue" and not app.player.controls_enabled and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Settings preserves the conversation and its input mode")
	app.close_dialogue()
	app.progress.stage = 6
	app.pause_game()
	app.show_settings()
	var remaining: float = app.narrative.remaining
	var position: Vector3 = app.world.npcs[0].position
	await frames(30)
	check(app.narrative.remaining == remaining and app.world.npcs[0].position == position, "Settings freezes countdown and NPCs")
	app.change_setting("low", false)
	check(app.player.light.shadow_enabled, "Standard quality restores flashlight shadows")
	app.show_menu()
	app.start(false)
	await frames(5)
	check(app.preferences.volume == 0 and app.preferences.sensitivity == 1.5 and app.progress.stage == 1, "New game resets story but retains preferences")
	app.show_menu()
	await frames(5)
	print("M5: %d checks, %d failures" % [checks, failures])
	await create_timer(0.2).timeout
	quit(1 if failures else 0)
