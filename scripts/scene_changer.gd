extends AnimationPlayer

var next_scene_name 
var base_path = "res://"
var file_extension = ".tscn"

# this handles changing scenes and transitioning between each scene using the ColorRect
# when the scene change function is called, the game is paused, the ColorRect is faded using the Animation, and then the scene is changed
# once the new scene is loaded the ColorRect is faded back in and the game is unpaused

func _ready():
	# fade the ColorRect
	play("fade_in")
	pass

func _process(delta):
	pass

func change_scene(scene_name):
	# TODO: disable all input
	# check if there's a scene associated with the name
	if not ResourceLoader.exists(base_path + scene_name + file_extension):
		printerr("Scene does not exist: " + scene_name)
		return
	next_scene_name = scene_name
	# pause the game
	get_tree().paused = true
	animation_finished.connect(animation_change_scene)
	play("fade_out")

func animation_unpause(animation_name):
	# TODO: enable all input
	pass

func animation_change_scene(animation_name):
	get_tree().paused = false
	animation_finished.disconnect(animation_change_scene)
	animation_finished.connect(animation_unpause);
	get_tree().change_scene_to_file(base_path + next_scene_name + file_extension)
	play("fade_in")
