extends Node3D

var current_level = 0
var start_level = 0
var level_count = 3
var levels = [
	preload("res://models/level0.glb"), 
	preload("res://models/level1.glb"),
	preload("res://models/level2.glb"),
	preload("res://models/level3.glb"),
]
var props = [
	preload("res://level0_propsit.tscn"),
	preload("res://level1_propsit.tscn"),
	preload("res://level2_propsit.tscn"),
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

func next_level():
	current_level += 1
	wait_for_next_level = true
	load_next_level_timer = 7

