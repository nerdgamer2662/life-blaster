extends Control

func _ready():
	get_node("/root/World").connect("pause", self, "toggle_visibility")
	self.visible = false
	
func toggle_visibility():
	visible = !visible
	
	

