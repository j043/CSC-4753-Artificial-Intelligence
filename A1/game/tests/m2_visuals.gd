extends SceneTree
func _initialize() -> void:
	call_deferred("run")

func capture(filename: String) -> void:
	for i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/" + filename))

func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await capture("m2-menu.png")
	app.start(false)
	await capture("m2-survivors.png")
	app.open_dialogue(app.world.npcs[0])
	await capture("m2-dialogue.png")
	app.topic("commands")
	await capture("m2-commands.png")
	app.pause_game()
	await capture("m2-pause.png")
	app.resume()
	await capture("m2-resume-dialogue.png")
	root.size = Vector2i(1920, 1080)
	await capture("m2-dialogue-1080p.png")
	app.order("isolation")
	app.update_notice(10)
	await capture("m2-bottom-feedback.png")
	app.show_menu()
	quit()
