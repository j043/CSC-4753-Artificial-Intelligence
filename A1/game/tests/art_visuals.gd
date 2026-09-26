extends SceneTree
func _initialize() -> void: call_deferred("run")
func capture(file: String) -> void:
	for i in 12: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../builds/" + file))
func run() -> void:
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.start(true)
	for npc in app.world.npcs:
		npc.human.rotation.y = PI
	await capture("art-security.png")
	app.player.position = Vector3(0, 0.05, 2.8)
	app.player.camera.look_at(app.world.npcs[0].position + Vector3(0, 1.5, 0))
	await capture("art-mara.png")
	app.player.camera.look_at(app.world.npcs[1].position + Vector3(0, 1.5, 0))
	await capture("art-eli.png")
	app.player.camera.rotation = Vector3.ZERO
	for sample in [["control", Vector3(0, 0.05, -10), Vector3(-3.6, 1.5, -14)], ["coolant", Vector3(0, 0.05, -20), Vector3(-3, 1.5, -25)], ["reactor", Vector3(0, 0.05, -36), Vector3(0, 1.6, -46)], ["workshop", Vector3(12, 0.05, -11), Vector3(15, 1.6, -15)]]:
		app.player.position = sample[1]
		app.player.camera.look_at(sample[2])
		await capture("art-" + sample[0] + ".png")
	app.show_menu()
	for i in 8: await process_frame
	quit()
