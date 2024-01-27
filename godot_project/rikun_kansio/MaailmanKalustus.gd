@tool
extends Node3D

@export
var generate_props := false

@export
var test_mode := false

@export
var delete_props := false

@export
var random_seed := 0

@export
var path_name := "level0_path"

@export
var intended_path_thickness := 20.0

const props := [ "res://rompe_scenet/huussi.tscn", "res://rompe_scenet/kivi_1.tscn", "res://rompe_scenet/kivi_2.tscn", "res://rompe_scenet/kivi_3.tscn", "res://rompe_scenet/kivi_4.tscn", "res://rompe_scenet/kuusi.tscn", "res://rompe_scenet/lehtipuu.tscn", "res://rompe_scenet/manty.tscn" ]

func _generate():
	var intended_path : Path3D = null
	var prosit = $"../Propsit"
	for path in [ $"../level2_path", $"../level0_path", $"../level1_path" ]:
		if not path:
			continue
		if not path.name.contains(path_name):
			continue
		if intended_path:
			print("Matches two paths: ", path_name, ", ", path, " != ", intended_path)
			return
		intended_path = path
	var curve : Curve3D = intended_path.curve
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

		var pos : Vector3 = result["position"] + Vector3.DOWN * 0.1
		var closest_point := curve.get_closest_point(pos - intended_path.global_position) + intended_path.global_position
		var dist_from_curve : float = (closest_point - pos).length()
		if test_mode:
			var node := shapes[shape_index].instantiate()
			prosit.add_child(node)
			node.global_position = closest_point
			print("a test, ", closest_point)
			continue
		print("not test")

		if dist_from_curve < intended_path_thickness:
			continue

		var node := shapes[shape_index].instantiate()
		prosit.add_child(node)
		node.global_position = pos

func _process(delta):
	if generate_props:
		generate_props = false
		_generate()
	if delete_props:
		delete_props = false
		var prosit = $"../Propsit"
		for child in prosit.get_children():
			get_tree().queue_delete(child)
