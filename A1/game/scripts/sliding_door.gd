extends Node3D
## Visual assembly and moving leaf collision; facility owns the navigation blocker.
var leaves: Array[AnimatableBody3D] = []
var indicators: Array[MeshInstance3D] = []
var opened := false

func block(parent: Node3D, at: Vector3, size: Vector3, color: Color, glow := false) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.position = at
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = 0.65
	material.roughness = 0.45
	if glow:
		material.emission_enabled = true
		material.emission = color
	mesh.material_override = material
	parent.add_child(mesh)
	return mesh

func _ready() -> void:
	for side in [-1, 1]:
		block(self, Vector3(side * 1.65, 1.4, 0), Vector3(0.3, 2.8, 0.6), Color("313d43"))
		var leaf := AnimatableBody3D.new()
		leaf.sync_to_physics = false
		leaf.position.x = side * 0.75
		add_child(leaf)
		leaves.append(leaf)
		block(leaf, Vector3(0, 1.38, 0), Vector3(1.49, 2.76, 0.26), Color("566166"))
		var collision := CollisionShape3D.new()
		var bounds := BoxShape3D.new()
		bounds.size = Vector3(1.49, 2.76, 0.26)
		collision.shape = bounds
		collision.position.y = 1.38
		leaf.add_child(collision)
		for face in [-1, 1]:
			block(leaf, Vector3(0, 1.48, face * 0.15), Vector3(1.20, 2.05, 0.035), Color("354148"))
			block(leaf, Vector3(-side * 0.60, 1.38, face * 0.18), Vector3(0.07, 2.64, 0.06), Color("b29b58"))
			for y in [0.44, 2.36]:
				block(leaf, Vector3(0, y, face * 0.19), Vector3(1.2, 0.16, 0.05), Color("b29b58"))
				for x in [-0.45, -0.15, 0.15, 0.45]:
					var stripe := block(leaf, Vector3(x, y, face * 0.22), Vector3(0.12, 0.16, 0.015), Color("182126"))
					stripe.rotation.z = -0.35
			block(leaf, Vector3(-side * 0.43, 1.35, face * 0.23), Vector3(0.08, 0.42, 0.10), Color("99a2a2"))
			indicators.append(block(self, Vector3(side * 1.65, 1.65, face * 0.32), Vector3(0.12, 0.32, 0.035), Color("dd392d"), true))
	block(self, Vector3(0, 2.9, 0), Vector3(3.6, 0.22, 0.65), Color("303a40"))
	block(self, Vector3(0, 0.018, 0), Vector3(3, 0.025, 0.44), Color("788184"))

func open(instant := false) -> void:
	if opened:
		return
	opened = true
	for indicator in indicators:
		indicator.material_override.albedo_color = Color("55c6a0")
		indicator.material_override.emission = Color("55c6a0")
	for leaf in leaves:
		var target := signf(leaf.position.x) * 2.28
		if instant:
			leaf.position.x = target
		else:
			var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(leaf, "position:x", target, 1.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
