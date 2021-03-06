extends KinematicBody2D

const PROJECTILE_SPEED = 1000
const MAX_BOUNCES = 3

var excluded_bodies: Array = []
var velocity: Vector2 = Vector2()
var bounces: int = 0
var bounce: bool = false

func _ready():
	add_to_group("bullets")
	for bullet in get_tree().get_nodes_in_group("bullets"):
		exclude_body(bullet)
	call_deferred("define_velocity")
	$FireSound.play()

func _process(delta):
	# Also a part of the memory leak prevention
	if (bounces > MAX_BOUNCES): explode()
	# This ensures we don't have sidewinding lasers.
	global_rotation = atan(velocity.y / velocity.x)
	var collision_info = move_and_collide(velocity * delta)
	# This only happens if the laser collides with something.
	if collision_info:
		var body = collision_info.collider
		if body.has_method("hurt") and not(body in excluded_bodies):
			# If the body this laser hits is on the opposing "side" and mortal,
			# it kills the body and explodes.
			body.hurt(20)
			$ExplodeSound.play()
			print("bang!")
			explode()
		elif body != self and bounce:
			# The lasers bounce off of walls, so this must exist. The bounces
			# variable is just to prevent memory leaks.
			velocity = velocity.bounce(collision_info.normal)
			bounces += 1
		else: explode()
			
# You shouldn't be able to kill yourself with a stray bounced bullet, so this 
# exists, and the shooter adds its parent to the excluded bodies after 
# initializing the laser.
func exclude_body(body):
	excluded_bodies.append(body)
	
# Godot doesn't like accessing the laser's rotation before it is defined by the 
# shooter, so it must be defined within a function, which is then called deferred.
func define_velocity():
	velocity = Vector2(cos(global_rotation), sin(global_rotation)) * PROJECTILE_SPEED

# If the laser exits the screen it stops existing.
func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	queue_free()
	
func toggle_bouncing():
	bounce = !bounce
	
func explode():
	self.visible = false
	if $CollisionShape2D: $CollisionShape2D.disabled = true
	yield($ExplodeSound, "finished")
	queue_free()
