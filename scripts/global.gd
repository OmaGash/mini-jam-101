extends Node

signal level_completed#Emits when level goal is reached

var current_score:= 0 setget _set_score
var level_goal:int = 1
var debug: bool = false
var current_level:int = 0 setget _set_level

func _set_level(new_level):
	current_level = min(new_level, 2)#Adjust second parameter according to number of levels the game currently has

func _set_score(new_score):
	current_score = new_score
	if new_score == 0: return
	if current_score >= level_goal:
		emit_signal("level_completed")
