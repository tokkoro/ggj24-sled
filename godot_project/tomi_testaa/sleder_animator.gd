extends Node3D
class_name SlederAnimator

@onready var hip = $laskija/body
@onready var l_arm = $laskija/body/r_hand
@onready var r_arm = $laskija/body/l_hand

var current_turning = 0.0
var current_acc = 0.0
var d = 0.2

var max_hip_angle = 60

var hand_idle_angle = 60
var hand_turn_angle = 5


func _process(delta):
	# set turning 
	hip.rotation = Vector3(0, 0, deg_to_rad(max_hip_angle * current_turning))
	if current_turning > 0:
		l_arm.rotation = Vector3(0, 0, deg_to_rad(lerp(hand_idle_angle, hand_turn_angle, current_turning)))
		r_arm.rotation = Vector3(0, 0, -hand_idle_angle)
	else:
		var t = -current_turning
		l_arm.rotation = Vector3(0, 0, hand_idle_angle)
		r_arm.rotation = Vector3(0, 0, deg_to_rad(lerp(-hand_idle_angle, -hand_turn_angle, t)))

func set_turning(amount: float):
	current_turning = lerp(current_turning, amount, d)
	
func set_acceleration(amount: float):
	current_acc = lerp(current_acc, amount, d)
