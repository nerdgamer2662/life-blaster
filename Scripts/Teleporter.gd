extends Node2D

export (String) var path = "res://Scenes/Level1.tscn"

signal change_level(level_to)

func _ready():
	add_to_group("teleporters")
	assert(connect("change_level", get_tree().get_nodes_in_group("player")[0], "next_level") == OK)

func _on_Area2D_body_entered(_body):
	emit_signal("change_level", path)
