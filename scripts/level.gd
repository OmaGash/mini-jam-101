extends Node2D

export var goal_score: int = 1#How many objects that needs replacing

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	g.current_score = 0
	g.level_goal = goal_score
	g.connect("level_completed", self, "_goal")

func _goal():
	var popup:AcceptDialog = AcceptDialog.new()
	popup.window_title = "Win"
	popup.dialog_text = "Level completed"
	popup.add_button("Restart", false, "reset")
	popup.popup_exclusive = true
	popup.get_ok().text = "Next Level"
	popup.connect("custom_action", self, "_dialog_pressed")
	popup.connect("confirmed", self, "_dialog_pressed")
	
	$ui.add_child(popup, true)
	popup.popup_centered()
	get_tree().paused = true

func _dialog_pressed(command: String = ""):
	match command:
		"reset":
			get_tree().paused = false
			loader.load_scene("res://scenes/levels/level" + str(g.current_level) + ".tscn", self)
		"":
			get_tree().paused = false
			g.current_level += 1
			loader.load_scene("res://scenes/levels/level" + str(g.current_level) + ".tscn", self)

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		loader.load_scene("res://scenes/levels/level" + str(g.current_level) + ".tscn", self)
		
