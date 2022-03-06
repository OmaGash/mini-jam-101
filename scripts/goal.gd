extends Node2D

enum STATES{
	STATE_GREEN,#0
	STATE_RED#1
}
export(STATES) var current_color: = STATES.STATE_GREEN#Green default
func _ready():
	#set the goal's color
	match current_color:
		STATES.STATE_GREEN:
			modulate = Color.green
		STATES.STATE_RED:
			modulate = Color.red
	#Add this node to goal groups so you dont have to set it every single time
	add_to_group("goal")
