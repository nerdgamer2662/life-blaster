extends KinematicBody2D

const BLOCK_SIDE = 64
const MOVE_SPEED = 256
const LIN_EPSILON = 2
const BARRAGE_INTERVAL = 0.1
const START_HEALTH = 100
const DEATH_HEAL = 20

var time_passed = 0
var mode = "Normal"
var machine = false
var dash_tick: float = 0

onready var current_health = START_HEALTH
onready var melee_range = $MeleeRange

signal player_death
signal damaged(amount)
signal mode_change(new_mode)

func _ready():
	add_to_group("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	# Moves the player based on arrow key/WASD inputs
	var movement_vector = Vector2()
	if Input.is_action_pressed("move_forward"):
		movement_vector.y -= 1
	elif Input.is_action_pressed("move_back"):
		movement_vector.y += 1
	if Input.is_action_pressed("move_left"):
		movement_vector.x -= 1
	elif Input.is_action_pressed("move_right"):
		movement_vector.x += 1
	
	# Toggles shot scattering, since I'm not very good at this game.
	if Input.is_action_just_pressed("1"):
		mode = "Normal"
		emit_signal("mode_change", mode)
	elif Input.is_action_just_pressed("2"):
		mode = "Bounce"
		emit_signal("mode_change", mode)
	elif Input.is_action_just_pressed("3"):
		mode = "Scatter"
		emit_signal("mode_change", mode)
	elif Input.is_action_just_pressed("4"):
		mode = "Machine"
		emit_signal("mode_change", mode)
	elif Input.is_action_just_pressed("5"):
		mode = "Bomb"
		emit_signal("mode_change", mode)
		
	if Input.is_action_just_pressed("left_click"):
		if mode == "Scatter":
			$Shooter.scatter()
			hurt(10)
		elif mode == "Bounce":
			$Shooter.bounce()
			hurt(10)
		elif mode == "Machine":
			machine = true
		elif mode == "Normal":
			$Shooter.shoot()
			hurt(5)
		elif mode == "Bomb":
			$Shooter.bomb()
			hurt(15)
			
		
	if Input.is_action_just_released("left_click"):
		machine = false
		
	if (machine):
		if time_passed > BARRAGE_INTERVAL:
			$Shooter.shoot()
			hurt(2)
			time_passed = 0
		time_passed += delta
		
	if Input.is_action_just_pressed("right_click"):
		var targets = melee_range.get_overlapping_bodies()
		for t in targets:
			if t.has_method("kill") and not(t == self): t.kill()
			elif t.has_method("talk") and not (t == self): t.talk()
			
	var dashing: int = 1
	if Input.is_action_pressed("shift"):
		dashing = 2
		if movement_vector.length() * MOVE_SPEED > LIN_EPSILON and dash_tick == 0:
			hurt(1)
		dash_tick += delta
		if dash_tick > 0.5: dash_tick = 0
	
	if Input.is_action_just_released("shift"):
		dash_tick = 0	
	
	look_at(get_global_mouse_position())
# warning-ignore:return_value_discarded
	move_and_slide(movement_vector * MOVE_SPEED * dashing)
	
func get_rotation():
	return global_rotation
	
func hurt(damage):
	emit_signal("damaged", -damage)
	current_health -= damage
	if current_health <= 0: kill()
	
func death_heal():
	hurt(-DEATH_HEAL)

func kill():
	emit_signal("player_death")
	$DeathSound.play()
	$AnimationPlayer.play("death")
	set_physics_process(false)
	yield(get_tree().create_timer(3), "timeout")
	get_tree().quit(0)
	
func next_level(path):
	print("Trying to change level...")
	assert(get_tree().change_scene(path) == OK)
