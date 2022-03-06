extends KinematicBody2D

signal color_changed

export var speed = 250#Movement speed
export var mass = 50
export var gravity = 50#Gravity Falls
export var jump = 1000#Jump Force
var dir = 1#Direction currently facing, 1 for right and -1 for left
var velocity: Vector2
var current_state = []#All the states the player is currently in
var current_color = 0#0 is green, 1 is red
var next_color: Color = Color.green#Green default
enum {
	STATE_IDLE,#0
	STATE_WALK,#1
	STATE_JUMP,#2
	STATE_FALL,#3
	STATE_CONTROLLED#4
}

func _add_state(state: int):#Add state only once it's not added yet.
	if not current_state.has(state):
		current_state.append(state)
func _remove_state(state: int):#Remove state only once it's included.
	if current_state.has(state):
		current_state.erase(state)

func _ready():
	pass

func _physics_process(delta):
	velocity.y += gravity
	_animation()
	_hover()
	if current_state.size() <= 0:#When it's not in any other states, put in idle by default.
		_add_state(STATE_IDLE)
	else:
		if current_state.size() >= 2:#If player's no longer idle, remove it from idle state.
			_remove_state(STATE_IDLE)
		
	
	if is_on_floor():#After landing a fall, remove the fall state from the player.
		_remove_state(STATE_FALL)
		gravity = mass
	else:
		if velocity.y > 0:#Once the y velocity goes positive while the player isn't touching the ground, the state is considered as falling.
			_remove_state(STATE_JUMP)
			_add_state(STATE_FALL)
	
	
	if !current_state.has(STATE_CONTROLLED):
		_move()
	else:#if the player is controlled
		#only stop the velocity.x after the player lands
		if !current_state.has(STATE_FALL) and !current_state.has(STATE_JUMP):
			velocity.x = 0
			

	velocity = move_and_slide(velocity, Vector2(0,-1))

func _animation():#Handles animations
	$Icon.scale.x = dir
	if current_state.has(STATE_IDLE) and current_state.size() == 1:#Idle is the only state
		$AnimationPlayer.play("idle")
	elif current_state.has(STATE_WALK):
		if current_state.has(STATE_JUMP):#Walking while jumping
			$AnimationPlayer.play("walk-jump")
			return
		elif current_state.has(STATE_FALL):#Walking while falling
			$AnimationPlayer.play("walk-fall")
			return
		$AnimationPlayer.play("walk")
	elif current_state.has(STATE_JUMP):
		$AnimationPlayer.play("jump")
	elif current_state.has(STATE_FALL):
		$AnimationPlayer.play("fall")

func _move():#Controls section
	#Change color
	if Input.is_action_just_pressed("change_player"):
		match current_color:
			0:#Green turn to red
				next_color = Color.red
				current_color = 1
				emit_signal("color_changed", 1)
			1:#Red turn to Green
				next_color = Color.green
				current_color = 0
				emit_signal("color_changed", 0)
	modulate = lerp(modulate, next_color, 0.08)
	#Jump
	if Input.is_action_just_pressed("ui_up") and (!current_state.has(STATE_FALL) and !current_state.has(STATE_JUMP)):
		velocity.y -= jump
		_add_state(STATE_JUMP)
	
	
	velocity.x = speed * dir
	if Input.is_action_pressed("ui_left"):
		dir = -1
		_add_state(STATE_WALK)
	elif Input.is_action_pressed("ui_right"):
		dir = 1
		_add_state(STATE_WALK)
	else:
		velocity.x = 0
		_remove_state(STATE_WALK)

func _controlled():
	if current_state.has(STATE_CONTROLLED): return#Don't run if already stunned.
	_add_state(STATE_CONTROLLED)
	$tooltip.show()
	$control.start()
	while !$control.is_stopped():
		$tooltip.text = str(int($control.time_left)+1)
		yield(get_tree(), "idle_frame")
	$tooltip.hide()
	
func _hover():#Handles the floaty floaty
	for raycast in $hover.get_children():
		if raycast.is_colliding():
			#If floor is different color
			if raycast.get_collider().get("current_color") != current_color and !raycast.get_collider().is_in_group("object"):
				velocity.y = -jump/5
				gravity = mass/20
				_add_state(STATE_JUMP)
			else:
				gravity = mass



func _on_control_timeout():
	_remove_state(STATE_CONTROLLED)
