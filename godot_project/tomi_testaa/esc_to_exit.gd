extends Node

func _input(event):
	if event.is_action_pressed("ui_cancel") and OS.has_feature("web"):
		get_tree().quit()
	
