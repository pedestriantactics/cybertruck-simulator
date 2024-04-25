extends Control

@onready var scene_changer = get_node("/root/SceneChanger")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _change_scene():
	scene_changer.change_scene("menu");

func _input(event):
	if event.is_action_released("ui_accept"):
		_change_scene()
