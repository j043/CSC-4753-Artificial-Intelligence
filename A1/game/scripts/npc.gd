extends CharacterBody3D
## Authored local state machine. No relocation or objective side effects.
signal announced(message: String)
const HumanVisual = preload("res://scripts/npc_visual.gd")
var human: Node3D
var person := "Mara Voss"
var engineer := true
var player: CharacterBody3D
var facility: Node3D
var state := "idle"
var task_ready := false
var task_id := ""
var talking := false
var destination := Vector3.ZERO
var path := PackedVector3Array()
var path_index := 0
var repath_time := 0.0
var stuck_time := 0.0
var progress_origin := Vector3.ZERO
var progress_time := 0.0
var retried := false
var status: Label3D
var follow_reference := Vector3.INF
var follow_anchor := Vector3.ZERO

func _ready() -> void:
	collision_layer = 2
	collision_mask = 3
	set_meta("npc", true)
	set_meta("prompt", "Talk to " + person)
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.8
	collider.shape = capsule
	collider.position.y = 0.9
	add_child(collider)
	human = HumanVisual.new()
	human.engineer = engineer
	human.rotation.y = PI
	add_child(human)
	status = Label3D.new()
	status.position.y = 2.2
	status.font_size = 27
	status.pixel_size = 0.0035
	status.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(status)
	progress_origin = position

func say(text: String) -> String:
	var line := person + ": " + text
	announced.emit(line)
	return line

func command(order: String) -> String:
	if facility.progression and not facility.tour:
		var reason: String = facility.progression.command_reason(self, order)
		if reason != "":
			return say(reason)
	if order == "repair" and not facility.progression:
		return say("I need the replacement component and emergency-power objective. Repair progression arrives in M3." if engineer else "Power must be restored before I can authorize access. Security progression arrives in M3.")
	if order == "wait":
		task_ready = false
		state = "wait"
		destination = position
		velocity = Vector3.ZERO
		path.clear()
		return say("Holding here.")
	var target: Vector3
	if order == "follow":
		target = follow_target()
	elif order in ["station", "repair"]:
		target = Vector3(13, 0, -12) if engineer else Vector3(-2, 0, -12)
	elif order == "evacuate":
		target = Vector3(-14, 0, 0 if engineer else 2)
	elif order == "isolation":
		target = Vector3(-2, 0, -36) if engineer else Vector3(2, 0, -38)
	else:
		return say("Unknown command.")
	var candidate: PackedVector3Array = facility.route(position, target)
	if candidate.is_empty():
		for gate in facility.gates:
			if is_instance_valid(gate) and (position.z - gate.position.z) * (target.z - gate.position.z) < 0:
				return say("No reachable route. " + ("Gate A needs emergency power restored." if gate.position.z > -24 else "Gate B needs power and security authorization."))
		return say("No reachable route. Check the locked gates or clear the destination, then ask again.")
	task_id = order
	task_ready = false
	state = "follow" if order == "follow" else "travel_to_task"
	destination = target
	path = candidate
	path_index = 0
	repath_time = 0
	stuck_time = 0
	progress_time = 0
	progress_origin = position
	retried = false
	if order == "evacuate":
		return ""
	return say("Following you." if order == "follow" else "On my way.")

func follow_target() -> Vector3:
	# Follow translation, never camera yaw. Retain a world-space stopping point
	# while the player stands still so they can turn and speak to us.
	if follow_reference == Vector3.INF:
		follow_reference = player.position
		follow_anchor = player.position + Vector3(-1.1 if engineer else 1.1, 0, 1.6)
	var movement := player.position - follow_reference
	movement.y = 0
	if movement.length() > 0.3:
		var heading := movement.normalized()
		var side := Vector3(-heading.z, 0, heading.x)
		follow_anchor = player.position - heading * 1.6 + side * (-1.1 if engineer else 1.1)
		follow_reference = player.position
	return follow_anchor

func _physics_process(delta: float) -> void:
	human.animate(delta, Vector2(velocity.x, velocity.z).length(), state == "perform_task" and task_id != "evacuate")
	var facing: Vector3 = player.position - position if talking else velocity
	facing.y = 0
	if facing.length() > 0.1:
		human.rotation.y = lerp_angle(human.rotation.y, atan2(-facing.x, -facing.z), minf(delta * 8, 1))
	var activity: String = {"idle": "Available", "wait": "Waiting", "follow": "Following", "travel_to_task": "Moving to station", "perform_task": "Ready"}.get(state, "Available")
	if task_id == "evacuate":
		activity = "Boarded" if task_ready else "Evacuating"
	status.text = person + " / " + ("Talking" if talking else activity)
	if talking or state in ["idle", "wait", "perform_task"]:
		velocity = Vector3.ZERO
		return
	repath_time -= delta
	if state == "follow":
		destination = follow_target()
	if position.distance_to(destination) < (0.65 if state == "follow" else 0.35):
		velocity = Vector3.ZERO
		stuck_time = 0
		progress_origin = position
		if state == "travel_to_task":
			state = "perform_task"
			task_ready = true
			# Repair/access produce their own objective updates; readiness is on the HUD.
			if task_id == "isolation":
				say("Ready for isolation.")
		return
	if repath_time <= 0:
		path = facility.route(position, destination)
		path_index = 0
		repath_time = 0.7
		if path.is_empty():
			cancel_blocked()
			return
	while path_index < path.size() and Vector2(path[path_index].x - position.x, path[path_index].z - position.z).length() < 0.25:
		path_index += 1
	var direction := Vector3.ZERO
	if path_index < path.size():
		direction = path[path_index] - position
		direction.y = 0
		direction = direction.normalized()
	# Yield around characters, with opposite preferred sides for the two roles.
	if test_move(global_transform, direction * 0.45):
		var side := Vector3(-direction.z, 0, direction.x) * (1 if engineer else -1)
		if not test_move(global_transform, side * 0.5):
			direction = side
	velocity.x = direction.x * 3.1
	velocity.z = direction.z * 3.1
	velocity.y = 0 if is_on_floor() else velocity.y - 18 * delta
	move_and_slide()
	progress_time += delta
	if progress_time >= 1.5:
		if position.distance_to(progress_origin) < 0.3:
			stuck_time += progress_time
		else:
			stuck_time = 0
		progress_origin = position
		progress_time = 0
		if stuck_time >= 1.5 and not retried:
			retried = true
			repath_time = 0
			say("My path is blocked. Trying another approach; please give me space.")
		if stuck_time >= 4.5:
			cancel_blocked()

func cancel_blocked() -> void:
	state = "wait"
	task_ready = false
	destination = position
	velocity = Vector3.ZERO
	path.clear()
	say("I can't reach that position. Holding here. Clear the route, then ask me to follow or reassign my station.")
