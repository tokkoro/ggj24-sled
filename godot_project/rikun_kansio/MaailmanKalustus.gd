@tool
extends Node3D

@export
var generate_props := false

@export
var delete_props := false

@export
var random_seed := 0

const props := [ "res://rompe_scenet/huussi.tscn", "res://rompe_scenet/kivi_1.tscn", "res://rompe_scenet/kivi_2.tscn", "res://rompe_scenet/kivi_3.tscn", "res://rompe_scenet/kivi_4.tscn", "res://rompe_scenet/kuusi.tscn", "res://rompe_scenet/lehtipuu.tscn", "res://rompe_scenet/manty.tscn" ]

@onready var prosit = $"../Propsit"

func _generate():
	seed(random_seed)
	var space_state := get_world_3d().direct_space_state
	
	var shapes : Array[PackedScene] = []
	
	for prop in props:
		shapes.append(load(prop))
	
	for i in range(5000):
		var start := Vector3(randf_range(-1000, 1000), 3000, randf_range(-1000, 1000))
		var shape_index := randi_range(0, len(shapes) - 1)
		if shape_index == 0 and randi_range(0, 4) != 0:
			continue # don't generate too many toilets
		
		var end := start + Vector3.DOWN * 6000
		var query := PhysicsRayQueryParameters3D.create(start, end)
		query.collision_mask = 1 # put all ropeable things on collision_layer 1
		var result := space_state.intersect_ray(query)
		if not result:
			continue

		var node := shapes[shape_index].instantiate()
		prosit.add_child(node)
		node.global_position = result["position"] + Vector3.DOWN * 0.1

func _process(delta):
	if generate_props:
		generate_props = false
		_generate()
	if delete_props:
		delete_props = false
		for child in prosit.get_children():
			get_tree().queue_delete(child)
