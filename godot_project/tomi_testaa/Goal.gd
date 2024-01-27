extends Area3D
class_name GoalArea

@onready var collision_shape_node:CollisionShape3D = $CollisionShape3D
@onready var goal_visu:MeshInstance3D = $GoalDebugVisu
@onready var the_game:= $".."

func set_size_pos_rot(size: Vector3, pos: Vector3, rot: Vector3):
	var shape: BoxShape3D = collision_shape_node.shape
	shape.size = size
	global_rotation = rot
	global_position = pos
	var mesh : BoxMesh = goal_visu.mesh
	mesh.size = size
	

func _on_body_entered(body: Node3D):
	if body.is_in_group("Player"):
		print("Finished")
		the_game.move_player_to_start()
