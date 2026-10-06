extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func capture(file: String) -> void:
	for i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/" + file))
func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.start(true)
	app.tour = false
	app.progress.stage = 5
	app.player.position = Vector3(0, 0.05, -36)
	app.narrative.tick(0)
	await capture("m4-figure.png")
	app.narrative.collect("Isolation protocol")
	await capture("m4-journal.png")
	app.resume()
	for i in 2:
		var npc = app.world.npcs[i]
		npc.position = Vector3(-2 if i == 0 else 2, 0.05, -38)
		npc.destination = npc.position
		npc.state = "perform_task"
		npc.task_id = "isolation"
		npc.task_ready = true
	app.narrative.save_checkpoint()
	app.show_decision()
	await capture("m4-decision.png")
	root.size = Vector2i(1920, 1080)
	await capture("m4-decision-1080.png")
	app.narrative.choose("isolate")
	await capture("m4-escape.png")
	app.show_menu()
	for i in 8:
		await process_frame
	quit()
