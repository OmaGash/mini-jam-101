extends Node2D

export var goal_score: int = 1#How many objects that needs replacing

func _ready():
	g.level_goal = goal_score
	g.connect("level_completed", self, "_Print_goal")

func _Print_goal():
	print("kjsadfhklhdsflkjsdfh")
