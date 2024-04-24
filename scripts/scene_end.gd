extends Control

# this will reveal different stats that were collected in the game in an animated fashion
# one container contains labels that are labeled with the key name for a value stored in the blackboard
# if the name of the label is found in the blackboard keys, the label will be set to visible along with the value label which is stored in another container at the same index
# the label will have a delay after it is revealed before the value label iterates up the numbers from 1 to the value that was stored (rounded)
# once the iteration is finished there is a delay before the next label is revealed
# once all the labels are revealed, the menu buttons at the bottom will reveal themselves

@onready var scene_changer = get_node("/root/SceneChanger")
@export var retry_button_path: NodePath
@onready var retry_button = get_node(retry_button_path)
@export var menu_button_path: NodePath
@onready var menu_button = get_node(menu_button_path)

@export var show_sound: AudioStream
@export var end_sound: AudioStream 
@onready var click_sound_audiostream_player = get_node("Click")
@onready var impact_sound_audiostream_player = get_node("Impact")

# containers for key labels
@export var key_container_path: NodePath
@onready var key_labels = get_node(key_container_path).get_children()

# containers for value labels
@export var value_container_path: NodePath
@onready var value_labels = get_node(value_container_path).get_children()

@onready var animation_player = get_node("AnimationPlayer")

# blackboard
@onready var blackboard = get_node("/root/Blackboard")

# create a timer
var timer = 0.00

# timer state
# 0 is waiting for the next label to be revealed
# 1 is waiting for the value to be iterated
var timer_state = 0

var current_label_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	retry_button.hide()
	menu_button.hide()

	# hide all the labels
	for child in key_labels:
		child.hide()
	for child in value_labels:
		child.hide()
	
	# start the timer
	timer = 1

func _on_timeout():
	if current_label_index >= key_labels.size():
		retry_button.pressed.connect(scene_changer.change_scene.bind("play"))
		menu_button.pressed.connect(scene_changer.change_scene.bind("menu"))

		retry_button.show()
		menu_button.show()
		
		retry_button.grab_focus()
		return

	match timer_state:
		0:
			key_labels[current_label_index].show()
			value_labels[current_label_index].show()
			timer = 0.3
			timer_state = 1
			click_sound_audiostream_player.stream = show_sound
			click_sound_audiostream_player.play()
			animation_player.play("glitch")
			return
		1:
			var value_label = value_labels[current_label_index]
			var blackboard_value = blackboard.kvps.get(key_labels[current_label_index].name)
			if blackboard_value != null:
				var blackboard_value_int = int(floor(blackboard_value))
				var current_value = value_label.text.to_int()
				if current_value < blackboard_value_int:
					value_label.text = str(current_value + 1)
					timer = 0.02
					click_sound_audiostream_player.play_random()
					return
			
			timer_state = 0
			current_label_index += 1
			timer = 0.3
			if (value_label.text.to_int() > 0):
				impact_sound_audiostream_player.play_random()
				animation_player.play("glitch_impact")
			return
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer > 0:
		timer -= delta
		if timer <= 0:
			_on_timeout()

