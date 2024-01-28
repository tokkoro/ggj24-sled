extends Node3D
class_name SlederAnimator

@onready var hip = $laskija/body
@onready var l_arm = $laskija/body/l_hand
@onready var r_arm = $laskija/body/r_hand
@onready var pulkka = $pulkka

@onready var left_parti = $laskija/body/l_hand/GPUParticles3D
@onready var right_parti = $laskija/body/r_hand/GPUParticles3D
@onready var ninja_rope = $laskija/body/r_hand/Ninjarope

var victory_pos = false
var current_turning = 0.0
var current_acc = 0.0

var d = 0.2

var max_hip_angle = 50
var hand_idle_angle = 60
var hand_turn_angle = 5
var total_tilt_max = 15
var is_in_air = false
var holding_hook = false

func _process(delta):
	
	# hook holding
	if not victory_pos and holding_hook:
		# lean over and grap the point
		pass
	
	# hands in the air
	if victory_pos or is_in_air:
		current_turning = lerp(current_turning, 0.0, 0.5)
		current_acc = lerp(current_acc, 0.0, 0.5)
		l_arm.rotation = Vector3(0, 0, lerp(l_arm.rotation.z, deg_to_rad(-hand_idle_angle), 0.5))
		r_arm.rotation = Vector3(0, 0, lerp(r_arm.rotation.z, deg_to_rad(hand_idle_angle), 0.5))
		left_parti.emitting = false
		right_parti.emitting = false
		
	# set turning
	hip.rotation = Vector3(0, 0, deg_to_rad(max_hip_angle * current_turning))
	pulkka.rotation = Vector3(0, 0, deg_to_rad(total_tilt_max * current_turning))
	
	if victory_pos or is_in_air:
		pass
	else:
		# handling hands
		if current_turning > 0:
			l_arm.rotation = Vector3(0, 0, deg_to_rad(lerp(hand_idle_angle, hand_turn_angle, current_turning)))
			r_arm.rotation = Vector3(0, 0, -deg_to_rad(hand_idle_angle))
			right_parti.emitting = false
			left_parti.emitting = current_turning > 0.9
		else:
			var t = -current_turning
			l_arm.rotation = Vector3(0, 0, deg_to_rad(hand_idle_angle))
			r_arm.rotation = Vector3(0, 0, deg_to_rad(lerp(-hand_idle_angle, -hand_turn_angle, t)))
			left_parti.emitting = false
			right_parti.emitting = current_turning < -0.9

func set_turning(amount: float):
	current_turning = lerp(current_turning, amount, d)
	
func set_acceleration(amount: float):
	current_acc = lerp(current_acc, amount, d)
	
func set_victory():
	victory_pos = true

func set_jump(jumpping: bool):
	is_in_air = jumpping
