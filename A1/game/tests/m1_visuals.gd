extends SceneTree
## Optional real-renderer captures, saved outside the source tree.
func _initialize() -> void:
	call_deferred("run")

func capture(filename: String) -> void:
	for i in 5:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/" + filename))

func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await capture("m1-menu.png")
	app.start(true)
	await capture("m1-security.png")
	app.player.position = Vector3(0, 0.05, -21)
	await capture("m1-coolant.png")
	app.pause_game()
	await capture("m1-pause.png")
	app.show_menu()
	quit()
