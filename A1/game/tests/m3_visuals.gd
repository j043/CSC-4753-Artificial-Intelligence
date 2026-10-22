extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func capture(file: String) -> void:
	for i in 10:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/" + file))
func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.start(false)
	await capture("m3-objective.png")
	app.open_dialogue(app.world.npcs[0])
	app.topic("help")
	await capture("m3-dialogue.png")
	app.close_dialogue()
	app.progress.stage = 5
	app.progress.warning_known = true
	await capture("m3-readiness.png")
	app.show_menu()
	quit()
