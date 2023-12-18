extends AnimationPlayer

var next_scene_name 

# this handles changing scenes and transitioning between each scene using the ColorRect
# when the scene change function is called, the game is paused, the ColorRect is faded using the Animation, and then the scene is changed
# once the new scene is loaded the ColorRect is faded back in and the game is unpaused

func _ready():
	# fade the ColorRect
	play("fade")
	pass

func _process(delta):
	pass

func change_scene(scene_name):
	next_scene_name = scene_name
	# pause the game
	get_tree().paused = true
	play("fade_in")

func animation_unpause():
	get_tree().paused = false

func animation_change_scene():
	get_tree().change_scene(next_scene_name)
	play("fade_out")