extends CharacterBody3D
## Local navigation/collision chase. Exploration sightings never deal damage.
const SPEED := 4.1
const GRACE := 6.0
var app: Control
var rng := RandomNumberGenerator.new()
var sighting: Node3D
var sighting_time := 0.0
var next_sighting := 14.0
var chasing := false
var grace := GRACE
var repath := 0.0
var path := PackedVector3Array()
var index := 0
var body: Node3D
var sightings := 0

func _ready() -> void:
	rng.randomize()
	next_sighting = rng.randf_range(12, 24)
	collision_layer = 0
	collision_mask = 1
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 2.2
	collider.shape = capsule
	collider.position.y = 1.1
	add_child(collider)
	body = silhouette()
	add_child(body)
	body.hide()

func silhouette() -> Node3D:
	var result := Node3D.new()
	for part in [[Vector3(0, 1.15, 0), Vector3(0.6, 1.5, 0.3)], [Vector3(0, 2.1, 0), Vector3(0.4, 0.4, 0.3)]]:
		var visual := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = part[1]
		visual.mesh = mesh
		visual.position = part[0]
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.008, 0.008, 0.012)
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		visual.material_override = material
		result.add_child(visual)
	return result

func in_lift() -> bool:
	var at: Vector3 = app.player.position
	return at.x < -11 and at.x > -18 and absf(at.z) < 6

func clear_sighting() -> void:
	if is_instance_valid(sighting):
		sighting.queue_free()
	sighting = null
	sighting_time = 0

func start_chase() -> void:
	clear_sighting()
	position = Vector3(0, 0.05, -39.5)
	chasing = true
	grace = GRACE
	repath = 0
	path.clear()
	body.show()

func caught() -> bool:
	if not chasing or grace > 0 or in_lift():
		return false
	var offset: Vector3 = app.player.position - position
	offset.y = 0
	if offset.length() > 0.9:
		return false
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, app.player.global_position + Vector3.UP, 1)
	query.exclude = [get_rid(), app.player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func try_sighting() -> bool:
	if not app.world.navigation_ready:
		return false
	var candidates: Array[Vector3] = []
	for room in app.world.ROOMS:
		for offset in [Vector3(-3, 0.05, -3), Vector3(3, 0.05, -3), Vector3(-3, 0.05, 3), Vector3(3, 0.05, 3)]:
			var at: Vector3 = room[0] + offset
			var toward: Vector3 = at + Vector3.UP - app.player.camera.global_position
			if toward.length() < 4 or toward.length() > 11:
				continue
			if -app.player.camera.global_basis.z.dot(toward.normalized()) < 0.3:
				continue
			if app.world.route(app.player.position, at).is_empty():
				continue
			var query := PhysicsRayQueryParameters3D.create(app.player.camera.global_position, at + Vector3.UP, 1)
			query.exclude = [get_rid(), app.player.get_rid()]
			if get_world_3d().direct_space_state.intersect_ray(query).is_empty():
				candidates.append(at)
	if candidates.is_empty():
		return false
	clear_sighting()
	sighting = silhouette()
	app.world.add_child(sighting)
	sighting.position = candidates[rng.randi_range(0, candidates.size() - 1)]
	sighting_time = 1.8
	sightings += 1
	return true

func _physics_process(delta: float) -> void:
	if app.tour or app.mode != "play":
		return
	if not chasing:
		if app.progress.stage >= 6:
			return
		if sighting_time > 0:
			sighting_time -= delta
			if sighting_time <= 0:
				clear_sighting()
		next_sighting -= delta
		if next_sighting <= 0:
			next_sighting = rng.randf_range(14, 26) if try_sighting() else 2.0
		return
	if app.progress.stage != 6:
		return
	grace = maxf(0, grace - delta)
	if grace > 0 or in_lift():
		velocity = Vector3.ZERO
		return
	if caught():
		app.show_outcome("YOU DIED", "The shadow caught you before you reached the lift. Retry the checkpoint. Hold Shift to sprint; the lift interior is safe.")
		return
	repath -= delta
	if repath <= 0:
		path = app.world.route(position, app.player.position)
		index = 0
		repath = 0.3
	while index < path.size() and Vector2(path[index].x - position.x, path[index].z - position.z).length() < 0.2:
		index += 1
	var heading := Vector3.ZERO
	if index < path.size():
		heading = path[index] - position
		heading.y = 0
		heading = heading.normalized()
	velocity.x = heading.x * SPEED
	velocity.z = heading.z * SPEED
	velocity.y = 0 if is_on_floor() else velocity.y - 18 * delta
	move_and_slide()
