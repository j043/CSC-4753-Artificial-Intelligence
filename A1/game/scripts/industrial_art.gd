extends Node3D
## Original industrial dressing. Added meshes stay outside tested circulation space.
var facility: Node3D
var materials: Dictionary = {}
const METAL := Color("657278")
const DARK := Color("253137")
const YELLOW := Color("bd9d48")
const TEAL := Color("517d7e")
func mat(color: Color, glow := false) -> StandardMaterial3D:
	var key := str(color) + str(glow)
	if key not in materials:
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.64
		material.metallic = 0.3
		if glow:
			material.emission_enabled = true
			material.emission = color
			material.emission_energy_multiplier = 1.4
		materials[key] = material
	return materials[key]
func mesh_at(mesh: Mesh, at: Vector3, color: Color, glow := false) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	visual.position = at
	visual.material_override = mat(color, glow)
	add_child(visual)
	return visual
func box(at: Vector3, size: Vector3, color: Color, glow := false) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	return mesh_at(shape, at, color, glow)
func cylinder(at: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = radius
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = 16
	return mesh_at(shape, at, color)
func label(text: String, at: Vector3, size := 22, yaw := 0.0, color := Color("cdd8d5")) -> void:
	var sign := Label3D.new()
	sign.text = text
	sign.position = at
	sign.font_size = size
	sign.pixel_size = 0.006
	sign.rotation.y = yaw
	sign.modulate = color
	sign.outline_size = 1
	add_child(sign)
func pipe_between(a: Vector3, b: Vector3, radius: float, color: Color) -> void:
	var pipe := cylinder((a + b) / 2, radius, a.distance_to(b), color)
	pipe.quaternion = Quaternion(Vector3.UP, (b-a).normalized())
func gauge(at: Vector3) -> void:
	var casing := cylinder(at, 0.15, 0.05, DARK)
	casing.rotation.x = PI / 2
	var face := cylinder(at + Vector3(0, 0, 0.03), 0.123, 0.008, Color("d9dac7"))
	face.rotation.x = PI / 2
	var needle := box(at + Vector3(0.026, 0.036, 0.041), Vector3(0.014, 0.10, 0.008), Color("252b2c"))
	needle.rotation.z = -0.6
func monitor(at: Vector3, size := Vector2(0.85, 0.55)) -> void:
	box(at, Vector3(size.x + 0.08, size.y + 0.08, 0.08), DARK)
	box(at + Vector3(0, 0, 0.045), Vector3(size.x, size.y, 0.008), Color("163d46"), true)
	for row in 4:
		box(at + Vector3(-size.x * 0.12, size.y * (0.32 - row * 0.19), 0.055), Vector3(size.x * (0.60 if row % 2 == 0 else 0.38), 0.012, 0.006), Color("64a994"), true)
func hazard(at: Vector3, width: float) -> void:
	box(at, Vector3(width, 0.13, 0.025), YELLOW)
	for i in int(width / 0.20):
		var stripe := box(at + Vector3(-width / 2 + 0.1 + i * 0.20, 0, 0.018), Vector3(0.08, 0.13, 0.015), DARK)
		stripe.rotation.z = -0.35
func _ready() -> void:
	for room in facility.ROOMS:
		room_detail(room[0], room[1])
	control_room()
	coolant_gallery()
	observation()
	workshop()
	security()
	lift()
	for child in facility.get_children():
		if child.get_meta("object_id", "") in ["Voice warning", "Incident note", "Isolation protocol"]:
			journal_book(child)

func journal_book(body: Node3D) -> void:
	var cover := Color("704735")
	if body.get_meta("object_id") == "Incident note":
		cover = Color("3c6064")
	elif body.get_meta("object_id") == "Isolation protocol":
		cover = Color("71643b")
	var parts := [
		[Vector3(0, -0.039, 0), Vector3(0.34, 0.018, 0.46), cover],
		[Vector3(0, 0.039, 0), Vector3(0.34, 0.018, 0.46), cover],
		[Vector3(0.005, 0, 0), Vector3(0.31, 0.06, 0.43), Color("d4c8a7")],
		[Vector3(-0.16, 0, 0), Vector3(0.025, 0.085, 0.46), cover.darkened(0.2)],
		[Vector3(0.025, 0.05, -0.055), Vector3(0.19, 0.003, 0.15), Color("c5b98f")],
		[Vector3(0.09, 0.007, 0.235), Vector3(0.035, 0.005, 0.07), Color("963e31")],
	]
	for y in [-0.02, -0.007, 0.007, 0.02]:
		parts.append([Vector3(0.005, y, 0), Vector3(0.312, 0.002, 0.432), Color("9d947d")])
	for z in [-0.095, -0.065, -0.035]:
		parts.append([Vector3(0.025, 0.052, z), Vector3(0.13, 0.002, 0.009), DARK])
	for part in parts:
		var visual := box(part[0], part[1], part[2])
		visual.reparent(body, false)
		visual.material_override = visual.material_override.duplicate()
		visual.material_override.metallic = 0.0
		visual.material_override.roughness = 0.95
func room_detail(center: Vector3, title: String) -> void:
	# Inlaid floor panel seams and a clear central circulation lane.
	for x in range(-5, 6, 2):
		box(center + Vector3(x, 0.006, 0), Vector3(0.018, 0.008, 11.8), DARK)
	for z in range(-5, 6, 2):
		box(center + Vector3(0, 0.006, z), Vector3(11.8, 0.008, 0.018), DARK)
	for x in [-1.65, 1.65]:
		box(center + Vector3(x, 0.011, 0), Vector3(0.055, 0.009, 11.6), YELLOW.darkened(0.15))
	# Ceiling beams, vents, cable conduits, and visible luminaires.
	for z in [-4, 0, 4]:
		box(center + Vector3(0, 3.40, z), Vector3(11.8, 0.20, 0.16), DARK)
		box(center + Vector3(0, 3.46, z + 0.3), Vector3(2.8, 0.06, 0.40), METAL)
		box(center + Vector3(0, 3.41, z + 0.3), Vector3(2.6, 0.016, 0.25), Color("394d50"), true)
	for x in [-4.8, -4.35]:
		pipe_between(center + Vector3(x, 3.18, -5.8), center + Vector3(x, 3.18, 5.8), 0.10, METAL)
	# Wall cladding only on solid portions, never across door openings.
	for direction in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
		var along := Vector3.RIGHT if direction.z != 0 else Vector3.BACK
		for distance in [-4.6, -2.6, 2.6, 4.6]:
			var at: Vector3 = center + direction * 5.83 + along * distance
			var size := Vector3(1.86, 1.85, 0.07) if direction.z != 0 else Vector3(0.07, 1.85, 1.86)
			# Keep the observation window entirely unobstructed.
			if center.z == -36 and direction == Vector3.FORWARD and absf(distance) < 4:
				continue
			box(at + Vector3(0, 1.08, 0), size, Color("424f53"))
			box(at + Vector3(0, 0.20, 0), Vector3(1.86, 0.08, 0.10) if direction.z != 0 else Vector3(0.10, 0.08, 1.86), METAL)
	for z in [-5.8, 5.8]:
		var neighbor := false
		for room in facility.ROOMS:
			if room[0] == center + Vector3(0, 0, 12 if z > 0 else -12):
				neighbor = true
		if not neighbor:
			continue
		for x in [-1.58, 1.58]:
			box(center + Vector3(x, 1.45, z), Vector3(0.12, 2.9, 0.16), METAL)
		box(center + Vector3(0, 2.91, z), Vector3(3.28, 0.13, 0.16), METAL)
	# Wall-mounted room placard backing; original signs stay in front.
	if center.z != -36:
		box(center + Vector3(-3.65, 2.46, -5.72), Vector3(4.05, 0.97, 0.05), DARK)
	label("BLACKWELL  /  NUCLEAR RESEARCH", center + Vector3(3.8, 3.05, -5.68), 13)
func security() -> void:
	for x in [-4.4, -3.5, -2.6]:
		monitor(Vector3(x, 1.48, -2.45), Vector2(0.64, 0.43))
	box(Vector3(-3.6, 1.32, -2.2), Vector3(2.6, 0.04, 1.0), METAL)
	for x in [3.5, 4.3, 5.1]:
		box(Vector3(x, 1.1, 5.77), Vector3(0.73, 2.15, 0.08), Color("4f6264"))
		box(Vector3(x + 0.2, 1.1, 5.68), Vector3(0.03, 0.22, 0.05), Color("b8b7a5"))
	label("PERSONNEL / DOSIMETRY", Vector3(4.2, 2.55, 5.65), 18, PI)
func control_room() -> void:
	# Instrumentation fills the existing console's envelope, not the walkway.
	for x in [-4.35, -3.55, -2.8]:
		monitor(Vector3(x, 1.95, -14.56), Vector2(0.66, 0.46))
		gauge(Vector3(x, 1.26, -13.88))
	box(Vector3(-3.6, 1.63, -14.35), Vector3(2.5, 0.07, 1.35), METAL)
	for i in 9:
		box(Vector3(-4.6 + i * 0.24, 1.68, -13.9), Vector3(0.10, 0.035, 0.13), Color("ad6a48") if i % 3 == 0 else Color("72968c"))
	label("REACTOR CONTROL / AUXILIARY BUS", Vector3(-3.6, 2.45, -14.4), 17)
	for x in [2.6, 3.8, 5.0]:
		box(Vector3(x, 1.5, -17.77), Vector3(1.03, 2.65, 0.10), DARK)
		monitor(Vector3(x, 2, -17.66), Vector2(0.8, 0.60))
		for i in 5:
			box(Vector3(x, 0.65 + i * 0.18, -17.65), Vector3(0.75, 0.065, 0.04), METAL)
func coolant_gallery() -> void:
	for z in [-26.5, -24.0, -21.5]:
		cylinder(Vector3(-4, 1.4, z), 0.67, 2.65, TEAL)
		for y in [0.25, 2.55]:
			cylinder(Vector3(-4, y, z), 0.73, 0.14, METAL)
		gauge(Vector3(-4, 1.8, z + 0.78))
		pipe_between(Vector3(-4, 2.7, z), Vector3(-4, 3.05, z), 0.22, METAL)
		label("PRIMARY COOLANT", Vector3(-4, 1.15, z + 0.79), 12)
	pipe_between(Vector3(-4, 3.05, -28), Vector3(-4, 3.05, -20), 0.22, TEAL)
	for z in [-27, -24, -21]:
		box(Vector3(5.78, 1.7, z), Vector3(0.11, 1.8, 1.3), DARK)
	label("COOLANT LOOP A / PRESSURIZED", Vector3(-3.8, 2.95, -28), 18)
func workshop() -> void:
	box(Vector3(15, 1.13, -14), Vector3(3, 0.08, 1.4), METAL)
	box(Vector3(15, 1.25, -14.2), Vector3(0.8, 0.17, 0.48), Color("8b8252")).set_meta("component_visual", true)
	for x in [14.72, 14.9, 15.08, 15.26]:
		cylinder(Vector3(x, 1.38, -14.2), 0.045, 0.13, Color("bbac71")).set_meta("component_visual", true)
	box(Vector3(15, 0.55, -13.28), Vector3(2.9, 0.88, 0.05), DARK)
	for y in [0.3, 0.6, 0.9]:
		box(Vector3(15, y, -13.23), Vector3(2.75, 0.015, 0.015), METAL)
		box(Vector3(15, y + 0.10, -13.20), Vector3(0.55, 0.035, 0.045), METAL)
	box(Vector3(15, 2.15, -17.77), Vector3(3.7, 1.9, 0.06), DARK)
	for i in 9:
		pipe_between(Vector3(13.5 + i * 0.35, 1.7, -17.69), Vector3(13.5 + i * 0.35, 2.3 + (i % 3) * 0.15, -17.69), 0.035, METAL)
	hazard(Vector3(15, 1.02, -13.19), 2.9)
func observation() -> void:
	for x in [-3.58, 3.58]:
		box(Vector3(x, 1.8, -41.3), Vector3(0.16, 2.7, 0.20), METAL)
	for y in [0.5, 3.12]:
		box(Vector3(0, y, -41.3), Vector3(7.3, 0.14, 0.20), METAL)
	# Sealed chamber scenery beyond the observation glass.
	box(Vector3(0, -0.08, -46), Vector3(11.8, 0.16, 8), DARK)
	box(Vector3(0, 3.6, -46), Vector3(11.8, 0.15, 8), DARK)
	box(Vector3(0, 1.8, -50), Vector3(11.8, 3.6, 0.2), Color("354249"))
	for x in [-5.9, 5.9]:
		box(Vector3(x, 1.8, -46), Vector3(0.2, 3.6, 8), DARK)
	cylinder(Vector3(0, 1.3, -46), 1.3, 2.6, METAL)
	for y in [0.2, 0.6, 2.2, 2.65]:
		cylinder(Vector3(0, y, -46), 1.46, 0.14, DARK)
	for x in [-0.8, -0.4, 0, 0.4, 0.8]:
		box(Vector3(x, 1.4, -44.76), Vector3(0.075, 1.3, 0.05), Color("478d94"), true)
	for x in [-3, 3]:
		pipe_between(Vector3(x, 0.25, -46), Vector3(x, 3.1, -46), 0.26, TEAL)
		pipe_between(Vector3(x, 2.6, -46), Vector3(0, 2.6, -46), 0.26, TEAL)
	label("EXPERIMENTAL CORE / RADIATION AREA", Vector3(0, 3.12, -49.85), 25, 0, YELLOW)
	hazard(Vector3(0, 0.57, -41.17), 7)
	radiation_sign(Vector3(4.75, 2.55, -41.70))
	monitor(Vector3(3.7, 1.65, -35.0), Vector2(1.3, 0.75))
	label("CHAMBER ISOLATION", Vector3(3.7, 2.23, -35), 16)
func lift() -> void:
	box(Vector3(-17.77, 1.5, 0), Vector3(0.08, 2.95, 3.8), METAL)
	box(Vector3(-17.69, 1.5, 0), Vector3(0.03, 2.9, 0.045), DARK)
	for z in [-2.15, 2.15]:
		box(Vector3(-17.6, 1.5, z), Vector3(0.25, 3.0, 0.17), DARK)
	label("SURFACE LIFT / SAFE ZONE", Vector3(-17.4, 3.08, 0), 22, PI / 2, Color("82b69f"))
	for i in 4:
		box(Vector3(-15.5, 1.2 - i * 0.2, -1.47), Vector3(0.28, 0.09, 0.018), Color("73b19b"), true)

func radiation_sign(at: Vector3) -> void:
	box(at, Vector3(0.9, 0.85, 0.025), YELLOW)
	var disk := cylinder(at + Vector3(0, 0.07, 0.025), 0.055, 0.008, DARK)
	disk.rotation.x = PI / 2
	var triangles := ImmediateMesh.new()
	triangles.surface_begin(Mesh.PRIMITIVE_TRIANGLES, mat(DARK))
	for blade in 3:
		for step in 8:
			var first := blade * TAU / 3 + step * PI / 24
			var second := first + PI / 24
			var a := Vector3(cos(first), sin(first), 0)
			var b := Vector3(cos(second), sin(second), 0)
			for point in [a * 0.09, a * 0.27, b * 0.27, a * 0.09, b * 0.27, b * 0.09]:
				triangles.surface_set_normal(Vector3.BACK)
				triangles.surface_add_vertex(point)
	triangles.surface_end()
	mesh_at(triangles, at + Vector3(0, 0.07, 0.034), DARK)
	label("RADIATION", at + Vector3(0, -0.30, 0.04), 15, 0, DARK)
