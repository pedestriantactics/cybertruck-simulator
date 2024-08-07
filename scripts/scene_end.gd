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

# amount of numbers to skip for speed sake
var skip_numbers = 2

# allows skipping when pressing enter
var skip_key_enabled = false

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

	# save specific values from the blackboard to the saved blackboard
	# top speed
	var key_to_check = "maximum_speed_achieved_miles_per_hour"
	if blackboard.kvps.has(key_to_check):
		# compare if the saved blackboard has one
		if blackboard.saved_kvps.has(key_to_check):
			var session_top_speed = blackboard.kvps[key_to_check]
			var saved_top_speed = blackboard.saved_kvps[key_to_check]
			if session_top_speed > saved_top_speed:
				blackboard.saved_kvps[key_to_check] = session_top_speed
		else:
			blackboard.saved_kvps[key_to_check] = blackboard.kvps[key_to_check]

	# total distance traveled
	key_to_check = "total_distance_traveled_miles"
	if blackboard.kvps.has(key_to_check):
		# add it to the saved blackboard
		if blackboard.saved_kvps.has(key_to_check):
			blackboard.saved_kvps[key_to_check] += blackboard.kvps[key_to_check]
		else:
			blackboard.saved_kvps[key_to_check] = blackboard.kvps[key_to_check]

	# total lawsuits
	key_to_check = "lawsuits"
	if blackboard.kvps.has(key_to_check):
		# add it to the saved blackboard
		if blackboard.saved_kvps.has(key_to_check):
			blackboard.saved_kvps[key_to_check] += blackboard.kvps[key_to_check]
		else:
			blackboard.saved_kvps[key_to_check] = blackboard.kvps[key_to_check]

	# total trees hit
	key_to_check = "trees_hit"
	if blackboard.kvps.has(key_to_check):
		# add it to the saved blackboard
		if blackboard.saved_kvps.has(key_to_check):
			blackboard.saved_kvps[key_to_check] += blackboard.kvps[key_to_check]
		else:
			blackboard.saved_kvps[key_to_check] = blackboard.kvps[key_to_check]

	# dogecoins collected
	key_to_check = "dogecoin_collected"
	if blackboard.kvps.has(key_to_check):
		# there's only one to collect so just add it
		if blackboard.saved_kvps.has(key_to_check):
			blackboard.saved_kvps[key_to_check] += 1
		else:
			blackboard.saved_kvps[key_to_check] = 1

	key_to_check = "day_completed"
	var save_key = "days_completed"
	if blackboard.kvps.has(key_to_check) and int(blackboard.kvps[key_to_check] == 1):
		# day complete is binary so just add to the day
		if blackboard.saved_kvps.has(save_key):
			blackboard.saved_kvps[save_key] += 1
		else:
			blackboard.saved_kvps[save_key] = 1

	# save
	blackboard.save()

func _on_timeout():
	if current_label_index >= key_labels.size():
		retry_button.pressed.connect(scene_changer.change_scene.bind("play"))
		menu_button.pressed.connect(scene_changer.change_scene.bind("menu"))

		if blackboard.kvps.has("day_completed") and blackboard.kvps["day_completed"] == 1:
			retry_button.text = "Next day"
		retry_button.show()
		menu_button.show()
		
		retry_button.grab_focus()
		return

	var key_label = key_labels[current_label_index]
	var value_label = value_labels[current_label_index]

	var blackboard_value = blackboard.kvps.get(key_label.name)
	var blackboard_value_int = 0
	if blackboard_value != null:
		var blackboard_float = float(blackboard_value)
		# round blackboard value down to the nearest int, if it's 1 it should be rounded to 1
		blackboard_value_int = int(floor(blackboard_float))

	var current_labeled_value = int(value_label.text)

	match timer_state:
		0:
			key_label.show()
			value_label.show()
			click_sound_audiostream_player.stream = show_sound
			click_sound_audiostream_player.play()
			animation_player.play("glitch")

			if current_labeled_value >= blackboard_value_int || key_label.name == "dogecoin_collected" || key_label.name == "day_completed":
				# if the value is the same as blackboard
				if (key_label.name == "dogecoin_collected"):
					if blackboard_value_int == 0:
						value_label.text = "Nope"
					else:
						value_label.text = "Yup"
				elif (key_label.name == "day_completed"):
					if blackboard_value_int == 0:
						value_label.text = "Nope"
					else:
						value_label.text = "Yup"
					if !blackboard.kvps.has("day_completed"):
						value_label.text = "N/A"
				else:
					value_label.text = str(blackboard_value_int)
			else:
				# break after the name appears to when it starts counting up
				timer_state = 1
				if skip_key_enabled:
					skip_key_enabled = false
					# _on_timeout()
				else:
					timer = 0.4
					return
		1:
			if current_labeled_value < blackboard_value_int:
				# check if it's worth skipping some numbers
				var check_value = current_labeled_value + (1 * skip_numbers)
				if check_value < blackboard_value_int:
					if (key_label.name == "dogecoin_collected"):
						if blackboard_value_int == 1:
							value_label.text = 1
							return		
					elif (key_label.name == "day_completed"):
						if blackboard_value_int == 1:
							value_label.text = 1
							return
					else:
						value_label.text = str(check_value)
				else:
					value_label.text = str(current_labeled_value + 1)
				timer = 0.02
				click_sound_audiostream_player.play_random()
				return

	timer_state = 0
	impact_sound_audiostream_player.play_random()
	animation_player.play("glitch_impact")
	current_label_index += 1
	timer = 0.4
	return
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer > 0:
		timer -= delta
		if timer <= 0:
			_on_timeout()

func _input(event):
	if event.is_action_released("ui_accept"):
		if (current_label_index >= key_labels.size()):
			return
		timer_state = 0
		timer = 0
		skip_key_enabled = true
		var key_label = key_labels[current_label_index]
		var blackboard_value = blackboard.kvps.get(key_label.name)
		var blackboard_value_int = 0
		if blackboard_value != null:
			blackboard_value_int = int(floor(blackboard_value))
		var value_label = value_labels[current_label_index]
		value_label.text = str(blackboard_value_int)
		_on_timeout()
