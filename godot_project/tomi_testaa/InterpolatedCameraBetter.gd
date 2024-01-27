extends Camera3D
class_name FollowerCamera

@export var lerp_speed := 3.0
@export var offset := Vector3.ZERO
@export var target : Node
var look_distance := 3.0

var snap_to = false

func _process(delta):
	if !target:
		return
	if snap_to:
		var target_pos = target.global_transform.translated_local(offset)
		global_transform = global_transform.interpolate_with(target_pos,1)
		snap_to = false
	else:
		var follow_point : Vector3 = target.global_position + Vector3.UP * offset.y
		var dist := global_position - follow_point
		var follow_distance :float= abs(offset.z)
		if dist.length() > follow_distance:
			global_position = follow_point + dist.normalized() * follow_distance

	look_at(target.global_position + (target.transform.basis.z * Vector3(1,0,1)).normalized() * -look_distance, Vector3.UP)

func force_move():
	snap_to = true
		
