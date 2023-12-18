extends Control

@onready var scene_changer = get_node("/root/SceneChanger")
@export var play_button_path: NodePath
@onready var play_button = get_node(play_button_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	play_button.pressed.connect(scene_changer.change_scene.bind("play"))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
