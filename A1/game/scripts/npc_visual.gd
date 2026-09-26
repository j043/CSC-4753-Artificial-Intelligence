extends Node3D
## Original stylized human model with articulated limbs; no external assets.
var engineer := true
var arms: Array[Node3D] = []
var legs: Array[Node3D] = []
var gait := 0.0
var materials: Dictionary = {}
func material(color: Color) -> StandardMaterial3D:
	if color not in materials:
		var value := StandardMaterial3D.new()
		value.albedo_color = color
		value.roughness = 0.8
		materials[color] = value
	return materials[color]
func ellipsoid(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 16
	mesh.rings = 8
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.scale = size
	node.position = at
	node.material_override = material(color)
	parent.add_child(node)
	return node
func block(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = at
	node.material_override = material(color)
	parent.add_child(node)

func tailored(parent: Node3D, at: Vector3, size: Vector3, color: Color, profile: Array = []) -> MeshInstance3D:
	# Loft chamfered cross-sections into one continuous, flat-shaded mesh.
	# Each section specifies height, width, depth, and forward/back offset.
	if profile.is_empty():
		profile = [[-0.5, 0.75, 0.8, 0], [-0.40, 0.9, 0.95, 0], [0.36, 1.0, 1.0, 0], [0.5, 0.8, 0.85, 0]]
	var vertices: Array[Vector3] = []
	var outline := [Vector2(-0.7, -1), Vector2(0.7, -1), Vector2(1, -0.65), Vector2(1, 0.65), Vector2(0.7, 1), Vector2(-0.7, 1), Vector2(-1, 0.65), Vector2(-1, -0.65)]
	for section in profile:
		for point in outline:
			vertices.append(Vector3(point.x * size.x * section[1] * 0.5, section[0] * size.y, (point.y * section[2] * 0.5 + section[3]) * size.z))
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(-1)
	for ring in range(profile.size() - 1):
		for i in 8:
			var a := ring * 8 + i
			var b := ring * 8 + (i + 1) % 8
			for index in [a, b + 8, a + 8, a, b, b + 8]:
				surface.add_vertex(vertices[index])
	for i in range(1, 7):
		for index in [0, i + 1, i]:
			surface.add_vertex(vertices[index])
		var top := (profile.size() - 1) * 8
		for index in [top, top + i, top + i + 1]:
			surface.add_vertex(vertices[index])
	surface.generate_normals()
	var node := MeshInstance3D.new()
	node.mesh = surface.commit()
	node.position = at
	node.material_override = material(color)
	parent.add_child(node)
	return node

func _ready() -> void:
	var cloth := Color("b17a36") if engineer else Color("314b64")
	var pants := Color("343b40") if engineer else Color("1b2938")
	var skin := Color("b88770") if engineer else Color("87604c")
	var black := Color("15191c")
	tailored(self, Vector3(0, 1.23, 0), Vector3(0.52 if engineer else 0.59, 0.52, 0.32), cloth, [[-0.5, 0.79, 0.9, 0], [-0.05, 0.87, 1.0, 0], [0.35, 1.0, 1.0, 0], [0.5, 0.63, 0.75, 0]])
	tailored(self, Vector3(0, 0.91, 0), Vector3(0.43, 0.23, 0.30), pants)
	block(self, Vector3(0, 0.99, -0.01), Vector3(0.43, 0.065, 0.31), black)
	block(self, Vector3(0, 0.99, -0.178), Vector3(0.07, 0.055, 0.025), Color("8d9294"))
	tailored(self, Vector3(0, 1.55, 0), Vector3(0.14, 0.19, 0.14), skin)
	tailored(self, Vector3(0, 1.72, 0), Vector3(0.29, 0.36, 0.27), skin, [[-0.5, 0.52, 0.65, -0.1], [-0.27, 0.85, 0.85, -0.03], [0.12, 1.0, 1.0, 0], [0.43, 0.9, 0.92, 0], [0.5, 0.65, 0.7, 0]])
	ellipsoid(self, Vector3(0, 1.82, 0.04), Vector3(0.32, 0.25, 0.25), Color("382820") if engineer else black)
	for side in [-1, 1]:
		ellipsoid(self, Vector3(side * 0.155, 1.71, 0), Vector3(0.055, 0.10, 0.06), skin)
		ellipsoid(self, Vector3(side * 0.065, 1.745, -0.134), Vector3(0.061, 0.034, 0.018), Color("ded8cd"))
		ellipsoid(self, Vector3(side * 0.065, 1.745, -0.144), Vector3(0.024, 0.027, 0.009), black)
		block(self, Vector3(side * 0.063, 1.785, -0.125), Vector3(0.065, 0.013, 0.018), Color("392e28"))
		var arm := Node3D.new()
		arm.position = Vector3(side * 0.29, 1.41, 0)
		add_child(arm)
		arms.append(arm)
		tailored(arm, Vector3(side * 0.025, -0.14, 0), Vector3(0.17, 0.35, 0.19), cloth)
		tailored(arm, Vector3(side * 0.04, -0.37, -0.015), Vector3(0.135, 0.30, 0.15), cloth)
		tailored(arm, Vector3(side * 0.04, -0.54, -0.025), Vector3(0.10, 0.16, 0.085), skin)
		var leg := Node3D.new()
		leg.position = Vector3(side * 0.125, 0.87, 0)
		add_child(leg)
		legs.append(leg)
		tailored(leg, Vector3(0, -0.20, 0), Vector3(0.21, 0.46, 0.25), pants)
		tailored(leg, Vector3(0, -0.53, 0), Vector3(0.17, 0.38, 0.20), pants)
		tailored(leg, Vector3(0, -0.77, -0.055), Vector3(0.20, 0.18, 0.34), black, [[-0.5, 1, 1, 0], [0.0, 1, 1, 0], [0.5, 0.85, 0.65, 0.12]])
	tailored(self, Vector3(0, 1.70, -0.143), Vector3(0.05, 0.085, 0.07), skin.lightened(0.05))
	block(self, Vector3(0, 1.635, -0.129), Vector3(0.072, 0.009, 0.012), Color("67463e"))
	if engineer:
		# Long chestnut hair falls from beneath the hard hat to the upper back.
		# Side locks frame the face without covering her eyes or work equipment.
		var hair := Color("503125")
		tailored(self, Vector3(0, 1.51, 0.135), Vector3(0.33, 0.65, 0.19), hair, [[-0.5, 0.65, 0.25, 0.32], [-0.35, 0.95, 0.40, 0.33], [0.05, 1.0, 0.65, 0.22], [0.37, 0.95, 0.95, 0], [0.5, 0.8, 0.8, -0.12]])
		for side in [-1, 1]:
			var lock := tailored(self, Vector3(side * 0.145, 1.53, 0.015), Vector3(0.075, 0.57, 0.16), hair, [[-0.5, 0.25, 0.5, -0.2], [-0.3, 0.9, 0.7, -0.12], [0.3, 1, 1, 0], [0.5, 0.7, 0.8, 0]])
			lock.rotation.z = side * 0.10
		ellipsoid(self, Vector3(0, 1.90, 0), Vector3(0.40, 0.22, 0.36), Color("d7ae48"))
		ellipsoid(self, Vector3(0, 1.85, -0.025), Vector3(0.46, 0.035, 0.43), Color("d7ae48"))
		for x in [-0.15, 0.15]:
			block(self, Vector3(x, 1.23, -0.159), Vector3(0.045, 0.40, 0.015), Color("d2d3b7"))
		block(self, Vector3(0, 1.11, -0.173), Vector3(0.40, 0.045, 0.012), Color("d2d3b7"))
		block(self, Vector3(0.24, 0.90, 0), Vector3(0.14, 0.23, 0.22), Color("624c37"))
		block(self, Vector3(0.26, 1.01, -0.04), Vector3(0.035, 0.22, 0.035), Color("909d9f"))
	else:
		block(self, Vector3(0, 1.23, -0.145), Vector3(0.38, 0.40, 0.09), Color("202e3d"))
		for x in [-0.105, 0.105]:
			block(self, Vector3(x, 1.13, -0.21), Vector3(0.12, 0.13, 0.04), Color("2c3c4d"))
		block(self, Vector3(-0.11, 1.35, -0.202), Vector3(0.065, 0.08, 0.014), Color("ccb974"))
		block(self, Vector3(0.19, 1.39, -0.16), Vector3(0.065, 0.10, 0.06), black)
		block(self, Vector3(0.19, 1.49, -0.16), Vector3(0.013, 0.13, 0.013), black)
		ellipsoid(self, Vector3(0, 1.88, 0), Vector3(0.34, 0.12, 0.32), pants)
		ellipsoid(self, Vector3(0, 1.83, -0.13), Vector3(0.34, 0.025, 0.30), pants)
func animate(delta: float, speed: float, working: bool) -> void:
	gait += delta * 8
	for i in 2:
		var swing := sin(gait + i * PI) * minf(speed / 3.1, 1) * 0.4
		legs[i].rotation.x = lerpf(legs[i].rotation.x, swing, minf(delta * 12, 1))
		arms[i].rotation.x = lerpf(arms[i].rotation.x, -0.7 if working else -swing, minf(delta * 12, 1))
