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

var max_hip_angle := 10.0
var hand_idle_angle := 60.0
var hand_turn_angle := 5.0
var total_tilt_max := 10.0
var is_in_air := true
var falling_speed := -5.0
var holding_hook := false

var force_emit_time = 0.35
var is_prewarm_emit = true

func _process(delta):
	if force_emit_time > 0:
		force_emit_time -= delta
	else:
		is_prewarm_emit = false
	
	# hook holding
	if not victory_pos and holding_hook:
		# lean over and grap the point
		pass
	
	# set turning
	hip.rotation = Vector3(0, 0, deg_to_rad(max_hip_angle * current_turning))
	pulkka.rotation = Vector3(0, 0, deg_to_rad(total_tilt_max * current_turning))

	var l_arm_target := hand_idle_angle
	var r_arm_target := hand_idle_angle
	
	if true:
		# handling hands
		if current_turning > 0:
			l_arm_target = deg_to_rad(lerp(hand_idle_angle, hand_turn_angle, current_turning))
			r_arm_target = -deg_to_rad(hand_idle_angle)
			right_parti.emitting = is_prewarm_emit
			left_parti.emitting = (not is_in_air and current_turning > 0.4) or is_prewarm_emit
		else:
			var t = -current_turning
			l_arm_target = deg_to_rad(hand_idle_angle)
			r_arm_target = deg_to_rad(lerp(-hand_idle_angle, -hand_turn_angle, t))
			left_parti.emitting = is_prewarm_emit
			right_parti.emitting = (not is_in_air and current_turning < -0.4) or is_prewarm_emit

	# hands in the air
	if victory_pos or is_in_air:
		current_turning = lerp(current_turning, 0.0, 0.5)
		current_acc = lerp(current_acc, 0.0, 0.5)
		var f : float = clamp(-falling_speed * 0.2, -0.9, 1.0) * 0.5 + 0.5
		l_arm_target = deg_to_rad(lerp(hand_idle_angle, -hand_idle_angle, f))
		r_arm_target = deg_to_rad(lerp(-hand_idle_angle, hand_idle_angle, f))
		
	var lerp_t = 1.0 - pow(0.0001, delta)
	l_arm.rotation.z = lerp(l_arm.rotation.z, l_arm_target, lerp_t)
	r_arm.rotation.z = lerp(r_arm.rotation.z, r_arm_target, lerp_t)
		
func set_turning(amount: float):
	current_turning = lerp(current_turning, amount, d)
	
func set_acceleration(amount: float):
	current_acc = lerp(current_acc, amount, d)
	
func set_victory():
	victory_pos = true

func set_jump(jumpping: bool):
	is_in_air = jumpping

func set_falling(falling_speed_: float):
	falling_speed = falling_speed_
