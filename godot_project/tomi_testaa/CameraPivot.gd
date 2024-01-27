@tool
extends Camera3D

@export var lerp_speed = 3.0
@export var target: Node3D
@export var offset = Vector3.ZERO

func _physics_process(delta):
	if !target or Engine.is_editor_hint():
		return
	lerp_camera(delta)

func _process(delta):
	if !Engine.is_editor_hint():
		return
	lerp_camera(delta)

func lerp_camera(delta):
	var target_xform = target.global_transform.translated_local(offset)
	global_transform = global_transform.interpolate_with(target_xform, lerp_speed*delta)
	
	look_at(global_transform.origin, target.transform.basis.y)
