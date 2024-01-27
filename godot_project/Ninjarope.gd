extends MeshInstance3D
class_name Ninjarope

@onready var player = $".."
#@onready var spring_joint: Generic6DOFJoint3D = $SpringJoint

var target: Node3D = null
var target_offset := Vector3(10, -1, 10)
var target_pos := Vector3()
var original_length : float

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if event.pressed:
				var viewport := get_viewport()
				var mouse_position := viewport.get_mouse_position()
				var camera := viewport.get_camera_3d()

				var space_state := get_world_3d().direct_space_state
				var start := camera.project_ray_origin(mouse_position);
				var end := camera.project_ray_normal(mouse_position) * 1000;
				var query := PhysicsRayQueryParameters3D.create(start, end)
				query.collision_mask = query.collision_mask & (~player.collision_layer)
				query.exclude.append(player.get_rid())
				var result := space_state.intersect_ray(query)
				
				var mouse_position_3D:Vector3 = result.get("position", Vector3(0,10,0))
				var target_object = result.get("collider", null)
				if target_object:
					target_offset = (mouse_position_3D - target_object.global_position)
					target = target_object
					print(target)
					original_length = (mouse_position_3D - global_position).length()
					#spring_joint.set_node_a(player.get_path())
					#spring_joint.set_node_b(target.get_path())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
		target = null
		#spring_joint.set_node_a(NodePath())
		#spring_joint.set_node_b(NodePath())
	
	var real_target := Vector3()
	if target:
		#print(spring_joint.linear_limit_x)
		real_target = (global_position - target.global_position - target_offset)
		global_rotation = Vector3()
		var diff : Vector3 = -real_target
		var dir : Vector3 = diff.normalized()
		var len : float = diff.length()
		var force : float = pow(max((len - original_length) * 5.0, 0.0), 2.0) * delta * 10
		player.apply_impulse(dir * force)
		original_length = max(1.0, original_length - delta)
		print(len, " / ", original_length, " -> ", force)
	target_pos = lerp(target_pos, real_target, 1.0)
	
	var shader_material : ShaderMaterial = mesh.surface_get_material(0)
	shader_material.set_shader_parameter("target_pos", target_pos)

	

