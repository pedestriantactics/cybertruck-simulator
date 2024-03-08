extends AnimationPlayer

var next_scene_name = ""
var base_path = "res://"
var file_extension = ".tscn"

# TODO: add time limit

# var loading = false

var progress_screen: Node
var progress_bar: Node

var current_scene: Node

# timer to show the progress var
var timer = 0.0
var time_limit_seconds = 0.1

# this handles changing scenes and transitioning between each scene using the ColorRect
# when the scene change function is called, the game is paused, the ColorRect is faded using the Animation, and then the scene is changed
# once the new scene is loaded the ColorRect is faded back in and the game is unpaused

func _ready():
	progress_screen = get_node("CanvasLayer/ProgressScreen")
	progress_bar = get_node("CanvasLayer/ProgressScreen/ProgressBar")
	progress_bar.value = 0
	progress_screen.hide();

	current_scene = get_tree().current_scene

	# fade the ColorRect
	play("fade_in")
	set_process(false)

func change_scene(scene_name):
	# check if there's a scene associated with the name
	if not ResourceLoader.exists(base_path + scene_name + file_extension):
		printerr("Scene does not exist: " + scene_name)
		return

	next_scene_name = scene_name

	if !ResourceLoader.has_cached(base_path + next_scene_name + file_extension):
		# if the scene is not loaded, load the scene and change the scene
		print("scene is not cached")
		ResourceLoader.load_threaded_request(base_path + next_scene_name + file_extension)
	else:
		# if the scene is already loaded, change the scene
		print("scene is cached")

	# pause the game
	get_tree().paused = true

	# this will prevent the loader from loading the scene right away
	set_process(false)

	play("fade_out")

func animation_change_scene():
	# set the countdown
	timer = time_limit_seconds
	set_process(true)

func unpause():
	get_tree().paused = false

func _process(delta):
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(base_path + next_scene_name + file_extension, progress)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		progress_bar.value = progress[0]
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(base_path + next_scene_name + file_extension))
		progress_screen.hide()
		play("fade_in")
		set_process(false)
		return
	else :
		printerr("Error loading scene: " + next_scene_name)

	# if the timer is running keep subtracting it
	if timer <= 0 && !progress_screen.is_visible():
		progress_screen.show()
		return
		
	timer -= delta