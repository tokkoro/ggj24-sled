extends Area3D

@onready var gfx : MeshInstance3D = $gfx
@onready var collect_sound : AudioStreamPlayer3D = $collect_sound

const duration_ms := 1000.0
var collected := false

var delete_time := 1000000000000.0

var level_loader: LevelLoader

func _ready():
	# util: find player in parent
	var g = get_parent()
	var c = 10
	while c > 0:
		c -= 1
		if not(g is LevelLoader):
			g = g.get_parent()
		else:
			level_loader = g
			break

func _process(delta):
	if not collected:
		gfx.rotate_y(delta * 3.0)
		return

	if delete_time < Time.get_ticks_msec():
		queue_free()
		return

	var t : float = max(0.0, 1.0 - (delete_time - Time.get_ticks_msec()) / duration_ms)
	gfx.rotate_y(delta * lerp(3.0, 100.0, t))
	translate(Vector3.UP * delta * lerp(0.0, 10.0, t))
	scale = Vector3.ONE * min(1.0, lerp(10.0, 0.0, t))

func collect():
	if collected:
		return
	collected = true
	delete_time = Time.get_ticks_msec() + duration_ms
	collect_sound.play()
	level_loader.coin_collected()

func _on_body_entered(body):
	if not body is Sled:
		return
	collect()

func _on_area_entered(area):
	if not area or not "Hook" in area.name:
		return
	collect()
