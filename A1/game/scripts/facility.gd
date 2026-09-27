extends Node3D
## Deterministic graybox: 12 m rooms, 3 m openings, no moving crush hazards.
const IndustrialArt = preload("res://scripts/industrial_art.gd")
const SlidingDoor = preload("res://scripts/sliding_door.gd")
var door_visuals: Array[Node3D] = []
var maintenance_visual: Node3D
var tour := false
var progression: Node
var gates: Array[StaticBody3D] = []
var maintenance_door: StaticBody3D
var navigation: NavigationRegion3D
var navigation_ready := false
var npcs: Array[CharacterBody3D] = []
const ROOMS := [
	[Vector3(0, 0, 0), "01  SECURITY STATION", "CONTROL / NORTH     LIFT / WEST", Color(0.24, 0.34, 0.40)],
	[Vector3(0, 0, -12), "02  CONTROL ROOM", "COOLANT / NORTH     WORKSHOP / EAST", Color(0.27, 0.38, 0.32)],
	[Vector3(12, 0, -12), "03  MAINTENANCE WORKSHOP", "CONTROL / WEST", Color(0.42, 0.32, 0.21)],
	[Vector3(0, 0, -24), "04  COOLANT GALLERY", "OBSERVATION / NORTH     CONTROL / SOUTH", Color(0.23, 0.36, 0.43)],
	[Vector3(0, 0, -36), "05  CHAMBER OBSERVATION", "CHAMBER CONTROL CONSOLE / EAST", Color(0.38, 0.27, 0.35)],
	[Vector3(-12, 0, 0), "06  EVACUATION LIFT", "SECURITY / EAST", Color(0.37, 0.37, 0.25)],
]
const WALL := Color(0.26, 0.29, 0.32)
const AMBIENT_ENERGY := 0.07
const ROOM_LIGHT_ENERGY := 0.22

func _ready() -> void:
	name = "Facility"
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color(0.025, 0.035, 0.045)
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color(0.65, 0.72, 0.8)
	settings.ambient_light_energy = AMBIENT_ENERGY
	environment.environment = settings
	add_child(environment)
	for room in ROOMS:
		build_room(room)
	gate(Vector3(0, 0, -18), "GATE A - EMERGENCY POWER", "Locked: emergency power must be restored by Mara.")
	gate(Vector3(0, 0, -30), "GATE B - SECURITY ACCESS", "Locked: power restoration and Eli's authorization are required.")
	maintenance_visual = door_assembly(Vector3(6, 0, -12), PI / 2)
	if not tour:
		maintenance_door = box(Vector3(6, 1.3, -12), Vector3(0.32, 2.8, 3), Color("544b32"))
		maintenance_door.get_child(0).hide()
		maintenance_door.set_meta("prompt", "Inspect maintenance access")
		maintenance_door.set_meta("message", "Maintenance is locked. Speak to both Mara and Eli in security to unlock it.")
	prop(Vector3(-3.6, 0.65, -2.5), Vector3(2.6, 1.3, 1.2), "Security desk", "Facility lockdown active. Control room is north; evacuation lift is west.")
	prop(Vector3(-3.6, 0.8, -14.5), Vector3(2.5, 1.6, 1.2), "Control console", "Maintenance workshop is east. Mara repairs power; Eli authorizes access here.")
	prop(Vector3(15, 0.55, -14), Vector3(3, 1.1, 1.4), "Maintenance workbench", "Replacement component tray and emergency-power repair station. Ask Mara to repair after collection.")
	for z in [-26.5, -24.0, -21.5]:
		var tank := box(Vector3(-4, 1.4, z), Vector3(1.5, 2.8, 1.5), Color(0.16, 0.4, 0.46))
		tank.get_child(0).hide()
	prop(Vector3(3.7, 0.65, -36), Vector3(1.7, 1.3, 2.5), "Chamber control console", "Isolation requires Mara at the maintenance panel and Eli at the security override.")
	var glass := box(Vector3(0, 1.8, -41.6), Vector3(7, 2.5, 0.2), Color(0.08, 0.17, 0.22))
	var glass_material := StandardMaterial3D.new()
	glass_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_material.albedo_color = Color(0.17, 0.3, 0.34, 0.13)
	glass_material.roughness = 0.2
	glass.get_child(0).material_override = glass_material
	prop(Vector3(-15.5, 0.9, -2), Vector3(1, 1.8, 1), "Lift call panel", "Isolate the chamber, then board with both survivors to evacuate.")
	box(Vector3(-16, 0.04, 1), Vector3(3, 0.08, 4), Color(0.6, 0.54, 0.27))
	journal(Vector3(3.7, 0.06, -3), "Voice warning", -0.25)
	journal(Vector3(9, 0.06, -15), "Incident note", 0.4)
	journal(Vector3(-4, 0.06, -39), "Isolation protocol", -0.5)
	var art := IndustrialArt.new()
	art.facility = self
	add_child(art)
	build_navigation()

func build_navigation() -> void:
	navigation_ready = false
	if not navigation:
		navigation = NavigationRegion3D.new()
		add_child(navigation)
	var mesh := NavigationMesh.new()
	NavigationServer3D.map_set_cell_size(navigation.get_navigation_map(), 0.15)
	NavigationServer3D.map_set_cell_height(navigation.get_navigation_map(), 0.1)
	mesh.agent_radius = 0.45
	mesh.agent_height = 1.8
	mesh.agent_max_climb = 0.2
	mesh.cell_size = 0.15
	mesh.cell_height = 0.1
	mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	mesh.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_GROUPS_EXPLICIT
	mesh.geometry_source_group_name = "navigation_geometry"
	mesh.filter_baking_aabb = AABB(Vector3(-19, -0.5, -43), Vector3(38, 2.6, 50))
	var source := NavigationMeshSourceGeometryData3D.new()
	NavigationServer3D.parse_source_geometry_data(mesh, source, self)
	NavigationServer3D.bake_from_source_geometry_data(mesh, source)
	navigation.navigation_mesh = mesh
	# The server applies the new region at the next physics synchronization.
	await get_tree().physics_frame
	await get_tree().physics_frame
	navigation_ready = true

func route(from: Vector3, to: Vector3) -> PackedVector3Array:
	if not navigation_ready:
		return PackedVector3Array()
	var map := navigation.get_navigation_map()
	var end := NavigationServer3D.map_get_closest_point(map, to)
	if Vector2(end.x - to.x, end.z - to.z).length() > 0.8:
		return PackedVector3Array()
	var path := NavigationServer3D.map_get_path(map, from, end, true)
	if path.is_empty() or path[path.size() - 1].distance_to(end) > 0.5:
		return PackedVector3Array()
	return path

func build_room(room: Array) -> void:
	var center: Vector3 = room[0]
	box(center + Vector3(0, -0.15, 0), Vector3(12, 0.3, 12), Color(room[3]).darkened(0.35))
	box(center + Vector3(0, 3.65, 0), Vector3(12, 0.3, 12), WALL)
	for direction in [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]:
		var neighbor := false
		for other in ROOMS:
			if center + direction * 12 == other[0]:
				neighbor = true
		var across := Vector3(1, 0, 0) if direction.z != 0 else Vector3(0, 0, 1)
		var wall_center: Vector3 = center + direction * 6
		if neighbor:
			for side in [-1, 1]:
				wall_piece(wall_center + across * 3.75 * side, direction, 4.5, 3.5, 1.75)
			wall_piece(wall_center, direction, 3, 0.7, 3.15)
		elif center.z == -36 and direction == Vector3.FORWARD:
			for side in [-1, 1]:
				wall_piece(wall_center + across * 4.8 * side, direction, 2.4, 3.5, 1.75)
			wall_piece(wall_center, direction, 7.2, 0.5, 0.25)
			wall_piece(wall_center, direction, 7.2, 0.4, 3.3)
		else:
			wall_piece(wall_center, direction, 12, 3.5, 1.75)
	var light := OmniLight3D.new()
	light.position = center + Vector3(0, 3.1, 0)
	light.omni_range = 6
	light.light_energy = ROOM_LIGHT_ENERGY
	light.light_color = Color(0.75, 0.83, 0.9)
	add_child(light)

func wall_piece(at: Vector3, direction: Vector3, width: float, height: float, elevation: float) -> void:
	var size := Vector3(width, height, 0.2) if direction.z != 0 else Vector3(0.2, height, width)
	box(at + Vector3(0, elevation, 0), size, WALL)

func box(at: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.add_to_group("navigation_geometry")
	body.position = at
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	mesh.material_override = material
	body.add_child(mesh)
	var collision := CollisionShape3D.new()
	var bounds := BoxShape3D.new()
	bounds.size = size
	collision.shape = bounds
	body.add_child(collision)
	add_child(body)
	return body

func journal(at: Vector3, title: String, yaw: float) -> void:
	var body := box(at, Vector3(0.34, 0.10, 0.46), Color("463b32"))
	body.rotation.y = yaw
	body.get_child(0).hide()
	body.set_meta("prompt", "Read " + title)
	body.set_meta("message", "")
	body.set_meta("object_id", title)

func prop(at: Vector3, size: Vector3, title: String, message: String) -> void:
	var body := box(at, size, Color(0.16, 0.20, 0.23))
	body.set_meta("prompt", "Inspect " + title)
	body.set_meta("message", message)
	body.set_meta("object_id", title)
	if title == "Maintenance workbench":
		body.set_meta("prompt", "Collect replacement component / inspect workbench")

func door_assembly(at: Vector3, yaw := 0.0) -> Node3D:
	var assembly := SlidingDoor.new()
	assembly.position = at
	assembly.rotation.y = yaw
	add_child(assembly)
	if tour:
		assembly.open(true)
	return assembly

func gate(at: Vector3, title: String, message: String) -> void:
	door_visuals.append(door_assembly(at))
	if not tour:
		var body := box(at + Vector3(0, 1.2, 0), Vector3(3, 2.8, 0.32), Color(0.52, 0.33, 0.14))
		body.get_child(0).hide()
		body.set_meta("prompt", "Inspect " + title)
		body.set_meta("message", message)
		gates.append(body)

func area_name(at: Vector3) -> String:
	for room in ROOMS:
		var center: Vector3 = room[0]
		if absf(at.x - center.x) <= 6 and absf(at.z - center.z) <= 6:
			return room[1]
	return "FACILITY"

func unlock_gate(index: int) -> void:
	if index >= gates.size() or not is_instance_valid(gates[index]):
		return
	if has_meta("sounds"):
		get_meta("sounds").cue("door")
	door_visuals[index].open()
	var gate_body := gates[index]
	remove_child(gate_body)
	gate_body.queue_free()
	build_navigation()

func unlock_maintenance() -> void:
	if not is_instance_valid(maintenance_door):
		return
	maintenance_visual.open()
	remove_child(maintenance_door)
	maintenance_door.queue_free()
	maintenance_door = null
	if has_meta("sounds"):
		get_meta("sounds").cue("door")
	build_navigation()

func set_component_visible(value: bool) -> void:
	for child in get_children():
		if child is IndustrialArt:
			for visual in child.get_children():
				if visual.has_meta("component_visual"):
					visual.visible = value
