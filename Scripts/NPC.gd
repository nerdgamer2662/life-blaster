extends StaticBody2D

signal send_text(text)

export (String) var dialogue = "I don't have anything to say. Sorry."

func _ready():
	add_to_group("talkers")
	assert(connect("send_text", get_node("/root/World/GUILayer/Dialogue"), "update_text") == OK)

func talk():
	emit_signal("send_text", dialogue)
