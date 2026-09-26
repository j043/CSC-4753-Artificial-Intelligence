extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.preferences.path = "res://../builds/m5-profile-settings.cfg"
	app.preferences.low = true
	app.preferences.resolution = 0
	app.preferences.brightness = 1
	app.preferences.volume = 0
	app.preferences.apply(app, true)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	app.start(true)
	var report := "Godot %s\nCPU: %s\nGPU: %s\nMemory: %s\nOS: %s\nLow preset, 1280x720, Compatibility, VSync disabled. Three-second rendered-frame samples per location; not full-playthrough performance.\n" % [Engine.get_version_info().string, OS.get_processor_name(), RenderingServer.get_video_adapter_name(), str(OS.get_memory_info()), OS.get_distribution_name()]
	for sample in [["security", Vector3(0, 0.05, 3)], ["maintenance", Vector3(12, 0.05, -12)], ["observation", Vector3(0, 0.05, -36)], ["escape", Vector3(0, 0.05, -24)]]:
		app.player.position = sample[1]
		if sample[0] == "escape":
			app.tour = false
			app.progress.stage = 6
			app.narrative.start_alarm()
			for npc in app.world.npcs:
				npc.command("evacuate")
		for i in 60: await process_frame
		var timings: Array[float] = []
		var before := Time.get_ticks_usec()
		var sample_start := before
		while Time.get_ticks_usec() - sample_start < 3000000:
			await RenderingServer.frame_post_draw
			var now := Time.get_ticks_usec()
			timings.append((now - before) / 1000.0)
			before = now
		assert(app.mode == "play" and not paused, "Profile must sample live gameplay")
		var total := 0.0
		for value in timings: total += value
		timings.sort()
		report += "%s: average %.1f FPS; p95 %.2f ms; worst %.2f ms\n" % [sample[0], timings.size() * 1000.0 / total, timings[int(timings.size() * 0.95)], timings[-1]]
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/m5-" + sample[0] + ".png"))
	app.pause_game()
	app.show_settings()
	for size in [Vector2i(1280,720), Vector2i(1920,1080)]:
		root.size = size
		for i in 8: await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/m5-settings-%d.png" % size.x))
	var file := FileAccess.open("res://../builds/m5-profile.txt", FileAccess.WRITE)
	file.store_string(report)
	file.close()
	print(report)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../licenses"))
	var license_file := FileAccess.open("res://../licenses/Godot-and-third-party.txt", FileAccess.WRITE)
	license_file.store_string("License information reported by the bundled Godot engine.\n\n" + Engine.get_license_text() + "\n\n")
	for entry in Engine.get_copyright_info():
		license_file.store_string(str(entry) + "\n")
	for name in Engine.get_license_info():
		license_file.store_string("\n" + name + "\n" + Engine.get_license_info()[name] + "\n")
	license_file.close()
	app.show_menu()
	for i in 20: await process_frame
	quit()
