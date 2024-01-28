extends WorldEnvironment
class_name EnvironmentChanger

var skyboxes = [
	load("res://skies/sky0.png"),
	load("res://skies/sky1.png"),
	load("res://skies/sky2.png"),
	load("res://skies/sky3.png"),
]

var fog_densities = [
	0.0,
	0.005,
	0.005,
	0.005,
	0.005,
]

@onready var level_loader: LevelLoader = $"../.."

func _ready():
	set_level(level_loader.current_level)
	
func set_level(level_num: int):
	environment.fog_density = fog_densities[level_num]
	var mat: PanoramaSkyMaterial= environment.sky.sky_material
	mat.panorama = skyboxes[level_num]
