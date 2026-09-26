extends Node
## Run-local narrative state; checkpoint contains values, never live node references.
var app: Control
var clues: Array[String] = []
var fired: Array[String] = []
var checkpoint: Dictionary = {}
var remaining := 120.0
var decision := ""
var figure: Node3D
var figure_time := 0.0
var light_time := 0.0
var alarm: AudioStreamPlayer
const CLUES := {
	"Voice warning": "VOICE AUTHENTICATION WARNING\nThe chamber can reproduce a familiar voice. A voice alone is not proof of identity. Verify instructions against physical instruments and the isolation protocol.",
	"Incident note": "INCIDENT 17\nAn operator heard a colleague asking to reconnect the chamber. The colleague was off-site. Reconnection increased the anomaly; isolation reduced it.",
	"Isolation protocol": "ISOLATION PROTOCOL\nEngineer: hold the maintenance panel. Security: hold the override. Technician: select ISOLATE. Reconnection bypasses containment. After isolation, evacuate together via the western lift."
}

func collect(id: String) -> void:
	if id not in clues:
		clues.append(id)
	app.show_journal(id)

func save_checkpoint() -> void:
	var p = app.progress
	checkpoint = {"clues": clues.duplicate(), "fired": fired.duplicate(), "met": p.met.duplicate(), "completed": p.completed.duplicate(), "pending": p.pending.duplicate(), "active": p.active, "line_index": p.line_index, "warning": p.warning_known, "player": app.player.position, "yaw": app.player.rotation, "pitch": app.player.camera.rotation, "flashlight": app.player.light.visible, "npcs": []}
	for npc in app.world.npcs:
		checkpoint.npcs.append({"position": npc.position, "rotation": npc.rotation, "destination": npc.destination})

func choose(choice: String) -> void:
	if app.mode != "decision" or app.progress.isolation_missing() != "":
		return
	app.replace_interaction_feedback()
	decision = choice
	if choice == "reconnect":
		app.show_outcome("CONTAINMENT BREACH", "You trusted the copied voice and reconnected the chamber. The isolation circuit fell silent. Something wearing Mara's voice reached the surface.")
	elif choice == "isolate":
		app.progress.stage = 6
		remaining = 120.0
		fired.append("alarm")
		start_alarm()
		app.shadow.start_chase()
		app.resume()
		app.show_notice("Mara Voss: It is coming! Hold Shift to sprint to the lift. You have six seconds before it moves.")
		if app.world.navigation_ready:
			for npc in app.world.npcs:
				npc.command("evacuate")

func start_alarm() -> void:
	alarm = AudioStreamPlayer.new()
	var wave := AudioStreamWAV.new()
	wave.mix_rate = 22050
	wave.format = AudioStreamWAV.FORMAT_16_BITS
	var samples := PackedByteArray()
	samples.resize(22050 * 2)
	for i in 22050:
		var envelope := 0.22 if i < 15000 else 0.0
		samples.encode_s16(i * 2, int(sin(TAU * 440.0 * i / 22050.0) * 32767 * envelope))
	wave.data = samples
	wave.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wave.loop_end = 22050
	alarm.stream = wave
	alarm.volume_db = -16
	add_child(alarm)
	alarm.play()

func tick(delta: float) -> void:
	if app.tour or app.mode != "play":
		return
	if app.progress.stage == 6:
		remaining = maxf(0.0, remaining - delta)
		if remaining <= 0:
			app.show_outcome("EVACUATION FAILED", "The evacuation window closed before everyone boarded. Retry the console checkpoint to try again.")
			return
	var at: Vector3 = app.player.position
	if app.progress.stage >= 4 and at.z < -20 and at.z > -29 and "lights" not in fired:
		fired.append("lights")
		light_time = 2.5
		set_gallery_lights(0.015)
	if light_time > 0:
		light_time = maxf(0, light_time - delta)
		if light_time == 0:
			set_gallery_lights(app.world.ROOM_LIGHT_ENERGY)
	if app.progress.stage >= 5 and at.z < -33 and "figure" not in fired:
		# Trigger only when the window is in front of the player.
		var toward: Vector3 = Vector3(0, 1.6, -41.3) - app.player.camera.global_position
		if -app.player.camera.global_basis.z.dot(toward.normalized()) > 0.65:
			fired.append("figure")
			figure = Node3D.new()
			app.world.add_child(figure)
			for part in [[Vector3(0, 1.3, -41.3), Vector3(0.6, 1.4, 0.12)], [Vector3(0, 2.2, -41.3), Vector3(0.4, 0.4, 0.12)]]:
				var mesh := MeshInstance3D.new()
				var shape := BoxMesh.new()
				shape.size = part[1]
				mesh.mesh = shape
				mesh.position = part[0]
				var material := StandardMaterial3D.new()
				material.albedo_color = Color(0.01, 0.01, 0.015)
				material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				mesh.material_override = material
				figure.add_child(mesh)
			figure_time = 1.8
	if figure_time > 0:
		figure_time = maxf(0, figure_time - delta)
		if figure_time == 0 and is_instance_valid(figure):
			figure.queue_free()

func set_gallery_lights(energy: float) -> void:
	for child in app.world.get_children():
		if child is OmniLight3D and child.position.z < -18 and child.position.z > -30:
			child.light_energy = energy


func stop_alarm() -> void:
	if is_instance_valid(alarm):
		alarm.stop()
		alarm.stream = null

func _exit_tree() -> void:
	stop_alarm()
