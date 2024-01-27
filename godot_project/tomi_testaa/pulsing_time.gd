extends MeshInstance3D
class_name PulsingTime

var is_pulsing = false
var pulse_start:int

func start_pulsing():
	is_pulsing = true
	pulse_start = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_pulsing:
		return
	
	var t = Time.get_ticks_msec() - pulse_start
	scale = Vector3.ONE * (1 + 0.15 * sin(t/200.0))
	position.y = 0.517 * (1 + 0.1 * (sin(t/200.0 + 3.1415/2)-1))

