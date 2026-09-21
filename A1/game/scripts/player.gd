extends CharacterBody3D
signal interacted(message: String)
const WALK_SPEED := 3.4
const SPRINT_SPEED := 5.6
const SENSITIVITY := 0.0023
var camera: Camera3D
var light: SpotLight3D
var ray: RayCast3D

func _ready() -> void:
	name = "Player"
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.75
	collider.shape = capsule
	collider.position.y = 0.875
	add_child(collider)
	camera = Camera3D.new()
	camera.position.y = 1.6
	camera.current = true
	camera.fov = 75
	add_child(camera)
	light = SpotLight3D.new()
	light.light_color = Color(0.92, 0.96, 1)
	light.light_energy = 2.5
	light.spot_range = 18
	light.spot_angle = 34
	light.shadow_enabled = true
	camera.add_child(light)
	ray = RayCast3D.new()
	ray.target_position = Vector3(0, 0, -3)
	ray.add_exception(self)
	camera.add_child(ray)

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotation.x = clampf(camera.rotation.x - event.relative.y * SENSITIVITY, -1.4, 1.4)
	if event.is_action_pressed("flashlight"):
		light.visible = not light.visible
	if event.is_action_pressed("interact"):
		var target := interaction_target()
		if target:
			interacted.emit(str(target.get_meta("message")))

func interaction_target() -> Object:
	ray.force_raycast_update()
	var target := ray.get_collider()
	if target and target.has_meta("prompt"):
		return target
	return null

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("walk_left", "walk_right", "walk_forward", "walk_back")
	var movement := transform.basis * Vector3(direction.x, 0, direction.y)
	var speed := SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED
	velocity.x = movement.x * speed
	velocity.z = movement.z * speed
	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = 0
	move_and_slide()
