extends Node3D
class_name LevelLoader

var current_level = 0
var start_level = 0
var level_count = 3
var levels = [
	preload("res://models/level0.glb"), 
	preload("res://models/level1.glb"),
	preload("res://models/level2.glb"),
	preload("res://models/level3.glb"),
	preload("res://game_over.tscn"),
]
var props = [
	preload("res://level0_propsit.tscn"),
	preload("res://level1_propsit.tscn"),
	preload("res://level2_propsit.tscn"),
	preload("res://level3_propsit.tscn"),
	preload("res://level3_propsit.tscn"),
]
var root_level = preload("res://tomi_testaa/hill_area.tscn")

var root_scene_ref
var level_scene_ref
var props_scene_ref

var load_next_level_timer = 0
var wait_for_next_level = false

func _input(event):
	if event is InputEventKey and event.is_pressed():
		var e: InputEventKey = event
		if not Input.is_key_pressed(KEY_CTRL):
			return
		if e.key_label == Key.KEY_1:
			current_level = 0
		elif e.key_label == Key.KEY_2:
			current_level = 1
		elif e.key_label == Key.KEY_3:
			current_level = 2
		elif e.key_label == Key.KEY_4:
			current_level = 3
		elif e.key_label == Key.KEY_5:
			current_level = 4
		else:
			return
		load_level()

func _ready():
	current_level = start_level
	load_level()
	
func _process(delta):
	if wait_for_next_level:
		load_next_level_timer -= delta
		if load_next_level_timer < 0:
			wait_for_next_level = false
			load_level()

func load_level():
	var level_num=current_level
	if is_instance_valid(root_scene_ref):
		root_scene_ref.queue_free()
	if is_instance_valid(level_scene_ref):
		level_scene_ref.queue_free()
	if is_instance_valid(props_scene_ref):
		props_scene_ref.queue_free()
	
	level_scene_ref = levels[level_num].instantiate()
	add_child(level_scene_ref)
	root_scene_ref = root_level.instantiate()
	add_child(root_scene_ref)
	props_scene_ref = props[level_num].instantiate()
	add_child(props_scene_ref)


var results = [
	0,
	0,
	0,
	0,
	0,
]

var coin_count = [
	0,
	0,
	0,
	0,
	0,
	0,
]

func next_level(time_s):
	results[current_level] = time_s
	current_level += 1
	wait_for_next_level = true
	load_next_level_timer = 7

func get_info_label_str():
	var result = "TIMES:\n"
	var has_times = false
	var total = 0
	for i in range(len(results)):
		var duration = results[i]
		if duration > 1:
			has_times = true
			var s = floor(duration / 1000.0)
			var ms = duration % 1000
			var time_str = get_time_str(s)
			result += "Map_" + str(i) + ": " + time_str + "." + ("%03d" % ms) + "\n"
			total += duration
	if not has_times:
		return "WASD to move\nSPACE to jump\nMOUSE to hook"
	
	# add total
	var total_s = floor(total / 1000.0)
	var total_ms = total % 1000
	var total_time_str = get_time_str(total_s)
	result += "TOTAL: " + total_time_str + "." + ("%03d" % total_ms)
	
	return result

func get_time_str(s: int) -> String:
	var minutes = floor(s / 60.0)
	var seconds = s % 60
	var mid = ":"
	var time_str = str(minutes) + mid + ("%02d" % seconds)
	return time_str

func coin_collected():
	coin_count[current_level] += 1
	var total = 0
	for c in coin_count:
		total += c
	root_scene_ref.get_node("TheGame").update_coin_lable(total)
