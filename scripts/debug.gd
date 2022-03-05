extends Control

func _process(delta):
	$HBoxContainer/states.text = "States: " + str($"../player".current_state)
