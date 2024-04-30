extends Control

@onready var scene_changer = get_node("/root/SceneChanger")

@export var play_button_path: NodePath
@onready var play_button = get_node(play_button_path)

@export var quit_button_path: NodePath
@onready var quit_button = get_node(quit_button_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	play_button.pressed.connect(scene_changer.change_scene.bind("play"))

	# assign the quit button to close the window
	quit_button.pressed.connect(get_tree().quit)
