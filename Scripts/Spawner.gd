extends StaticBody2D

export (int) var count: int = 3
export (String) var enemy_path: String = "res://Scenes/Enemy.tscn"

const INTERVAL = 10
const MAX_HEALTH = 60

var spawned: int = 0
var tick: float = 0
var enemy = load(enemy_path)
var health: int
var rand: RandomNumberGenerator = RandomNumberGenerator.new()

signal enemy_defeated()

func _ready():
	health = MAX_HEALTH
	add_to_group("enemies")

func _process(delta):
	if spawned >= count: return
	tick += delta
	if tick > INTERVAL:
		var spawn_rotation = rand.randf() * 2 * PI
		var new_enemy = enemy.instance()
		new_enemy.position = self.global_position + (Vector2(cos(spawn_rotation) * 65, sin(spawn_rotation) * 65))
		new_enemy.rotation = spawn_rotation
		get_node("/root/World").add_child(new_enemy)
		tick = 0
		spawned += 1
		
func hurt(damage):
	health -= damage
	if health <= 0: kill()
	else:
		var spawn_rotation = rand.randf() * 2 * PI
		var new_enemy = enemy.instance()
		new_enemy.position = self.global_position + (Vector2(cos(spawn_rotation) * 65, sin(spawn_rotation) * 65))
		new_enemy.rotation = spawn_rotation
		get_node("/root/World").add_child(new_enemy)
	
func kill(): 
	emit_signal("enemy_defeated")
	queue_free()

func _on_VisibilityNotifier2D_screen_entered():
	self.set_process(true)

func _on_VisibilityNotifier2D_screen_exited():
	self.set_process(false)
