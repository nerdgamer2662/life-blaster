extends Node2D

var bullet_scene := load("res://Scenes/Laser.tscn")
var bomb_scene := load("res://Scenes/Bomb.tscn")

const SCATTER_ANGLE = PI / 12
const SHOT_BUFFER = 10


func shoot():
	var bullet = bullet_scene.instance()
	bullet.global_position = self.global_position
	bullet.global_rotation = get_parent().global_rotation
	get_node("/root/World").add_child(bullet)
	bullet.exclude_body(get_parent())
	
func bomb():
	var bomb = bomb_scene.instance()
	bomb.global_position = self.global_position
	bomb.global_rotation = get_parent().global_rotation
	get_node("/root/World").add_child(bomb)
	
func bounce():
	var bullet = bullet_scene.instance()
	bullet.global_position = self.global_position
	bullet.global_rotation = get_parent().global_rotation
	get_node("/root/World").add_child(bullet)
	bullet.exclude_body(get_parent())
	bullet.toggle_bouncing()
	
func scatter():
	for n in range(3):
		var bullet = bullet_scene.instance()
		get_node("/root/World").add_child(bullet)
		var buffer = (n * SHOT_BUFFER) - SHOT_BUFFER
		bullet.global_rotation = get_parent().global_rotation + (n * SCATTER_ANGLE) - SCATTER_ANGLE
		bullet.global_position = self.global_position + (Vector2(-sin(bullet.global_rotation), cos(bullet.global_rotation)) * buffer)
		bullet.exclude_body(get_parent())
