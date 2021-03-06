extends Node2D

signal pause

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"): get_tree().quit()
	
	elif event.is_action_pressed("p"): 
		emit_signal("pause")
		get_tree().paused = !get_tree().paused
