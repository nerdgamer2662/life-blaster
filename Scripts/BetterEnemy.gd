extends KinematicBody2D

onready var player = get_tree().get_nodes_in_group("player")[0]
onready var current_health = START_HEALTH
onready var tween = $Tween

var player_seen := false
var target_pos = Vector2()
var move_path = PoolVector2Array()
var time_passed := 0.0 # seconds
var player_exists := true
var left_barrel: bool = true

const MOVE_SPEED = 64 # pixels
const SHOT_INTERVAL = 0.2 # seconds
const ROT_EPSILON = PI / 9 # radians
const LIN_EPSILON = 2 # Pixels
const START_HEALTH = 120

# Exists for future scoring/mechanical purposes.
signal enemy_defeated()

# Part of the code to ensure the enemy doesn't try to look for a dead player
func _ready():
	player.connect("player_death", self, "stop_process")
# warning-ignore:return_value_discarded
	connect("enemy_defeated", player, "death_heal")
	add_to_group("enemies")

func _physics_process(delta):
	if !player_exists: return
	# Casts a ray towards the player and checks whether the ray is obsructed to 
	# establish vision.
	# TODO: Add a vision cone to ensure the enemies can't see out of the back
	# of their heads
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray($LookPoint.global_position, player.global_position, [$LookPoint])
	if result.collider == player:
		player_seen = true
		# Sets the position to look at to that of the player.
		target_pos = result.collider.global_position
		# The enemy will shoot lasers at the player on an interval.
		if time_passed > SHOT_INTERVAL:
			time_passed = 0
			if left_barrel: $LeftShooter.shoot()
			else: $RightShooter.shoot()
			left_barrel = !left_barrel
	else: player_seen = false
	# The expected behavior from this is that the enemy will slowly turn towards
	# the player and try to move towards them.
	if (target_pos) and abs((target_pos - self.global_position).length()) > LIN_EPSILON:
# warning-ignore:return_value_discarded
		move_and_slide((target_pos - self.global_position).normalized() * MOVE_SPEED)
		var view_angle
		if (player_seen): view_angle = (player.position - self.position).angle()
		else: view_angle = (target_pos - self.position).angle()
		tween.interpolate_property(self, "rotation",
				null, view_angle, 0.25,
				Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
	# Keeps track of how much time has passed since the last shot for timing
	time_passed += delta
	
func hurt(damage):
	current_health -= damage
	if current_health <= 0: kill()

func kill(): 
	emit_signal("enemy_defeated")
	$AnimationPlayer.play("death")
	$AudioStreamPlayer.play()
	set_physics_process(false)
	yield($AnimationPlayer, "animation_finished")
	queue_free()

func stop_process():
	player_exists = false
