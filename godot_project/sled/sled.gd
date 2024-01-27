extends RigidBody3D
## turning sled with human in

@onready var sled_mesh = $SledModel
@onready var ground_ray = $SledModel/GroundDetector
@onready var sled_mesh_body = $SledModel/SledVisual/Mesh1

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

func _physics_process(delta):
	sled_mesh.position = position + sphere_offset
	if ground_ray.is_colliding():
		apply_central_force(-sled_mesh.global_transform.basis.z * speed_input)
	if abs(jump_input) > 1:
		apply_central_impulse(Vector3(0, jump_input, 0))
		jump_input = 0

func _process(delta):
	if can_jump < 1:
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
		sled_mesh.global_transform = sled_mesh.global_transform.interpolate_with(xform, 10.0 * delta)
	
	if linear_velocity.length() > turn_stop_limit:
		var new_basis = sled_mesh.global_transform.basis.rotated(sled_mesh.global_transform.basis.y, turn_input)
		sled_mesh.global_transform.basis = sled_mesh.global_transform.basis.slerp(new_basis, turning_speed * delta)
		sled_mesh.global_transform = sled_mesh.global_transform.orthonormalized()
		# tiltti
		var t = -turn_input * linear_velocity.length() / body_tilt
		sled_mesh.rotation.z = lerp(sled_mesh.rotation.z, t, 5.0 * delta)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform.orthonormalized()
