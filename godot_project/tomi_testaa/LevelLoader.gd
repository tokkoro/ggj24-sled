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
	preload("res://level4_propsit.tscn"),
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

	if event is InputEventScreenTouch:
		if event.pressed and event.index == 4:
			current_level = (current_level + 1) % 5
			load_level()

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
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
	
	update_coin_label()


var results = [
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

###
# Coin system
###

func v3_to_index(v3: Vector3):
	# y is not used as coins move up and down
	return str(int(round(v3.x))) + "," + str(int(round(v3.z)))


var coins_per_level = [
	Dictionary(),
	Dictionary(),
	Dictionary(),
	Dictionary(),
	Dictionary(),
	Dictionary(),
]

func register_coin(c_pos: Vector3):
	# returns whether coin is collected or not
	var index = v3_to_index(c_pos)
	if coins_per_level[current_level].has(index):
		return coins_per_level[current_level][index]
	else:
		coins_per_level[current_level][index] = false
	return false

func get_coin_count(level_num: int):
	var total = 0
	for c in coins_per_level[level_num]:
		if coins_per_level[level_num][c]:
			total += 1
	return total

func update_coin_label():
	var global_total = 0
	var global_count = 0
	
	var result = "COINS:\n"
	for i in range(len(coins_per_level)):
		var coins = coins_per_level[i]
		var coin_count = get_coin_count(i)
		var coin_max = len(coins)
		if coin_max > 1:
			result += "Map_" + str(i) + ": " + str(coin_count) + " / " + str(coin_max) + "\n"
			global_count += coin_count
			global_total += coin_max
	if global_total < 3:
		return ""
	
	# add total
	result += "TOTAL: " + str(global_count) + " / " + str(global_total)
	root_scene_ref.get_node("TheGame").update_coin_lable(result)

func coin_collected(c_pos:Vector3):
	var index = v3_to_index(c_pos)
	coins_per_level[current_level][index] = true
	update_coin_label()


