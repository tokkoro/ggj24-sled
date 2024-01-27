extends Node3D
class_name CountDownLabel

@onready var obj_ready = $ready
@onready var obj_go = $go

func set_label(num: int):
	if num >= 1:
		$Ping.play()
	if num == 0:
		$Ping.pitch_scale = 1.5
		$Ping.play()
	obj_ready.visible = num >= 1
	obj_go.visible = num == 0
