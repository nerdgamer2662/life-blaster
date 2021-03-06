extends MarginContainer

func _ready():
	set_process(false)

func update_text(text: String):
	self.visible = true
	$DialogueBox/RichTextLabel.text = text
	set_process(true)
	get_tree().paused = true
	
func _process(_delta):
	if Input.is_action_just_pressed("left_click"):
		self.visible = false
		get_tree().paused = false
		set_process(false)
