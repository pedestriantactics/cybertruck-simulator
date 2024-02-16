extends Control

@onready var scene_changer = get_node("/root/SceneChanger")

@export var resume_button_path: NodePath
var resume_button: Button

@export var restart_button_path: NodePath

@export var main_menu_button_path: NodePath

# hides when paused
@export var make_invisible_when_paused_paths: Array[NodePath]
var make_invisible_when_paused: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready():

	for path in make_invisible_when_paused_paths:
		var node = get_node(path)
		make_invisible_when_paused.append(node)

	resume_button = get_node(resume_button_path)
	resume_button.pressed.connect(_resume)

	var restart_button = get_node(restart_button_path)
	restart_button.pressed.connect(scene_changer.change_scene.bind("play"))

	var main_menu_button = get_node(main_menu_button_path)
	main_menu_button.pressed.connect(scene_changer.change_scene.bind("menu"))

	visible = false
	

# when the key is pressed
func _input(event):
	if event.is_action_released("pause"):

		if visible:
			_resume()
		else:
			if make_invisible_when_paused.size() > 0:
				for item in make_invisible_when_paused:
					item.hide()
			visible = true
			resume_button.grab_focus()
			get_tree().paused = true

func _resume():
	if make_invisible_when_paused.size() > 0:
		for item in make_invisible_when_paused:
			item.show()
	visible = false
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
