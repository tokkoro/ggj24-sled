extends RigidBody3D
class_name Sled
## turning sled with human in

@onready var sled_mesh = $SledModel
@onready var ground_ray = $SledModel/GroundDetector
@onready var ground_ray_for_normal = $SledModel/GroundNormalDetector
@onready var animator: SlederAnimator = $SledModel/SledVisual/Pulkkailija_origo

var acceleration = 1200.0
var turning = 40  # degrees per second
var max_turning = 15
var turn_stop_limit = 0.75
var sphere_offset = Vector3.DOWN
var body_tilt = 35
var jump_power = 20

var speed_input = 0  # speeeed!!
var turn_input = 0
var jump_input = 0

var can_move = false

var can_jump = 0
var jump_cost = -0.3

var stop_me = false
var camera: FollowerCamera
var start_rotation: Vector3
var graphics_up := Vector3(0,1,0)

var victory = false
var turbo = false

var touch_screen_jump_input := false
var prev_mouse_pos : Vector2

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed and event.index > 1:
			touch_screen_jump_input = true

func _physics_process(delta):
	if stop_me:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		global_rotation = start_rotation
		can_jump = 0
		stop_me = false
		if not camera:
			camera = get_viewport().get_camera_3d()
		camera.force_move()
		
	if Engine.is_editor_hint() and Input.is_key_pressed(KEY_G):
		on_victory()

	var n = ground_ray_for_normal.get_collision_normal()
	var xform = align_with_y(sled_mesh.global_transform, n)
	graphics_up = graphics_up.slerp(xform.basis.y.normalized(), 10.0 * delta)
	sled_mesh.position = position + sphere_offset
	sled_mesh.global_basis.y = graphics_up.normalized()
	sled_mesh.rotation.y = rotation.y
	if ground_ray.is_colliding():
		var force = sled_mesh.global_transform.basis.z * -speed_input
		
		var turbo_boost = 1
		turbo = Input.is_key_pressed(KEY_SHIFT) and OS.has_feature("editor")
		if turbo:
			turbo_boost = 100
		apply_central_force(force * delta * turbo_boost)

	if abs(jump_input) > 1:
		var extra = 1
		if victory:
			extra = -0.6
		var forward_power : Vector3 = -transform.basis.z * jump_input
		if victory:
			forward_power = Vector3() 
		apply_central_impulse(Vector3(0, jump_input * extra, 0) + forward_power)
		jump_input = 0

func _process(delta):
	if can_jump < 0.1:
		can_jump += delta
		if victory:
			can_jump += 2 * delta
	turn_input = Input.get_axis("turn_right", "turn_left") * deg_to_rad(turning)
	if not can_move:
		return
	if ground_ray.is_colliding():
		#jump
		if (Input.is_action_just_pressed("jump") or touch_screen_jump_input or victory) and can_jump > 0:
			can_jump = jump_cost
			jump_input = jump_power
			touch_screen_jump_input = false
		speed_input = Input.get_axis("break", "accelerate") * acceleration

	if not prev_mouse_pos:
		prev_mouse_pos = get_viewport().get_mouse_position()
	else:
		var new_mouse_pos := get_viewport().get_mouse_position()
		var mouse_delta := new_mouse_pos - prev_mouse_pos
		prev_mouse_pos = new_mouse_pos
		const aim_velocity := Vector2(30, -10)
		var relative_delta := mouse_delta / Vector2(get_viewport().size) * aim_velocity
		if Input.get_mouse_button_mask() != 0:
			const touch_turn_multiplier := 10
			turn_input -= relative_delta.x * touch_turn_multiplier * (60 * delta)

	var t = -turn_input / body_tilt
	sled_mesh.rotation.z = lerp(sled_mesh.rotation.z, -t * 40, 5.0 * delta)
	if linear_velocity.length() > turn_stop_limit:
		var turning_multi_per_speed =  linear_velocity.length()
		# print("speed", turning_multi_per_speed)
		turning_multi_per_speed = clamp(turning_multi_per_speed, 1, max_turning)
		apply_torque_impulse(global_basis.y * -t * delta * 100 * turning_multi_per_speed)
	# Animate
	animator.set_turning(Input.get_axis("turn_right", "turn_left"))
	animator.set_acceleration(Input.get_axis("break", "accelerate"))
	animator.set_jump(not ground_ray.is_colliding())

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
	
func stop(start_rot: Vector3):
	start_rotation = start_rot
	stop_me = true
	
func enable_move():
	can_move = true

func on_victory():
	victory = true
	animator.set_victory()
