extends KinematicBody2D

const PROJECTILE_SPEED = 500
const TIMEOUT: float = 3.0

var excluded_bodies: Array = []
var velocity: Vector2 = Vector2()
var timer: float = 0

func _ready():
	add_to_group("bullets")
	for bullet in get_tree().get_nodes_in_group("bullets"):
		exclude_body(bullet)
	call_deferred("define_velocity")
	$Sprite.texture = load("res://Textures/bullet_bomb.png")

func _process(delta):
	
	timer += delta
	if velocity.length() > 0: global_rotation = atan(velocity.y / velocity.x)
	var collision_info = move_and_collide(velocity * delta)
	# This only happens if the bomb collides with something or 3 seconds passes.
	if (collision_info and not(collision_info.collider in excluded_bodies)) or timer > TIMEOUT:
		explode()
	
	$AnimationPlayer.play("move")
		
func define_velocity():
	velocity = Vector2(cos(global_rotation), sin(global_rotation)) * PROJECTILE_SPEED
	
func explode():
	velocity = Vector2()
	for body in $ExplosionArea.get_overlapping_bodies():
		if body.has_method("hurt"): body.hurt(30)
		
	$Sprite.texture = load("res://Textures/bomb_explosion.png")
	var t = Timer.new()
	t.set_wait_time(0.5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	queue_free()
	
func exclude_body(body):
	excluded_bodies.append(body)
