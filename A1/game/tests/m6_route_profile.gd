extends "res://tests/m3_checks.gd"
var samples: Array[float] = []
var configured := false
var elapsed := 0.0
func _process(delta: float) -> bool:
	if is_instance_valid(app) and not configured:
		app.preferences.low = true
		app.preferences.resolution = 0
		app.preferences.volume = 0
		app.preferences.apply(app, true)
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 0
		configured = true
	if configured and is_instance_valid(app.world) and app.mode == "play" and not paused:
		samples.append(delta * 1000)
		elapsed += delta
	return false
func run() -> void:
	await super.run()
	if samples.is_empty(): return
	samples.sort()
	var report := "Approved M5 baseline: 281996e\nAutomated M3 route, rendered Low 1280x720, VSync off. Scripted player relocations; real NPC traversal. Excludes menus/paused frames. Not a human full-route benchmark or first-playthrough timing.\nCPU: %s\nGPU: %s\nFrames: %d; gameplay sample seconds: %.2f\nMean FPS: %.1f; median frame ms: %.2f; p95 frame ms: %.2f; p99 frame ms: %.2f; worst frame ms: %.2f\nProgression checks: %d; failures: %d\n" % [OS.get_processor_name(), RenderingServer.get_video_adapter_name(), samples.size(), elapsed, samples.size() / elapsed, samples[samples.size()/2], samples[int(samples.size()*0.95)], samples[int(samples.size()*0.99)], samples.back(), checks, failures]
	var file := FileAccess.open("res://../builds/m6-route-performance.txt", FileAccess.WRITE)
	file.store_string(report)
	print(report)