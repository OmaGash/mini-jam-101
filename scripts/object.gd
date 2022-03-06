extends KinematicBody2D

export var mass = 50
export var gravity = 50#Gravity Falls
export var jump = 1000#Jump Force
export var repel_radius = 128#How far the social distancing should be
var player_node: KinematicBody2D#Stores a reference for the player's node
var velocity: Vector2
var current_color = 0#0 is green, 1 is red
enum{
	GREEN,
	RED
}
enum STATE{
	FOLLOW,
	REPEL,
	NEUTRAL
}
var current_state:int = STATE.NEUTRAL
func _ready():
	$"../player".connect("color_changed", self, "_player_color_changed")

func _physics_process(delta):
	velocity.y += gravity
	modulate = lerp(modulate, Color.green, 0.08) if current_color == GREEN else lerp(modulate, Color.red, 0.08)
	_hover()
	_move()
	velocity = move_and_slide(velocity, Vector2(0,-1))

func _hover():#Handles the floaty floaty
	for ray in $hover.get_children():
		if ray.is_colliding():
			var similar_color = ray.get_collider().get("current_color") == current_color
			if ray.get_collider().is_in_group("goal") and similar_color:
				g.current_score += 1
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
			GREEN:#Green
				_react(GREEN)
			RED:
				_react(RED)

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
