extends MeshInstance3D
class_name Ninjarope

var player: Sled
@export var hook_rest_pos: Node3D
@onready var hook_res_pos_hand := $"../HookRestPositionHand"
@export var hook: Node3D
@export var pointer: Node3D

var target: Node3D = null
var offset_to_target := Vector3(10, -1, 10)
var target_pos := Vector3()
var original_length : float
var extra_impulse := Vector3()
var extra_impulse_cooldwon := 0.0
@export var audio_player_3d : AudioStreamPlayer3D

var ninjarope_hit_sound = preload("res://sounds/hop.wav")
var huussi_sound = preload("res://sounds/fart.ogg")

@onready var rope_2 = $"../Rope2"

func _ready():
	# util: find player in parent
	var p = get_parent()
	var c = 10
	while c > 0:
		c -= 1
		if not(p is Sled):
			p = p.get_parent()
		else:
			player = p
			break
	# new level loader super parent breaks these probably
	if !audio_player_3d:
		audio_player_3d = get_tree().current_scene.find_child("HitAudio3D")
	if !hook:
		hook = get_tree().current_scene.find_child("Hook")
		hook.position = Vector3(0,-100,0)
	if !pointer:
		pointer = get_tree().current_scene.find_child("Pointer")


func get_mouse_hit() -> Dictionary:
	var viewport := get_viewport()
	var mouse_position := viewport.get_mouse_position()
	var camera := viewport.get_camera_3d()
	var space_state := get_world_3d().direct_space_state
	var start := camera.project_ray_origin(mouse_position);
	var end := start + camera.project_ray_normal(mouse_position) * 1000;
	var query := PhysicsRayQueryParameters3D.create(start, end)
	query.collision_mask = 1 # we have all ropeable things on collision_layer 1
	query.exclude.append(player.get_rid())
	return space_state.intersect_ray(query)
	
func play_hit_sound(target_node: Node3D, mouse_position_3d: Vector3):
	if target_node.is_in_group("huussi"):
		audio_player_3d.stream = huussi_sound
	else:
		audio_player_3d.stream = ninjarope_hit_sound
	audio_player_3d.position = mouse_position_3d
	audio_player_3d.play()

func _input(event):
	if not player.can_move:
		return
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			$NinjaRopeFired.play()
			var result: Dictionary = get_mouse_hit()
			var mouse_hit_position_3D:Vector3 = result.get("position", Vector3(0,10,0))
			var target_object = result.get("collider", null)
			if target_object:
				# hit something, save the hit offset to that something, and attach the hook there
				offset_to_target = (mouse_hit_position_3D - target_object.global_position)
				target = target_object
				const min_length = 10.0
				original_length = max(min_length, (mouse_hit_position_3D - global_position).length())
				hook.look_at_from_position(global_position, mouse_hit_position_3D)
				extra_impulse = ((mouse_hit_position_3D - global_position) * Vector3(1,0,1)).normalized()
				play_hit_sound(target, mouse_hit_position_3D)

func _physics_process(delta):
	if pointer:
		var result : Dictionary = get_mouse_hit()
		var pos = result.get("position", Vector3(0, 10000.0, 0))
		pointer.global_position = pos
		pointer.basis.y = result.get("normal", Vector3(0,1,0))

	extra_impulse_cooldwon = min(1.0, extra_impulse_cooldwon + delta / 3.0)
	if not Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT) or not player.can_move:
		target = null

	var real_target := Vector3()
	var real_target_global := global_position
	if target:
		real_target_global = target.global_position + offset_to_target
		global_rotation = Vector3()
		var diff: Vector3 = -(global_position - real_target_global)
		var dir: Vector3 = diff.normalized()
		var distance: float = diff.length()
		const snap_back_force_multiplier_squared := 5
		const snap_back_force_multiplier := 20
		const anti_explosion_max_force := 500
		const min_shortened_length := 1.3

		original_length = min(distance, original_length)
		var force: float = min(pow(max(max(0.1, distance - original_length) * snap_back_force_multiplier_squared, 0.0), 1.0) * snap_back_force_multiplier, anti_explosion_max_force) * delta

		player.apply_impulse((dir * force + extra_impulse * extra_impulse_cooldwon)*3, (global_position - player.global_position) * 0.3)
		if extra_impulse.length_squared() > 0.0:
			extra_impulse_cooldwon = 0.0
			extra_impulse = Vector3()
		var shortening_per_second := 1.0
		original_length = max(min_shortened_length, original_length - delta * shortening_per_second)
		
		hook.global_position = lerp(hook.global_position, real_target_global, 0.5)
	else:
		hook.global_rotation = lerp(hook.global_rotation, player.global_rotation, 0.7)
		hook.global_position = lerp(hook.global_position, hook_rest_pos.global_position, 0.75)
	update_rope_pos()


func _process(delta):
	update_rope_pos()


func update_rope_pos():
	var hook_tail_pos = hook.global_position + hook.global_basis.z * 0.7
	rope_2.global_position = hook_res_pos_hand.global_position
	rope_2.look_at(hook_tail_pos, Vector3.UP)
	var distance = (hook_res_pos_hand.global_position - hook_tail_pos).length()
	rope_2.scale = Vector3(1, 1, -distance)
