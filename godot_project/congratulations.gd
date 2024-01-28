extends MeshInstance3D


var origina_scale : Vector3
var origina_pos : Vector3
var origina_rot : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	origina_scale = scale
	origina_pos = position
	origina_rot = rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var t = Time.get_ticks_msec()
	scale = origina_scale * (1 + 0.15 * sin(t/400.0))
	position.y = origina_pos.y + 0.517 * (1 + 0.1 * (sin(t/700.0 + 3.1415/2)-1))
	rotation.y = origina_rot.y - 0.1 * cos(t/500.0)
	rotation.z = origina_rot.z + 0.3 * cos(t/1000.0)
	
