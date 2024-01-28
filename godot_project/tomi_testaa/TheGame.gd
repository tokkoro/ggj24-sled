extends Node
class_name TheGame

@export var start_pos_offset = Vector3.UP*10
@onready var goal: GoalArea = $GoalArea
@onready var time_label = $"../Camera3D/time"
@onready var level_loader = $"../.."
@onready var info_label = $"../Camera3D/TotalInfoLabel"

var start_node: Node3D
var end_node: Node3D
@export var player: Sled
var camera: FollowerCamera
@export var count_down_label: CountDownLabel

var run_start_time: int  # milliseconds when start happened
var run_has_started = false
var previous_timer_second = -1

var run_ended = false
var run_end_time = 0 # milliseconds when end happened


func on_goal():
	run_ended = true
	run_end_time = Time.get_ticks_msec()
	var duration = run_end_time - run_start_time
	var s = floor(duration / 1000.0)
	var ms = duration % 1000
	var time_str = get_time_str(s)
	var text_mesh: TextMesh = time_label.mesh
	time_label.start_pulsing()
	text_mesh.text = time_str + "." + ("%03d" % ms)
	player.on_victory()
	level_loader.next_level(duration)

func get_time_str(s: int) -> String:
	var minutes = floor(s / 60.0)
	var seconds = s % 60
	var mid = ":"
	#if seconds < 10:
	#	mid = ":0"
	var time_str = str(minutes) + mid + ("%02d" % seconds)
	return time_str

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	if not start_node:
		game_start()
	if Input.is_action_just_pressed("reset"):
		move_player_to_start()
		
	# start game after player hits the ground
	if not run_has_started and player.ground_ray.is_colliding():
		run_has_started = true
		player.enable_move()
		count_down_label.set_label(0)
		run_start_time = Time.get_ticks_msec()
		previous_timer_second = -1
	
	if not run_has_started:
		return
	
	# timing the run
	var time_from_start = Time.get_ticks_msec() - run_start_time
	var s = time_from_start / 1000.0
	if previous_timer_second + 1 < s:
		if previous_timer_second == 0:
			count_down_label.set_label(-2)
		previous_timer_second += 1
		# make run clock
		var time_str = get_time_str(s)
		if s < 0 or level_loader.current_level > level_loader.level_count:
			time_str = ""
		if not run_ended:
			var text_mesh: TextMesh = time_label.mesh
			text_mesh.text = time_str
		
		
	if player.global_position.y < -300:
		print("TOO LOW")
		move_player_to_start()


func game_start():
	start_node = level_loader.level_scene_ref.find_child("hint_start")
	end_node = level_loader.level_scene_ref.find_child("hint_goal")
	if !player:
		player = get_node("..").find_child("Sled")
	if !count_down_label:
		count_down_label = get_node("..").find_child("CountDownLabels")
	count_down_label.set_label(1)
	info_label.mesh.text = level_loader.get_info_label_str()

	if not end_node:
		return # game over

	goal.set_size_pos_rot(end_node.scale*2, end_node.global_position, end_node.global_rotation)

	camera = get_viewport().get_camera_3d()
	# move player to start
	move_player_to_start()
	# wait 3 secs
	run_start_time = Time.get_ticks_msec()

func move_player_to_start():
	player.stop(start_node.global_rotation)
	player.global_position = start_node.global_position + start_pos_offset

