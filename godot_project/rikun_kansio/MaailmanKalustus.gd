@tool
extends Node3D


const props := [ "res://rompe_scenet/huussi.tscn", "res://rompe_scenet/kivi_1.tscn", "res://rompe_scenet/kivi_2.tscn", "res://rompe_scenet/kivi_3.tscn", "res://rompe_scenet/kivi_4.tscn", "res://rompe_scenet/kuusi.tscn", "res://rompe_scenet/lehtipuu.tscn", "res://rompe_scenet/manty.tscn" ]

@onready var prosit = $"../Propsit"

var random_seed := 0

func _ready():
	seed(random_seed)
	var space_state := get_world_3d().direct_space_state
	
	var shapes : Array[PackedScene] = []
	
	for prop in props:
		#print(prop)
		shapes.append(load(prop))
		#print(shapes[-1])
	
	for i in range(5000):
		var start := Vector3(randf_range(-1000, 1000), 3000, randf_range(-1000, 1000))
		var shape_index := randi_range(0, len(shapes) - 1)
		var end := start + Vector3.DOWN * 6000
		var query := PhysicsRayQueryParameters3D.create(start, end)
		query.collision_mask = 1 # put all ropeable things on collision_layer 1
		var result := space_state.intersect_ray(query)
		if not result:
			continue

		var node := shapes[shape_index].instantiate()
		node.global_position = result["position"]
		prosit.add_child(node)
		print(node.global_position)
		
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
