extends Control

func _ready():
	if !g.debug:
		queue_free()
	g.connect("level_completed", self, "level_completed")

func _process(delta):
	if Input.is_action_just_pressed("reset"):
		get_tree().change_scene("res://world.tscn")
	
	$VBoxContainer/HBoxContainer/states.text = "States: " + str($"../player".current_state)
	$VBoxContainer/HBoxContainer/current_animation.text = $"../player/AnimationPlayer".current_animation
func level_completed():
	$victory.popup_centered()
