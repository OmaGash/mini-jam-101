extends StaticBody2D
#Will handle the floor's behavior
enum STATES{
	STATE_GREEN,#0
	STATE_RED#1
}
export(STATES) var current_color: = STATES.STATE_GREEN#Green default

func toggle_state():
	if current_color == STATES.STATE_GREEN:
		current_color = STATES.STATE_RED
	else:
		current_color = STATES.STATE_GREEN
		

func _physics_process(delta):
	if Input.is_action_just_pressed("change_environment"):
		toggle_state()
	match current_color:
		STATES.STATE_GREEN:
			modulate = lerp(modulate, Color.green, 0.08)
		STATES.STATE_RED:
			modulate = lerp(modulate, Color.red, 0.08)
