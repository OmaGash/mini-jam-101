extends Node

signal loading
signal done

enum STATUS{
	DONE,
	LOADING,
	ERROR
}
var current_status: int

func _ready():
	current_status = STATUS.DONE
	pause_mode = Node.PAUSE_MODE_PROCESS

var max_loading_time = 10000

func load_scene(path_to_scene: String, current_scene: Node):
	var loader = ResourceLoader.load_interactive(path_to_scene)
	if current_status != STATUS.DONE: return
	current_status = STATUS.LOADING
	if loader == null:
		current_status = STATUS.ERROR
		print("Error loading resource. (", path_to_scene, ") was not loaded")
		get_tree().quit()
		return
	
	var loading_bar: ProgressBar = load("res://scenes/loading_bar.tscn").instance()
	var transition: ColorRect = load("res://scenes/transition.tscn").instance()
#	loading_bar.theme = load(g.theme) 
	transition.call_deferred("add_child", loading_bar)
	get_tree().root.call_deferred("add_child", transition)
	yield(transition.get_node("anim"), "animation_finished")
	var t = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() - t < max_loading_time:#Load while max_loading_time is not reached
		var err = loader.poll()
		if err == ERR_FILE_EOF:#Load done
			var resource: PackedScene = loader.get_resource()
			get_tree().root.call_deferred("add_child", resource.instance())
			loading_bar.queue_free()
			current_scene.queue_free()
			transition.get_node("anim").play_backwards("fade")
			yield(transition.get_node("anim"), "animation_finished")
			transition.queue_free()
			get_tree().root.set_disable_input(false)
			print("done")
			current_status = STATUS.DONE
			emit_signal("done")
			break
		elif err == OK:#Scene is loading
			current_status = STATUS.LOADING
			emit_signal("loading")
			get_tree().root.set_disable_input(true)
			var progress = float(loader.get_stage())/loader.get_stage_count()
			loading_bar.value = progress * 100
		else:
			current_status = STATUS.ERROR
			print("Error loading [", err, "].")
			break
		yield(get_tree(), "idle_frame")
