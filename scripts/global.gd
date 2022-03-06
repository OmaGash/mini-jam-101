extends Node

signal level_completed#Emits when level goal is reached

var current_score:= 0 setget set_score
var level_goal:int = 1
var debug: bool = false

func set_score(new_score):
	current_score = new_score
	if new_score == 0: return
	if current_score >= level_goal:
		emit_signal("level_completed")
