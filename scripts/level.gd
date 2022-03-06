extends Node2D

export var goal_score: int = 1#How many objects that needs replacing

func _ready():
	g.level_goal = goal_score
	g.connect("level_completed", self, "_Print_goal")

func _Print_goal():
	print("kjsadfhklhdsflkjsdfh")

func _process(delta):
	if Input.is_action_just_pressed("reset") and loader.current_status == loader.STATUS.DONE:
		loader.load_scene("res://scenes/levels/level0.tscn", self)
		
