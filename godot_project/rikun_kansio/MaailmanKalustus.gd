@tool
extends Node3D

@export
var generate_props := false

@export
var test_mode := false

@export
var delete_props := false

@export
var generate_coins := false

@export
var delete_coins := false

@export
var random_seed := 0

@export
var intended_path_thickness := 20.0

@export var intended_path : Path3D

@export var coin_count : int = 30

const props := [ "res://rompe_scenet/huussi.tscn", "res://rompe_scenet/kivi_1.tscn", "res://rompe_scenet/kivi_2.tscn", "res://rompe_scenet/kivi_3.tscn", "res://rompe_scenet/kivi_4.tscn", "res://rompe_scenet/kuusi.tscn", "res://rompe_scenet/lehtipuu.tscn", "res://rompe_scenet/manty.tscn" ]

func _generate(do_coins:bool):
	var prosit = $"../Propsit"
	var curve : Curve3D = intended_path.curve
	seed(random_seed)
	var space_state := get_world_3d().direct_space_state
	
	if not do_coins:
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
				node.rotate_y(closest_point.length_squared() * 10.0)
				print("a test, ", closest_point)
				continue
			print("not test")

			if dist_from_curve < intended_path_thickness:
				continue

			var node := shapes[shape_index].instantiate()
			prosit.add_child(node)
			node.global_position = pos

	if do_coins:
		var coin_prefab := load("res://rikun_kansio/coin.tscn")
		var curve_length := curve.get_baked_length()
		for i in range(coin_count):
			var t : float = i * curve_length * 1.0 / coin_count
			var start := curve.sample_baked(t) + intended_path.global_position + Vector3.UP * 30.0
			
			var end := start + Vector3.DOWN * 6000
			var query := PhysicsRayQueryParameters3D.create(start, end)
			query.collision_mask = 1 # put all ropeable things on collision_layer 1
			var result := space_state.intersect_ray(query)
			if not result:
				continue

			var pos : Vector3 = result["position"] + Vector3.DOWN * 0.1 + result["normal"] * 1.5
			var node : Node3D = coin_prefab.instantiate()
			prosit.add_child(node)
			print(prosit, ", ", node, ", ", pos, ", ", t)
			node.global_position = pos

func _process(delta):
	if generate_props:
		generate_props = false
		_generate(false)

	if generate_coins:
		generate_coins = false
		_generate(true)
	if delete_props:
		delete_props = false
		var prosit = $"../Propsit"
		for child in prosit.get_children():
			get_tree().queue_delete(child)
	if delete_coins:
		delete_coins = false
		var coinsit = $"../Coins"
		for child in coinsit.get_children():
			get_tree().queue_delete(child)
