extends SceneTree
var failures := 0
func _initialize(): call_deferred("run")
func frames(count):
	for i in count: await physics_frame
func check(value, message):
	if value: print("PASS: " + message)
	else:
		failures += 1
		push_error(message)
func run():
	var app = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	app.start(true)
	await frames(10)
	var sounds = app.sounds
	check(sounds.hum.playing and sounds.hum.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Ambient loop starts with gameplay")
	await frames(35)
	check(sounds.step_count == 0, "Standing still produces no footsteps")
	Input.action_press("walk_forward")
	await frames(60)
	Input.action_release("walk_forward")
	var walking = sounds.step_count
	check(walking >= 2, "Actual walking produces footsteps")
	Input.action_press("walk_forward")
	Input.action_press("sprint")
	await frames(60)
	Input.action_release("sprint")
	Input.action_release("walk_forward")
	check(sounds.step_count - walking > walking, "Sprinting produces faster cadence")
	var steps = sounds.step_count
	app.pause_game()
	Input.action_press("walk_forward")
	await frames(40)
	check(sounds.step_count == steps, "Pause prevents footsteps")
	app.resume()
	Input.action_release("walk_forward")
	app.player.position = Vector3(0, 0.05, 5.5)
	Input.action_press("walk_back")
	await frames(60)
	steps = sounds.step_count
	await frames(60)
	Input.action_release("walk_back")
	check(sounds.step_count == steps, "Pushing against a wall produces no footsteps")
	app.narrative.start_alarm()
	check(app.narrative.alarm.volume_db == -6, "Alarm is ten decibels louder")
	check(sounds.hum.bus == &"Master" and sounds.footsteps.bus == &"Master" and app.narrative.alarm.bus == &"Master", "All new audio follows Master volume")
	app.show_menu()
	await frames(5)
	print("Audio checks: %d failures" % failures)
	quit(failures)