extends Node
class_name TheGame

@export var start_pos_offset = Vector3.UP*10
@onready var goal: GoalArea = $GoalArea
@onready var time_label = $"../Camera3D/time"
var start_node: Node3D
var end_node: Node3D
var player: Sled
var camera: FollowerCamera
var count_down_label: CountDownLabel

var run_start_time: int
var run_has_started = false
var previous_start_second = -1

var run_ended = false
var run_end_time = 0

func on_goal():
	run_ended = true
	run_end_time = Time.get_ticks_msec()
	var duration = run_end_time - run_start_time
	var s = floor(duration / 1000)
	var ms = duration % 1000
	var time_str = get_time_str(s)
	var text_mesh: TextMesh = time_label.mesh
	text_mesh.text = time_str + "." + ("%03d" % ms)

func get_time_str(s: int) -> String:
	var minutes = floor(s / 60)
	var seconds = s % 60
	var mid = ":"
	#if seconds < 10:
	#	mid = ":0"
	var time_str = str(minutes) + mid + ("%02d" % seconds)
	return time_str

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not start_node:
		game_start()
	if Input.is_action_just_pressed("reset"):
		move_player_to_start()
	# count down
	var time_from_start = Time.get_ticks_msec() - run_start_time
	var s = time_from_start / 1000
	if previous_start_second + 1 < s:
		previous_start_second += 1
		var count_down_num = 4 - s
		count_down_label.set_label(count_down_num)
		if previous_start_second > 2:
			run_has_started = true
			player.enable_move()
		# make run clock
		s -= 4
		var time_str = get_time_str(s)
		if s < 0:
			time_str = ""
		if not run_ended:
			var text_mesh: TextMesh = time_label.mesh
			text_mesh.text = time_str
		
		
	if player.global_position.y < -200:
		print("TOO LOW")
		move_player_to_start()


func game_start():
	var root = get_tree().current_scene
	start_node = root.find_child("hint_start")
	print("Gind end knode")
	end_node = root.find_child("hint_goal")
	player = root.find_child("Sled")
	count_down_label = root.find_child("CountDownLabels")
	
	goal.set_size_pos_rot(end_node.scale*2, end_node.global_position, end_node.global_rotation)

	camera = get_viewport().get_camera_3d()
	# move player to start
	move_player_to_start()
	# wait 3 secs
	run_start_time = Time.get_ticks_msec()
	previous_start_second = -1


func generate_goal():
	var goal = 23

func move_player_to_start():
	player.stop(start_node.global_rotation)
	player.global_position = start_node.global_position + start_pos_offset

