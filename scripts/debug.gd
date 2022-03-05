extends Control

func _ready():
	g.connect("level_completed", self, "level_completed")

func _process(delta):
	$HBoxContainer/states.text = "States: " + str($"../player".current_state)

func level_completed():
	$victory.popup_centered()
