extends RigidBody3D
class_name Sled
## turning sled with human in

@onready var sled_mesh = $SledModel
@onready var ground_ray = $SledModel/GroundDetector

@export_group("Sled's properties")
@export var acceleration = 35.0
@export var turning = 18.0  # degrees
@export var turning_speed = 4.0
@export var turn_stop_limit = 0.75
@export var sphere_offset = Vector3.DOWN
@export var body_tilt = 35
@export var jump_power = 10

@export_group("inputs for debug")
@export var speed_input = 0  # speeeed!!

# how much turning from input!
@export var turn_input = 0
@export var jump_input = 0
var can_jump = 0
var jump_cost = -0.3

var stop_me = false
var camera: FollowerCamera
var start_rotation: Vector3

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
	sled_mesh.position = position + sphere_offset
	sled_mesh.rotation = rotation
	if ground_ray.is_colliding():
		apply_central_force(-sled_mesh.global_transform.basis.z * speed_input)
	if abs(jump_input) > 1:
		apply_central_impulse(Vector3(0, jump_input, 0))
		jump_input = 0

func _process(delta):
	if can_jump < 0.1:
		can_jump += delta
	turn_input = Input.get_axis("turn_right","turn_left") * deg_to_rad(turning)
	if ground_ray.is_colliding():
		#jump
		if Input.is_action_just_pressed("jump") and can_jump > 0:
			can_jump = jump_cost
			jump_input = jump_power
			
		speed_input = Input.get_axis("break", "accelerate") * acceleration
		var n = ground_ray.get_collision_normal()
		var xform = align_with_y(sled_mesh.global_transform, n)
	
	if linear_velocity.length() > turn_stop_limit:
		var t = -turn_input * linear_velocity.length() / body_tilt
		apply_torque_impulse(global_basis.y * -t * delta * 100)
		# tiltti
		sled_mesh.rotation.z = lerp(sled_mesh.rotation.z, t, 5.0 * delta)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
	
func stop(start_rot: Vector3):
	start_rotation = start_rot
	stop_me = true
	
