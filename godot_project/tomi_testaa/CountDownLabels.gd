extends Node3D
class_name CountDownLabel

@onready var obj1 = $l1
@onready var obj2 = $l2
@onready var obj3 = $l3
@onready var obj_go = $go

func set_label(num: int):
	if num == 3 || num == 2 || num == 1:
		$Ping.play()
	if num == 0:
		$Ping.pitch_scale = 1.5
		$Ping.play()
	obj_go.visible = num == 0
	obj1.visible = num == 1
	obj2.visible = num == 2
	obj3.visible = num == 3
