extends Camera2D
#The camera needs to be at the bottom of the root node's children.
#Then assign the player scene to the camera so the camera would be able to follow the player.

export var player_scene: NodePath #Add the player scene from the editor
export var follow_x: bool = true#Whether the camera will follow the player on the x axis
export var follow_y: bool = true#Whether the camera will follow the player on the y axis
export(int, "Follow Up and Down", "Follow Down Only", "Follow Up Only") var followY_options
export var follow_offset: Vector2 = Vector2(0,0)# The point where the camera will move
export var smoothing: float = .01
onready var player_node: Node2D = get_node(player_scene) if has_node(player_scene) else null

func _ready():
	if player_node == null:
		print("/tools/camera.gd: I think you forgot to assign the player in the Camera node's inspector.")
		var warning = load("res://ui/warning.tscn").instance()
		add_child(warning)
		warning.warn(get_tree(), "/tools/camera.gd: I think you forgot to assign the player in the Camera node's inspector.")
		set_physics_process(false)
	current = true

func _physics_process(_delta: float):
	#TODO: Add offset then smoothing
	#Check if the player's x is getting to the screen's edge
	if follow_x:
		if player_node.position.x < position.x - follow_offset.x:#Left offset
			position.x = lerp(position.x, player_node.position.x + follow_offset.x, smoothing)
		if player_node.position.x > position.x + follow_offset.x:#Right offset
			position.x = lerp(position.x, player_node.position.x - follow_offset.x, smoothing)
	if follow_y:
		if player_node.position.y < position.y - follow_offset.y and (followY_options == 0 or followY_options == 2):#Up offset
			position.y = lerp(position.y, player_node.position.y + follow_offset.y, smoothing)
		if player_node.position.y > position.y + follow_offset.y and (followY_options == 0 or followY_options == 1):#Down offset
			position.y = lerp(position.y, player_node.position.y - follow_offset.y, smoothing)
#	position.x = player_node.position.x
#	position.y = player_node.position.y + 4
