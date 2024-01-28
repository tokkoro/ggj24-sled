extends Area3D
class_name GoalArea

@onready var collision_shape_node: CollisionShape3D = $CollisionShape3D
@onready var goal_visu: MeshInstance3D = $GoalDebugVisu
@onready var the_game = $".."

var end_triggered = false


func set_size_pos_rot(size: Vector3, pos: Vector3, rot: Vector3):
	var shape: BoxShape3D = collision_shape_node.shape
	shape.size = size
	global_rotation = rot
	global_position = pos
	var mesh : BoxMesh = goal_visu.mesh
	mesh.size = size
	

func _on_body_entered(body: Node3D):
	if end_triggered:
		return
	if body.is_in_group("Player"):
		print("Finished")
		end_triggered = true
		the_game.on_goal()

func _input(event):
	if event is InputEventKey and event.is_pressed() and not end_triggered:
		var e: InputEventKey = event
		if e.key_label == Key.KEY_G:
			end_triggered = true
			the_game.on_goal()
