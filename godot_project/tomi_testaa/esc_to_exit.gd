extends Node

func _input(event):
	if event.is_action_pressed("ui_cancel") and OS.get_name() != "Web":
		get_tree().quit()
	
