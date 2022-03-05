extends KinematicBody2D

export var speed = 250#Movement speed
export var mass = 50
export var gravity = 50#Gravity Falls
export var jump = 1000#Jump Force
var velocity: Vector2
var current_state = []#All the states the player is currently in
var current_color = 0#0 is green, 1 is red
enum {
	STATE_IDLE,#0
	STATE_WALK,#1
	STATE_JUMP,#2
	STATE_FALL,#3
	STATE_CONTROLLED#4
}

func add_state(state: int):#Add state only once it's not added yet.
	if not current_state.has(state):
		current_state.append(state)
func remove_state(state: int):#Remove state only once it's included.
	if current_state.has(state):
		current_state.erase(state)

func _ready():
	pass

func _physics_process(delta):
	velocity.y += gravity
	
	hover()
	if current_state.size() <= 0:#When it's not in any other states, put in idle by default.
		add_state(STATE_IDLE)
	else:
		if current_state.size() >= 2:#If player's no longer idle, remove it from idle state.
			remove_state(STATE_IDLE)
		
	
	if is_on_floor():#After landing a fall, remove the fall state from the player.
		remove_state(STATE_FALL)
	else:
		if velocity.y > 0:#Once the y velocity goes positive while the player isn't touching the ground, the state is considered as falling.
			remove_state(STATE_JUMP)
			add_state(STATE_FALL)
	
	
	if !current_state.has(STATE_CONTROLLED):
		move()
	else:#if the player is controlled
		#only stop the velocity.x after the player lands
		if !current_state.has(STATE_FALL) and !current_state.has(STATE_JUMP):
			velocity.x = 0
			

	velocity = move_and_slide(velocity, Vector2(0,-1))

func move():#Controls section
	if Input.is_action_just_pressed("ui_up") and (!current_state.has(STATE_FALL) and !current_state.has(STATE_JUMP)):
		velocity.y -= jump
		add_state(STATE_JUMP)
	
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		add_state(STATE_WALK)
	elif Input.is_action_pressed("ui_right"):
		velocity.x = speed
		add_state(STATE_WALK)
	else:
		velocity.x = 0
		remove_state(STATE_WALK)

func control():
	if current_state.has(STATE_CONTROLLED): return#Don't run if already stunned.
	add_state(STATE_CONTROLLED)
	$time.show()
	$control.start()
	while !$control.is_stopped():
		$time.text = str(int($control.time_left)+1)
		yield(get_tree(), "idle_frame")
	$time.hide()
	
func hover():#Handles the floaty floaty
	
	if $hover.is_colliding():
		if $hover.get_collider().get("current_state") != current_color:
			velocity.y = -jump/5
			gravity = mass/20
		else:
			gravity = mass
	
func _on_control_timeout():
	remove_state(STATE_CONTROLLED)
