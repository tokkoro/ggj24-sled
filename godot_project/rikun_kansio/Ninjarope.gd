extends MeshInstance3D
class_name Ninjarope

@onready var player = $".."
var hook: Node3D = null

var target: Node3D = null
var target_offset := Vector3(10, -1, 10)
var target_pos := Vector3()
var original_length : float

func _ready():
	hook = get_tree().current_scene.find_child("Hook")
	hook.position = Vector3(0,-100,0)

func _input(event):
	if event is InputEventMouseButton:
		print(event)
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if event.pressed:
				# raycast from camera to mouse
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
					# hit something, save the hit offset to that something, and attach the hook there
					target_offset = (mouse_position_3D - target_object.global_position)
					target = target_object
					original_length = (mouse_position_3D - global_position).length()
					hook.look_at_from_position(global_position, mouse_position_3D)
					hook.global_position = mouse_position_3D
					print(hook.global_position)

func _process(delta):
	if not Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
		target = null
	
	var real_target := Vector3()
	var real_target_global := global_position
	if target:
		real_target_global = target.global_position + target_offset
		global_rotation = Vector3()
		var diff : Vector3 = -(global_position - real_target_global)
		var dir : Vector3 = diff.normalized()
		var len : float = diff.length()
		const snap_back_force_multiplier_squared := 5
		const snap_back_force_multiplier := 20
		const anti_explosion_max_force := 500
		const min_length := 3.0

		var force : float = min(pow(max((len - original_length) * snap_back_force_multiplier_squared, 0.0), 1.0) * snap_back_force_multiplier, anti_explosion_max_force) * delta
		player.apply_impulse(dir * force, global_position - player.global_position)
		var shortening_per_second := 0.0
		original_length = max(min_length, original_length - delta * shortening_per_second)
	else:
		hook.global_rotation = lerp(hook.global_rotation, global_rotation, 0.7)
		real_target_global += -global_basis.z
	
	hook.global_position = lerp(hook.global_position, real_target_global, 0.5)

	var hook_attachment_point_offset := hook.global_basis.z * 0.7
	var shader_material : ShaderMaterial = mesh.surface_get_material(0)
	shader_material.set_shader_parameter("target_pos", hook.global_position + hook_attachment_point_offset - global_position)
