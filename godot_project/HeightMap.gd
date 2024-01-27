extends MeshInstance3D

var original_pos : Vector3

func _ready():
	original_pos = position
	var image:Image = load("res://graphics/heightmap.png")
	
	var w = image.get_width()
	var h = image.get_height()
	
	var m = PlaneMesh.new();
	m.subdivide_width = w - 1
	m.subdivide_depth = h - 1
	
	m.material = mesh.material
	
	mesh = m
	
	# First, create a StaticBody3D node
	var static_body = StaticBody3D.new()
	add_child(static_body)
	
	static_body.transform = static_body.transform.scaled(Vector3(1.0, 1.0, 1.0) * 2 / w)
	
	# Then create a CollisionShape3D node and attach it to the StaticBody3D
	var collision_shape = CollisionShape3D.new()
	static_body.add_child(collision_shape)
	
	# Generate a new HeightMapShape3D
	var s = HeightMapShape3D.new()
	# Assign the HeightMapShape3D to the CollisionShape3D's 'shape' property
	collision_shape.shape = s
	
	# Create a flat heightmap data array
	var heightmap_data = PackedFloat32Array()
	for y in range(0,h):
		for x in range(0,w):
			heightmap_data.append(image.get_pixel(x, y).r * w / 2)

	s.map_width = w
	s.map_depth = h
	s.map_data = heightmap_data

func _process(delta):
	var t = Time.get_ticks_msec() / 1000.0
	position = original_pos + Vector3(sin(t), cos(t * 2), cos(t))
