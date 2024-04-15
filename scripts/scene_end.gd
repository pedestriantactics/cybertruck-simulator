extends Control

@onready var scene_changer = get_node("/root/SceneChanger")
@export var retry_button_path: NodePath
@onready var retry_button = get_node(retry_button_path)
@export var menu_button_path: NodePath
@onready var menu_button = get_node(menu_button_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	retry_button.pressed.connect(scene_changer.change_scene.bind("play"))
	menu_button.pressed.connect(scene_changer.change_scene.bind("menu"))
	retry_button.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
