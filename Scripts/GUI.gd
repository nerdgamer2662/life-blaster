extends MarginContainer

var mode_label
var player
var sp_bar
var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	mode_label = $HBoxContainer/Mode
	sp_bar = $HBoxContainer/SPBar
	tween = $HBoxContainer/Tween
	player = get_tree().get_nodes_in_group("player")[0]
	player.connect("mode_change", self, "change_label")
	player.connect("damaged", self, "update_bar")
	#player.connect("player_defeated", self, )

func change_label(new_mode: String):
	mode_label.text = "Mode: " + new_mode
	mode_label.update()
	
func update_bar(amount: int):
	tween.interpolate_property(sp_bar, "value", 
			sp_bar.value, sp_bar.value + amount, 0.05,
			Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	

