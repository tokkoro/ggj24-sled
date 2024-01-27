extends Camera3D
class_name FollowerCamera

@export var lerp_speed = 3.0
@export var offset = Vector3.ZERO
@export var target : Node

var snap_to = false

func _physics_process(delta):
	if !target:
		return
	var target_pos = target.global_transform.translated_local(offset)
	var t =  lerp_speed * delta
	if snap_to:
		t = 1
		snap_to = false
	global_transform = global_transform.interpolate_with(target_pos,t)
	look_at(target.global_position, Vector3.UP)

func force_move():
	snap_to = true
		
