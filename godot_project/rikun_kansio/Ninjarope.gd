extends MeshInstance3D
class_name Ninjarope

@onready var player: Sled = $"../../.."
var hook: Node3D = null
var pointer: Node3D = null

var target: Node3D = null
var target_offset := Vector3(10, -1, 10)
var target_pos := Vector3()
var original_length : float
var extra_impulse := Vector3()
var extra_impulse_cooldwon := 0.0
var audio_player_3d : AudioStreamPlayer3D = null

var ninjarope_hit_sound = preload("res://sounds/hop.wav")
var huussi_sound = preload("res://sounds/fart.ogg")

func _ready():
	hook = get_tree().current_scene.find_child("Hook")
	pointer = get_tree().current_scene.find_child("Pointer")
	audio_player_3d = get_tree().current_scene.find_child("HitAudio3D")
	hook.position = Vector3(0,-100,0)

func get_mouse_hit() -> Dictionary:
	var viewport := get_viewport()
	var mouse_position := viewport.get_mouse_position()
	var camera := viewport.get_camera_3d()
	var space_state := get_world_3d().direct_space_state
	var start := camera.project_ray_origin(mouse_position);
	var end := start + camera.project_ray_normal(mouse_position) * 1000;
	var query := PhysicsRayQueryParameters3D.create(start, end)
	query.collision_mask = 1 # put all ropeable things on collision_layer 1
	query.exclude.append(player.get_rid())
	return space_state.intersect_ray(query)
	
func play_hit_sound(target, mouse_position_3d):
	if target.is_in_group("huussi"):
		audio_player_3d.stream = huussi_sound
	else:
		audio_player_3d.stream = ninjarope_hit_sound
	audio_player_3d.position = mouse_position_3d
	audio_player_3d.play()

func _input(event):
	if not player.can_move:
		return
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			if event.pressed:
				$NinjaRopeFired.play()
				var result : Dictionary = get_mouse_hit()
				var mouse_position_3D:Vector3 = result.get("position", Vector3(0,10,0))
				var target_object = result.get("collider", null)
				if target_object:
					# hit something, save the hit offset to that something, and attach the hook there
					target_offset = (mouse_position_3D - target_object.global_position)
					target = target_object
					const min_length := 10.0
					original_length = max(min_length, (mouse_position_3D - global_position).length())
					hook.look_at_from_position(global_position, mouse_position_3D)
					extra_impulse = ((mouse_position_3D - global_position) * Vector3(1,0,1)).normalized()
					play_hit_sound(target, mouse_position_3D)
					

func _process(delta):
	if pointer:
		var result : Dictionary = get_mouse_hit()
		var pos = result.get("position", Vector3(0, 10000.0, 0))
		pointer.global_position = pos
		pointer.basis.y = result.get("normal", Vector3(0,1,0))

	extra_impulse_cooldwon = min(1.0, extra_impulse_cooldwon + delta / 3.0)
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
		const min_shortened_length := 1.3

		original_length = min(len, original_length)
		var force : float = min(pow(max(max(0.1, len - original_length) * snap_back_force_multiplier_squared, 0.0), 1.0) * snap_back_force_multiplier, anti_explosion_max_force) * delta

		player.apply_impulse(dir * force + extra_impulse * extra_impulse_cooldwon, (global_position - player.global_position) * 0.3)
		if extra_impulse.length_squared() > 0.0:
			extra_impulse_cooldwon = 0.0
			extra_impulse = Vector3()
		var shortening_per_second := 1.0
		original_length = max(min_shortened_length, original_length - delta * shortening_per_second)

	else:
		hook.global_rotation = lerp(hook.global_rotation, global_rotation, 0.7)
		real_target_global += -global_basis.z

	hook.global_position = lerp(hook.global_position, real_target_global, 0.5)

	var hook_attachment_point_offset := hook.global_basis.z * 0.7
	var shader_material : ShaderMaterial = mesh.surface_get_material(0)
	shader_material.set_shader_parameter("target_pos", hook.global_position + hook_attachment_point_offset - global_position)
