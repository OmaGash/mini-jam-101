extends KinematicBody2D

enum COLOR{
	GREEN,
	RED
}
export(COLOR) var current_color:= COLOR.GREEN#0 is green, 1 is red
export var mass = 50
export var gravity = 50#Gravity Falls
export var jump = 1000#Jump Force
export var repel_radius = 128#How far the social distancing should be
var player_node: KinematicBody2D#Stores a reference for the player's node
var velocity: Vector2
var rays_colliding:Array = []#needs both rays colliding to consider a goal [ray1. ray2]


enum STATE{
	FOLLOW,
	REPEL,
	NEUTRAL
}
var current_state:int = STATE.NEUTRAL
func _ready():
	$"../player".connect("color_changed", self, "_player_color_changed")
	
	modulate = Color.green if current_color == COLOR.GREEN else Color.red
	
func _physics_process(delta):
	velocity.y += gravity
	
	_hover()
	_move()
	velocity = move_and_slide(velocity, Vector2(0,-1))

func _hover():#Handles the floaty floaty
	if !has_node("hover"):
		modulate = lerp(modulate, Color.white, 0.08)#Decolorize when done
		return#dont run when hover detection node is deleted
	
	if rays_colliding.size() == 2 and is_on_floor():
		g.current_score += 1
		$Area2D.monitoring = false
		$hover.queue_free()
		return
	
	for ray in $hover.get_children():
		if ray.is_colliding():
			var similar_color = ray.get_collider().get("current_color") == current_color
			if ray.get_collider().is_in_group("goal") and similar_color:
				if !rays_colliding.has(ray.name):#If one of the rays collided with goal, add the ray to the list
					rays_colliding.append(ray.name)
			if !similar_color:
				velocity.y = -jump/5
				gravity = mass/20
			else:
				gravity = mass

func _move():#Do the following/repelling
	match current_state:
		STATE.FOLLOW:#Check for the player's location, then head towards the player's respective x axis
			if position != player_node.position:
				position = lerp(position, player_node.position, 0.08)
#			if position.x != player_node.position.x:
#				position.x = lerp(position.x, player_node.position.x, 0.08)
		STATE.REPEL:#Check the player's location then move away from it
			if position.x < player_node.position.x:
				repel_radius = -abs(repel_radius)
			else:
				repel_radius = abs(repel_radius)
			position.x = lerp(position.x, player_node.position.x + repel_radius, 0.08)

func _on_Area2D_body_entered(body):
	if body.name == "player":
		player_node = body
		match body.get("current_color"):
			COLOR.GREEN:#Green
				_react(COLOR.GREEN)
			COLOR.RED:
				_react(COLOR.RED)

func _on_Area2D_body_exited(body):
	if body.name == "player":
		player_node = null
		current_state = STATE.NEUTRAL

func _player_color_changed(color):
	if player_node != null: _react(color)

func _react(color: int):
	if color != current_color:#repel mode if different colors
		current_state = STATE.REPEL
	else:
		current_state = STATE.FOLLOW
